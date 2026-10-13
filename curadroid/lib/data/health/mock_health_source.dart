import 'dart:math' as math;
import '../../domain/models/health_day.dart';
import 'health_source.dart';

/// Seeded 30-day generator that produces realistic-looking health data.
/// Uses seed 42 for reproducibility — data looks the same every app run.
class MockHealthSource implements HealthSource {
  static const int _seed = 42;

  @override
  Future<HealthPermissionStatus> requestPermissions() async =>
      HealthPermissionStatus.granted;

  @override
  Future<HealthPermissionStatus> checkPermissions() async =>
      HealthPermissionStatus.granted;

  @override
  Future<List<HealthDay>> fetchHistory(int days) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate IO
    final rng = math.Random(_seed);
    final today = DateTime.now();
    final result = <HealthDay>[];

    for (int i = days; i >= 1; i--) {
      final date = today.subtract(Duration(days: i));
      result.add(_generate(date, rng, roughPatch: i >= 18 && i <= 22));
    }
    return result;
  }

  @override
  Future<HealthDay?> fetchToday() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final rng = math.Random(_seed + 999);
    return _generate(DateTime.now(), rng, roughPatch: false);
  }

  HealthDay _generate(DateTime date, math.Random rng,
      {required bool roughPatch}) {
    // Day-of-week rhythm: weekends slightly worse sleep
    final isWeekend = date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;

    // Base ranges
    final sleepBase = roughPatch ? 360 : (isWeekend ? 430 : 460);
    final hrvBase = roughPatch ? 42.0 : 55.0;
    final rhrBase = roughPatch ? 68 : 63;
    final stepsBase = roughPatch ? 4000 : 7500;

    return HealthDay(
      date: date,
      sleepMin: sleepBase + rng.nextInt(isWeekend ? 60 : 80) - (isWeekend ? 40 : 30),
      hrvMs: (hrvBase + (rng.nextDouble() * 20 - 10)).clamp(30.0, 80.0),
      restingHr: (rhrBase + rng.nextInt(10) - 4).clamp(48, 85),
      steps: stepsBase + rng.nextInt(5000) - 2000,
      source: 'mock',
    );
  }
}
