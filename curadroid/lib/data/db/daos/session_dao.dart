import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<int> insertSession(SessionsCompanion entry) =>
      into(sessions).insert(entry);

  Future<List<Session>> recentSessions(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(sessions)
          ..where((t) => t.startedAt.isBiggerThanValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Future<List<Session>> allSessions() =>
      (select(sessions)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();

  Future<void> deleteAll() => delete(sessions).go();
}
