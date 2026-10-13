import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'health_dao.g.dart';

@DriftAccessor(tables: [HealthDays])
class HealthDao extends DatabaseAccessor<AppDatabase> with _$HealthDaoMixin {
  HealthDao(super.db);

  Future<void> upsertDay(HealthDaysCompanion entry) =>
      into(healthDays).insertOnConflictUpdate(entry);

  Future<List<HealthDay>> recentDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr =
        '${cutoff.year.toString().padLeft(4, '0')}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    return (select(healthDays)
          ..where((t) => t.date.isBiggerOrEqualValue(cutoffStr))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<HealthDay?> dayFor(DateTime date) {
    final key =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return (select(healthDays)..where((t) => t.date.equals(key)))
        .getSingleOrNull();
  }

  Future<void> deleteAll() => delete(healthDays).go();
}
