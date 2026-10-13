import '../../../domain/models/health_day.dart';

enum HealthPermissionStatus { granted, denied, unavailable }

abstract class HealthSource {
  /// Request permissions. Returns the resulting status.
  Future<HealthPermissionStatus> requestPermissions();

  /// Current permission status without requesting.
  Future<HealthPermissionStatus> checkPermissions();

  /// Fetch health data for the last [days] days (excl. today).
  /// Returns one [HealthDay] per local date, may have null fields.
  Future<List<HealthDay>> fetchHistory(int days);

  /// Fetch today's health data.
  Future<HealthDay?> fetchToday();
}
