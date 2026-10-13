import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/crisis_fab.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/app_card.dart';
import '../../domain/models/readiness.dart';
import '../exercises/catalog.dart';
import 'today_notifier.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todayNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CuraTrail'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppTokens.space8),
            child: CrisisFab(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ref.read(todayNotifierProvider.notifier).load,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppTokens.space16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting
                  Text(
                    '${_greeting()} 👋',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    'Here\'s your readiness for today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppTokens.space32),

                  // Score ring + stress chip
                  if (state.loading)
                    Center(child: SkeletonRing(size: 200))
                  else if (state.readiness != null)
                    _ReadinessCard(readiness: state.readiness!)
                  else
                    _EmptyReadiness(),

                  const SizedBox(height: AppTokens.space24),

                  // Check-in CTA
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.checkin),
                    icon: const Icon(Icons.edit_note),
                    label: Text(
                      state.todayCheckin == null
                          ? 'Check In Now'
                          : 'Update Check-In',
                    ),
                  ),

                  const SizedBox(height: AppTokens.space24),

                  // Suggested technique card
                  if (!state.loading) ...[
                    Text(
                      'Suggested for you',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.space8),
                    _TechniqueCard(
                      techniqueId: state.suggestedTechniqueId,
                    ),
                  ],

                  const SizedBox(height: AppTokens.space24),

                  // Disclaimer
                  Text(
                    'CuraTrail is wellness support, not medical treatment.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.space32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  final Readiness readiness;
  const _ReadinessCard({required this.readiness});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Center(
          child: ScoreRing(
            score: readiness.score,
            size: 200,
            label: readiness.bandLabel,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        // Stress chip
        Center(
          child: Chip(
            avatar: Icon(
              Icons.monitor_heart_outlined,
              color: readiness.stressIndex >= 70
                  ? cs.error
                  : readiness.stressIndex >= 40
                      ? cs.tertiary
                      : cs.primary,
              size: 18,
            ),
            label: Text('Stress: ${readiness.stressLabel}'),
            backgroundColor: cs.surfaceContainerLow,
          ),
        ),
        if (readiness.drivers.isNotEmpty) ...[
          const SizedBox(height: AppTokens.space12),
          ...readiness.drivers.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space4),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: cs.primary),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      d,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyReadiness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          Icon(Icons.data_usage, size: 64, color: cs.outlineVariant),
          const SizedBox(height: AppTokens.space16),
          Text(
            'No health data yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          Text(
            'Connect Health Connect in Settings to see your readiness.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final String techniqueId;
  const _TechniqueCard({required this.techniqueId});

  @override
  Widget build(BuildContext context) {
    final technique = techniqueById(techniqueId);
    if (technique == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return AppCard(
      onTap: () => context.push('${AppRoutes.exercise}/$techniqueId'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppTokens.radiusM),
            ),
            child: Icon(
              Icons.self_improvement,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(technique.title,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${technique.minutes} min · ${technique.kindLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
