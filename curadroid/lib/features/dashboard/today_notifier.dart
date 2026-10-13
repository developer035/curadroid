import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/checkin_repo.dart';
import '../../data/repositories/health_repo.dart';
import '../../domain/models/checkin.dart';
import '../../domain/models/readiness.dart';
import '../../domain/usecases/compute_readiness.dart';
import '../../domain/usecases/pick_technique.dart';

class TodayState {
  final Readiness? readiness;
  final CheckIn? todayCheckin;
  final String suggestedTechniqueId;
  final bool loading;
  final String? error;

  const TodayState({
    this.readiness,
    this.todayCheckin,
    this.suggestedTechniqueId = 'grounding_54321',
    this.loading = true,
    this.error,
  });

  TodayState copyWith({
    Readiness? readiness,
    CheckIn? todayCheckin,
    String? suggestedTechniqueId,
    bool? loading,
    String? error,
  }) =>
      TodayState(
        readiness: readiness ?? this.readiness,
        todayCheckin: todayCheckin ?? this.todayCheckin,
        suggestedTechniqueId:
            suggestedTechniqueId ?? this.suggestedTechniqueId,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}

final todayNotifierProvider =
    StateNotifierProvider<TodayNotifier, TodayState>(
  (ref) => TodayNotifier(
    ref.watch(checkinRepoProvider),
    ref.watch(healthRepoProvider),
  ),
);

class TodayNotifier extends StateNotifier<TodayState> {
  final CheckinRepository _checkinRepo;
  final HealthRepository _healthRepo;
  static const _computeReadiness = ComputeReadiness();
  static const _pickTechnique = PickTechnique();

  TodayNotifier(this._checkinRepo, this._healthRepo)
      : super(const TodayState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _healthRepo.sync();
      final history = await _healthRepo.recentDays(30);
      final todayHealth = await _healthRepo.today();
      final todayCheckin = await _checkinRepo.todayFirst();

      // Exclude today from baseline
      final baseline = history
          .where((d) => !_isToday(d.date))
          .toList();

      final readiness = _computeReadiness(
        today: todayHealth,
        history: baseline,
        todayCheckin: todayCheckin,
      );

      final techniqueId = _pickTechnique(
        readiness: readiness,
        checkin: todayCheckin,
      );

      state = state.copyWith(
        readiness: readiness,
        todayCheckin: todayCheckin,
        suggestedTechniqueId: techniqueId,
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
