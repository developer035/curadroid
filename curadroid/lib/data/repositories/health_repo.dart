import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart' as db;
import '../health/health_source.dart';
import '../health/mock_health_source.dart';
import '../health/health_connect_source.dart';
import '../../domain/models/health_day.dart' as domain;
import 'checkin_repo.dart' show dbProvider;
import 'settings_repo.dart';

final healthSourceProvider = Provider<HealthSource>((ref) {
  final settings = ref.watch(settingsRepoProvider);
  return settings.useRealHealth ? HealthConnectSource() : MockHealthSource();
});

final healthRepoProvider = Provider<HealthRepository>(
  (ref) => HealthRepository(
    ref.watch(dbProvider),
    ref.watch(healthSourceProvider),
  ),
);

class HealthRepository {
  final db.AppDatabase _db;
  final HealthSource _source;

  HealthRepository(this._db, this._source);

  /// Sync from source and cache to DB.
  Future<void> sync() async {
    final days = await _source.fetchHistory(30);
    for (final d in days) {
      await _db.healthDao.upsertDay(_toCompanion(d));
    }
    final today = await _source.fetchToday();
    if (today != null) {
      await _db.healthDao.upsertDay(_toCompanion(today));
    }
  }

  /// Read cached days from DB.
  Future<List<domain.HealthDay>> recentDays(int days) async {
    final rows = await _db.healthDao.recentDays(days);
    return rows.map(_toDomain).toList();
  }

  Future<domain.HealthDay?> today() async {
    final row = await _db.healthDao.dayFor(DateTime.now());
    return row == null ? null : _toDomain(row);
  }

  Future<HealthPermissionStatus> requestPermissions() =>
      _source.requestPermissions();

  Future<void> deleteAll() => _db.healthDao.deleteAll();

  db.HealthDaysCompanion _toCompanion(domain.HealthDay d) {
    final key =
        '${d.date.year.toString().padLeft(4, '0')}-${d.date.month.toString().padLeft(2, '0')}-${d.date.day.toString().padLeft(2, '0')}';
    return db.HealthDaysCompanion(
      date: Value(key),
      sleepMin: Value(d.sleepMin),
      hrvMs: Value(d.hrvMs),
      restingHr: Value(d.restingHr),
      steps: Value(d.steps),
      source: Value(d.source),
    );
  }

  domain.HealthDay _toDomain(db.HealthDay row) => domain.HealthDay(
        date: DateTime.parse(row.date),
        sleepMin: row.sleepMin,
        hrvMs: row.hrvMs,
        restingHr: row.restingHr,
        steps: row.steps,
        source: row.source,
      );
}
