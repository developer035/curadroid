import 'package:health/health.dart';
import '../../domain/models/health_day.dart';
import 'health_source.dart';

/// Real Health Connect source. Permissions are requested only when the user
/// explicitly taps "Connect" in Settings. Never called until then.
class HealthConnectSource implements HealthSource {
  static final _health = Health();

  static const _types = [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.STEPS,
  ];

  @override
  Future<HealthPermissionStatus> requestPermissions() async {
    try {
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _types.map((_) => HealthDataAccess.READ).toList(),
      );
      return granted
          ? HealthPermissionStatus.granted
          : HealthPermissionStatus.denied;
    } catch (_) {
      return HealthPermissionStatus.unavailable;
    }
  }

  @override
  Future<HealthPermissionStatus> checkPermissions() async {
    try {
      final ok = await _health.hasPermissions(_types) ?? false;
      return ok ? HealthPermissionStatus.granted : HealthPermissionStatus.denied;
    } catch (_) {
      return HealthPermissionStatus.unavailable;
    }
  }

  @override
  Future<List<HealthDay>> fetchHistory(int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return _fetchRange(start, end);
  }

  @override
  Future<HealthDay?> fetchToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final days = await _fetchRange(start, now);
    return days.isNotEmpty ? days.last : null;
  }

  Future<List<HealthDay>> _fetchRange(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: _types,
      );

      // Group by local date
      final map = <String, _DayAccumulator>{};
      for (final point in data) {
        final key = _dateKey(point.dateFrom);
        map.putIfAbsent(key, () => _DayAccumulator(point.dateFrom));
        map[key]!.add(point);
      }

      return map.entries.map((e) => e.value.toHealthDay()).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      return [];
    }
  }

  static String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
}

class _DayAccumulator {
  final DateTime date;
  int? sleepMin;
  double? hrvMs;
  int? restingHr;
  int steps = 0;

  _DayAccumulator(this.date);

  void add(HealthDataPoint p) {
    final val = (p.value as NumericHealthValue).numericValue;
    switch (p.type) {
      case HealthDataType.SLEEP_SESSION:
        sleepMin = (sleepMin ?? 0) +
            p.dateTo.difference(p.dateFrom).inMinutes;
      case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
        hrvMs = val.toDouble();
      case HealthDataType.RESTING_HEART_RATE:
        restingHr = val.round();
      case HealthDataType.STEPS:
        steps += val.round();
      default:
        break;
    }
  }

  HealthDay toHealthDay() => HealthDay(
        date: date,
        sleepMin: sleepMin,
        hrvMs: hrvMs,
        restingHr: restingHr,
        steps: steps > 0 ? steps : null,
        source: 'health_connect',
      );
}
