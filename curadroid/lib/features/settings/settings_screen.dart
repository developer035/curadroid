import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/crisis_fab.dart';
import '../../data/repositories/checkin_repo.dart';
import '../../data/repositories/session_repo.dart';
import '../../data/repositories/settings_repo.dart';
import '../../domain/coach/llm_coach_engine.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _useRealHealth;
  late TimeOfDay _reminderTime;
  late bool _useAiCoach;
  late TextEditingController _proxyUrlController;
  late String _installId;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsRepoProvider);
    _useRealHealth = settings.useRealHealth;
    _useAiCoach = settings.useAiCoach;
    _proxyUrlController = TextEditingController(text: settings.proxyBaseUrl);
    _installId = settings.anonymousInstallId;

    // Load saved reminder time, default 21:00
    final saved = settings.reminderTime;
    if (saved != null) {
      try {
        final parts = saved.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (_) {
        _reminderTime = const TimeOfDay(hour: 21, minute: 0);
      }
    } else {
      _reminderTime = const TimeOfDay(hour: 21, minute: 0);
    }
  }

  @override
  void dispose() {
    _proxyUrlController.dispose();
    super.dispose();
  }

  void _toggleAiCoach(bool value) {
    setState(() => _useAiCoach = value);
    ref.read(settingsRepoProvider).useAiCoach = value;
  }

  Future<void> _testConnection() async {
    setState(() => _isTestingConnection = true);
    final url = _proxyUrlController.text.trim();
    ref.read(settingsRepoProvider).proxyBaseUrl = url;
    final engine = LlmCoachEngine();
    final ok = await engine.checkHealth(url);
    if (!mounted) return;
    setState(() => _isTestingConnection = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Proxy online! Connection verified (/health returned 200).'
              : 'Could not connect to proxy at $url (/health unreachable).',
        ),
        backgroundColor:
            ok ? Colors.green.shade700 : Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Set daily check-in reminder',
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
      final timeStr =
          '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(settingsRepoProvider).reminderTime = timeStr;
      await NotificationService.scheduleDaily(picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily reminder set for ${picked.format(context)}.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleHealthSource(bool value) async {
    setState(() {
      _useRealHealth = value;
    });
    ref.read(settingsRepoProvider).useRealHealth = value;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Health Connect enabled. Data will sync from device.'
                : 'Using simulated 30-day health metrics.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportData() async {
    final checkinRepo = ref.read(checkinRepoProvider);
    final sessionRepo = ref.read(sessionRepoProvider);

    final checkins = await checkinRepo.recent(90);
    final sessions = await sessionRepo.recent(90);

    final exportObj = {
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': '1.0.0+1',
      'checkins': checkins
          .map((c) => {
                'id': c.id,
                'timestamp': c.ts.toIso8601String(),
                'mood': c.mood,
                'energy': c.energy,
                'stress': c.stress,
                'note': c.note,
                'tags': c.tags,
              })
          .toList(),
      'sessions': sessions
          .map((s) => {
                'id': s.id,
                'technique_id': s.techniqueId,
                'started_at': s.startedAt.toIso8601String(),
                'completed_at': s.completedAt.toIso8601String(),
                'pre_mood': s.preMood,
                'post_mood': s.postMood,
                'inputs': s.inputs,
              })
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportObj);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exported Data (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy to Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied data to clipboard!')),
              );
            },
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Local Data?'),
        content: const Text(
          'This will permanently delete all your logged check-ins, exercise sessions, and local metrics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(dbProvider).deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: const CrisisFab(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          children: [
            // Section: Data Sources
            Text(
              'DATA & INTEGRATIONS',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Use Real Health Connect Data'),
                    subtitle: Text(
                      _useRealHealth
                          ? 'Syncing sleep, HRV, steps & resting HR via Android Health Connect.'
                          : 'Using reproducible 30-day simulated health metrics.',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    value: _useRealHealth,
                    onChanged: _toggleHealthSource,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text('Daily Check-In Reminder'),
                    subtitle: Text(
                      'Tap to change · currently ${_reminderTime.format(context)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    trailing: Text(
                      _reminderTime.format(context),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: _pickReminderTime,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Section: AI Coach
            Text(
              'AI COACH (BETA PROXY)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable AI CuraCoach (Beta)'),
                    subtitle: Text(
                      _useAiCoach
                          ? 'Streams responses via SSE proxy backend with local fallback.'
                          : 'Using offline deterministic rule-based coach.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    value: _useAiCoach,
                    onChanged: _toggleAiCoach,
                  ),
                  if (_useAiCoach) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proxy Base URL',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Emulator: http://10.0.2.2:2000 | Desktop: http://localhost:2000',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _proxyUrlController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. http://10.0.2.2:2000',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    ref.read(settingsRepoProvider).proxyBaseUrl =
                                        val.trim();
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(64, 40),
                                ),
                                onPressed: _isTestingConnection
                                    ? null
                                    : _testConnection,
                                child: _isTestingConnection
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Test'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            children: [
                              ActionChip(
                                label: const Text('10.0.2.2:2000',
                                    style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  _proxyUrlController.text =
                                      'http://10.0.2.2:2000';
                                  ref
                                      .read(settingsRepoProvider)
                                      .proxyBaseUrl = 'http://10.0.2.2:2000';
                                },
                              ),
                              ActionChip(
                                label: const Text('localhost:2000',
                                    style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  _proxyUrlController.text =
                                      'http://localhost:2000';
                                  ref
                                      .read(settingsRepoProvider)
                                      .proxyBaseUrl = 'http://localhost:2000';
                                },
                              ),
                              ActionChip(
                                label: const Text('10.0.2.2:3000',
                                    style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  _proxyUrlController.text =
                                      'http://10.0.2.2:3000';
                                  ref
                                      .read(settingsRepoProvider)
                                      .proxyBaseUrl = 'http://10.0.2.2:3000';
                                },
                              ),
                              ActionChip(
                                label: const Text('localhost:3000',
                                    style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  _proxyUrlController.text =
                                      'http://localhost:3000';
                                  ref
                                      .read(settingsRepoProvider)
                                      .proxyBaseUrl = 'http://localhost:3000';
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Anonymous Install ID'),
                    subtitle: Text(
                      _installId,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 11),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy Install ID',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _installId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Copied Install ID to clipboard')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Section: Privacy & Storage
            Text(
              'DATA MANAGEMENT',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Export Data as JSON'),
                    subtitle: const Text('View or copy your logged history'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _exportData,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.delete_forever_outlined, color: cs.error),
                    title: Text(
                      'Clear All Local Data',
                      style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Wipe local database and reset'),
                    trailing: Icon(Icons.chevron_right, color: cs.error),
                    onTap: _confirmClearData,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Section: Clinical & Safety Disclaimer
            Text(
              'SAFETY & DISCLAIMER',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: cs.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Wellness Prototype Notice',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'CuraTrail is an interactive wellness and self-reflection prototype. It is not a certified medical device and does not diagnose, treat, or prevent any mental health condition.\n\nAll readiness scores, stress indexes, and recommended techniques are educational heuristics and should never replace clinical advice from a licensed medical professional.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'CuraTrail v1.0.0 (Build 1) • Offline First',
                style: theme.textTheme.labelSmall?.copyWith(color: cs.outline),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
