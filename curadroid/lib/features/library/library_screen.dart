import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/crisis_fab.dart';
import '../../domain/models/technique.dart';
import '../exercises/catalog.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  TechniqueKind? _selectedKind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final filteredTechniques = _selectedKind == null
        ? kTechniqueCatalog
        : kTechniqueCatalog.where((t) => t.kind == _selectedKind).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: const CrisisFab(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          children: [
            Text(
              'Evidence-based exercises to help regulate your nervous system, challenge cognitive distortions, and restore balance.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedKind == null,
                    onSelected: (_) => setState(() => _selectedKind = null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('Breathing'),
                    avatar: const Icon(Icons.air, size: 16),
                    selected: _selectedKind == TechniqueKind.breathing,
                    onSelected: (val) => setState(() => _selectedKind = val ? TechniqueKind.breathing : null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('Grounding'),
                    avatar: const Icon(Icons.spa_outlined, size: 16),
                    selected: _selectedKind == TechniqueKind.grounding,
                    onSelected: (val) => setState(() => _selectedKind = val ? TechniqueKind.grounding : null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('Cognitive (CBT)'),
                    avatar: const Icon(Icons.psychology_outlined, size: 16),
                    selected: _selectedKind == TechniqueKind.cognitive,
                    onSelected: (val) => setState(() => _selectedKind = val ? TechniqueKind.cognitive : null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('Behavioural'),
                    avatar: const Icon(Icons.bolt_outlined, size: 16),
                    selected: _selectedKind == TechniqueKind.behavioural,
                    onSelected: (val) => setState(() => _selectedKind = val ? TechniqueKind.behavioural : null),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // List of technique cards (or empty state)
            if (filteredTechniques.isEmpty)
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Column(
                    children: [
                      Icon(Icons.search_off,
                          size: 56, color: cs.outlineVariant),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No exercises in this category yet.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredTechniques.map((technique) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: () => context.push('${AppRoutes.exercise}/${technique.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  _iconForKind(technique.kind),
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      technique.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      technique.subtitle,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule, size: 12, color: cs.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${technique.minutes} min',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            technique.whyNow,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: technique.bestFor.map((trigger) {
                              return Chip(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                                label: Text(
                                  _labelForTrigger(trigger),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonalIcon(
                              onPressed: () => context.push('${AppRoutes.exercise}/${technique.id}'),
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Start'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 80), // Fab clearance
          ],
        ),
      ),
    );
  }

  IconData _iconForKind(TechniqueKind kind) {
    switch (kind) {
      case TechniqueKind.breathing:
        return Icons.air;
      case TechniqueKind.grounding:
        return Icons.spa_outlined;
      case TechniqueKind.cognitive:
        return Icons.psychology_outlined;
      case TechniqueKind.behavioural:
        return Icons.bolt_outlined;
    }
  }

  String _labelForTrigger(TechniqueTrigger trigger) {
    switch (trigger) {
      case TechniqueTrigger.highStress:
        return 'High Stress';
      case TechniqueTrigger.lowEnergy:
        return 'Low Energy';
      case TechniqueTrigger.worry:
        return 'Worry & Rumination';
      case TechniqueTrigger.poorSleep:
        return 'Bedtime / Wind Down';
      case TechniqueTrigger.general:
        return 'Everyday Focus';
    }
  }
}
