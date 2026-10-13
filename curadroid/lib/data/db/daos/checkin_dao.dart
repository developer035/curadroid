import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'checkin_dao.g.dart';

@DriftAccessor(tables: [Checkins])
class CheckinDao extends DatabaseAccessor<AppDatabase> with _$CheckinDaoMixin {
  CheckinDao(super.db);

  /// Insert a check-in and return its id.
  Future<int> insertCheckin(CheckinsCompanion entry) =>
      into(checkins).insert(entry);

  /// All check-ins ordered newest first.
  Future<List<Checkin>> allCheckins() =>
      (select(checkins)..orderBy([(t) => OrderingTerm.desc(t.ts)])).get();

  /// Check-ins for the last [days] calendar days.
  Future<List<Checkin>> recentCheckins(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(checkins)
          ..where((t) => t.ts.isBiggerThanValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.ts)]))
        .get();
  }

  /// Today's check-ins (local date).
  Future<List<Checkin>> todayCheckins() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(checkins)
          ..where((t) =>
              t.ts.isBiggerThanValue(start) & t.ts.isSmallerThanValue(end)))
        .get();
  }

  Future<void> deleteAll() => delete(checkins).go();
}
