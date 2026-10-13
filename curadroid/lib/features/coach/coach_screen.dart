import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/crisis_fab.dart';
import '../../data/repositories/settings_repo.dart';
import '../../domain/models/coach_message.dart';
import '../exercises/catalog.dart';
import 'coach_notifier.dart';

class CoachScreen extends ConsumerStatefulWidget {
  final int? checkinId;
  const CoachScreen({super.key, this.checkinId});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAiConsent();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _checkAiConsent() {
    final settings = ref.read(settingsRepoProvider);
    if (settings.useAiCoach && !settings.hasAiConsent) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('AI Coach Consent'),
            ],
          ),
          content: const Text(
            'CuraCoach can use an AI assistant to personalize suggestions based on your check-in summaries.\n\n• Your data stays private (anonymized summary only).\n• No raw journals or PII are sent.\n• CuraCoach is for wellness reflection, not clinical diagnosis or emergency medical care.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(settingsRepoProvider).useAiCoach = false;
              },
              child: const Text('Use Scripted Coach'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref
                    .read(coachNotifierProvider(widget.checkinId).notifier)
                    .grantConsent();
              },
              child: const Text('Agree & Continue'),
            ),
          ],
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppTokens.durationMedium,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitCustomMessage(CoachNotifier notifier) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      notifier.reply(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coachNotifierProvider(widget.checkinId));
    final notifier =
        ref.read(coachNotifierProvider(widget.checkinId).notifier);

    // Auto-scroll and handle crisis navigation trigger
    ref.listen<CoachSessionState>(
      coachNotifierProvider(widget.checkinId),
      (prev, next) {
        _scrollToBottom();
        if (next.crisisDetected && !(prev?.crisisDetected ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: const Text(
                'Crisis detected: We strongly recommend contacting 988 or professional support now.',
              ),
              action: SnackBarAction(
                label: 'Get Help',
                textColor: Colors.white,
                onPressed: () => context.push(AppRoutes.crisis),
              ),
              duration: const Duration(seconds: 10),
            ),
          );
        }
      },
    );

    if (state.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lastMsg = state.messages.isNotEmpty ? state.messages.last : null;
    final chips = lastMsg?.chips;
    final techniqueId = state.messages
        .where((m) => m.techniqueId != null)
        .map((m) => m.techniqueId!)
        .lastOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CuraCoach'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.today),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppTokens.space8),
            child: CrisisFab(),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI disclaimer badge
          Padding(
            padding: const EdgeInsets.only(
              top: AppTokens.space8,
              bottom: AppTokens.space4,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI-generated • Not clinical advice',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppTokens.space16),
              itemCount: state.messages.length + (state.isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (state.isTyping && i == state.messages.length) {
                  return _TypingBubble();
                }
                return _MessageBubble(message: state.messages[i]);
              },
            ),
          ),

          // Technique card
          if (techniqueId != null) ...[
            const Divider(height: 1),
            _TechniqueCard(
              techniqueId: techniqueId,
              onTap: () async {
                final result = await context.push<Map<String, int?>>(
                    '${AppRoutes.exercise}/$techniqueId');
                if (result != null && mounted) {
                  notifier.closeSession(
                    preMood: result['preMood'],
                    postMood: result['postMood'],
                  );
                }
              },
            ),
          ],

          // Quick-reply chips
          if (chips != null && chips.isNotEmpty && !state.isTyping) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppTokens.space12),
              child: Wrap(
                spacing: AppTokens.space8,
                runSpacing: AppTokens.space8,
                children: chips.map((chip) {
                  return ActionChip(
                    label: Text(chip),
                    onPressed: () {
                      if (chip == 'Find Help Now' ||
                          chip == 'Get Immediate Help' ||
                          chip == 'Find Helplines') {
                        context.push(AppRoutes.crisis);
                      } else {
                        notifier.reply(chip);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],

          // Bottom text input bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.space8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Share a thought or reflection...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.space16,
                          vertical: AppTokens.space12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitCustomMessage(notifier),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: state.isTyping
                        ? null
                        : () => _submitCustomMessage(notifier),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final CoachMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isCoach = message.sender == MessageSender.coach;
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: isCoach ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: AppTokens.space12),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        decoration: BoxDecoration(
          color: isCoach ? cs.surfaceContainerLow : cs.primaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppTokens.radiusL),
            topRight: const Radius.circular(AppTokens.radiusL),
            bottomLeft: Radius.circular(isCoach ? 0 : AppTokens.radiusL),
            bottomRight: Radius.circular(isCoach ? AppTokens.radiusL : 0),
          ),
        ),
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCoach ? cs.onSurface : cs.onPrimaryContainer,
              ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTokens.space12),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTokens.radiusL),
            topRight: Radius.circular(AppTokens.radiusL),
            bottomRight: Radius.circular(AppTokens.radiusL),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (_controller.value - i * 0.2).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8 + 4 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final String techniqueId;
  final VoidCallback onTap;
  const _TechniqueCard({required this.techniqueId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final technique = techniqueById(techniqueId);
    if (technique == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(AppTokens.radiusM),
              ),
              child: Icon(Icons.self_improvement, color: cs.primary, size: 22),
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Try: ${technique.title}',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    technique.whyNow,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size(56, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
