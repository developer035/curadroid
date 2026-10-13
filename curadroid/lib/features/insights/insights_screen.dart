import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/crisis_fab.dart';
import '../../data/repositories/checkin_repo.dart';
import '../../data/repositories/health_repo.dart';
import '../../domain/models/checkin.dart';
import '../../domain/models/health_day.dart';
import '../../domain/usecases/compute_readiness.dart';
import '../../domain/usecases/compute_streak.dart';

// ─── State / Provider ─────────────────────────────────────────────────────────

class InsightsState {
  final int days;
  final List<CheckIn> checkins;
  final List<HealthDay> healthDays;
  final int streak;
  final List<String> topDrivers;
  final bool loading;
  final String? error;

  const InsightsState({
    this.days = 7,
    this.checkins = const [],
    this.healthDays = const [],
    this.streak = 0,
    this.topDrivers = const [],
    this.loading = true,
    this.error,
  });

  InsightsState copyWith({
    int? days,
    List<CheckIn>? checkins,
    List<HealthDay>? healthDays,
    int? streak,
    List<String>? topDrivers,
    bool? loading,
    String? error,
  }) =>
      InsightsState(
        days: days ?? this.days,
        checkins: checkins ?? this.checkins,
        healthDays: healthDays ?? this.healthDays,
        streak: streak ?? this.streak,
        topDrivers: topDrivers ?? this.topDrivers,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}

final insightsNotifierProvider =
    StateNotifierProvider<InsightsNotifier, InsightsState>(
  (ref) => InsightsNotifier(
    ref.watch(checkinRepoProvider),
    ref.watch(healthRepoProvider),
  ),
);

class InsightsNotifier extends StateNotifier<InsightsState> {
  final CheckinRepository _checkinRepo;
  final HealthRepository _healthRepo;
  static const _computeReadiness = ComputeReadiness();
  static const _computeStreak = ComputeStreak();

  InsightsNotifier(this._checkinRepo, this._healthRepo)
      : super(const InsightsState()) {
    load(7);
  }

  Future<void> load(int days) async {
    state = state.copyWith(loading: true, days: days, error: null);
    try {
      final checkins = await _checkinRepo.recent(days);
      final healthDays = await _healthRepo.recentDays(days);
      final allCheckins = await _checkinRepo.all();
      final streak = _computeStreak(allCheckins);

      // Compute top drivers from the period's health days
      final history = await _healthRepo.recentDays(30);
      final baseline = history
          .where((d) => !_isToday(d.date))
          .toList();

      // Collect unique driver messages across all days in the period
      final driverSet = <String>{};
      for (final hd in healthDays) {
        final r = _computeReadiness(today: hd, history: baseline);
        driverSet.addAll(r.drivers);
      }
      final topDrivers = driverSet.take(3).toList();

      state = state.copyWith(
        checkins: checkins,
        healthDays: healthDays,
        streak: streak,
        topDrivers: topDrivers,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsNotifierProvider);
    final notifier = ref.read(insightsNotifierProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppTokens.space8),
            child: CrisisFab(),
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Text('Error: ${state.error}',
                      style: TextStyle(color: cs.error)))
              : ListView(
                  padding: const EdgeInsets.all(AppTokens.space16),
                  children: [
                    // Period selector
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 7, label: Text('7 days')),
                        ButtonSegment(value: 30, label: Text('30 days')),
                      ],
                      selected: {state.days},
                      onSelectionChanged: (s) => notifier.load(s.first),
                    ),
                    const SizedBox(height: AppTokens.space24),

                    // Streak badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.space16,
                            vertical: AppTokens.space8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: AppTokens.space8),
                              Text(
                                '${state.streak} day streak',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space24),

                    // Mood + Readiness dual-line chart
                    if (state.checkins.isNotEmpty) ...[
                      Text('Mood & Readiness',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppTokens.space4),
                      Row(
                        children: [
                          _LegendDot(color: cs.primary),
                          const SizedBox(width: 4),
                          Text('Mood', style: theme.textTheme.bodySmall),
                          const SizedBox(width: AppTokens.space12),
                          _LegendDot(color: cs.tertiary, dashed: true),
                          const SizedBox(width: 4),
                          Text('Readiness',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space8),
                      _DualLineChart(
                        checkins: state.checkins,
                        healthDays: state.healthDays,
                      ),
                      const SizedBox(height: AppTokens.space24),
                    ],

                    // Sleep bar chart
                    if (state.healthDays.isNotEmpty) ...[
                      Text('Sleep (minutes)',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppTokens.space12),
                      _SleepChart(days: state.healthDays),
                      const SizedBox(height: AppTokens.space24),

                      Text('HRV (ms)', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppTokens.space12),
                      _HrvChart(days: state.healthDays),
                      const SizedBox(height: AppTokens.space24),
                    ],

                    // Top Drivers section
                    if (state.topDrivers.isNotEmpty) ...[
                      Text('Top Drivers This Period',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppTokens.space8),
                      ...state.topDrivers.map((driver) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppTokens.space8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: cs.primary),
                                const SizedBox(width: AppTokens.space8),
                                Expanded(
                                  child: Text(
                                    driver,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: AppTokens.space24),
                    ],

                    // Empty state
                    if (state.checkins.isEmpty && state.healthDays.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: AppTokens.space48),
                            Icon(Icons.bar_chart,
                                size: 64, color: cs.outlineVariant),
                            const SizedBox(height: AppTokens.space16),
                            Text(
                              'No data yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Check in daily to see trends here.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}

// ─── Legend dot ───────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final bool dashed;
  const _LegendDot({required this.color, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 3,
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : color,
        border: dashed ? Border(bottom: BorderSide(color: color, width: 2)) : null,
      ),
      child: dashed
          ? null
          : null,
    );
  }
}

// ─── Dual line chart (mood + readiness) ───────────────────────────────────────

class _DualLineChart extends StatelessWidget {
  final List<CheckIn> checkins;
  final List<HealthDay> healthDays;
  const _DualLineChart({required this.checkins, required this.healthDays});

  static const _computeReadiness = ComputeReadiness();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final sorted = List<CheckIn>.from(checkins)
      ..sort((a, b) => a.ts.compareTo(b.ts));

    // Build mood spots
    final moodSpots = sorted.asMap().entries.map((e) {
      // Normalize mood (1-5) to 0-100 scale for same axis
      return FlSpot(e.key.toDouble(), e.value.mood.toDouble() * 20.0);
    }).toList();

    // Build readiness spots aligned to same x-axis indices
    final readinessSpots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final day = sorted[i];
      final matchingHealth = healthDays.where((h) {
        return h.date.year == day.ts.year &&
            h.date.month == day.ts.month &&
            h.date.day == day.ts.day;
      }).firstOrNull;
      if (matchingHealth != null) {
        final r = _computeReadiness(
          today: matchingHealth,
          history: healthDays.where((h) => h.date.isBefore(day.ts)).toList(),
        );
        readinessSpots.add(FlSpot(i.toDouble(), r.score.toDouble()));
      }
    }

    return SizedBox(
      height: 180,
      child: Semantics(
        label: 'Dual line chart: mood (solid) and readiness (dashed) over time. '
            'Both plotted on a 0–100 scale.',
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: cs.outlineVariant.withOpacity(0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (v, _) => Text(
                    v.round().toString(),
                    style: TextStyle(
                        fontSize: 10, color: cs.onSurfaceVariant),
                  ),
                ),
              ),
              bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              // Mood line (solid)
              LineChartBarData(
                spots: moodSpots,
                isCurved: true,
                color: cs.primary,
                barWidth: 2.5,
                dotData: FlDotData(
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 4,
                    color: cs.primary,
                    strokeColor: cs.surface,
                    strokeWidth: 2,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: cs.primary.withOpacity(0.08),
                ),
              ),
              // Readiness line (dashed)
              if (readinessSpots.isNotEmpty)
                LineChartBarData(
                  spots: readinessSpots,
                  isCurved: true,
                  color: cs.tertiary,
                  barWidth: 2,
                  dashArray: [6, 4],
                  dotData: const FlDotData(show: false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sleep bar chart ──────────────────────────────────────────────────────────

class _SleepChart extends StatelessWidget {
  final List<HealthDay> days;
  const _SleepChart({required this.days});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sorted = List<HealthDay>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));

    final bars = sorted.asMap().entries.map((e) {
      final sleep = e.value.sleepMin ?? 0;
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: sleep.toDouble(),
          color: sleep >= 420 ? cs.primary : cs.error,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ]);
    }).toList();

    return SizedBox(
      height: 150,
      child: Semantics(
        label: 'Sleep duration bar chart. Red bars are below 7 hours.',
        child: BarChart(
          BarChartData(
            barGroups: bars,
            maxY: 540,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 120,
              getDrawingHorizontalLine: (_) => FlLine(
                color: cs.outlineVariant.withOpacity(0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              leftTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(
                y: 480,
                color: cs.primary.withOpacity(0.5),
                strokeWidth: 1.5,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  labelResolver: (_) => '8h',
                  style: TextStyle(fontSize: 10, color: cs.primary),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── HRV bar chart ────────────────────────────────────────────────────────────

class _HrvChart extends StatelessWidget {
  final List<HealthDay> days;
  const _HrvChart({required this.days});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sorted = List<HealthDay>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));

    final bars = sorted.asMap().entries.map((e) {
      final hrv = e.value.hrvMs ?? 0.0;
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: hrv,
          color: cs.tertiary,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ]);
    }).toList();

    return SizedBox(
      height: 150,
      child: Semantics(
        label: 'HRV bar chart in milliseconds.',
        child: BarChart(
          BarChartData(
            barGroups: bars,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: cs.outlineVariant.withOpacity(0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              leftTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }
}
