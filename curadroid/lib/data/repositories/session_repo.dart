import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../../domain/models/exercise_session.dart';
import 'checkin_repo.dart' show dbProvider;

final sessionRepoProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(dbProvider)),
);

class SessionRepository {
  final AppDatabase _db;
  SessionRepository(this._db);

  Future<int> save(ExerciseSession s) => _db.sessionDao.insertSession(
        SessionsCompanion(
          techniqueId: Value(s.techniqueId),
          startedAt: Value(s.startedAt),
          completedAt: Value(s.completedAt),
          preMood: Value(s.preMood),
          postMood: Value(s.postMood),
          inputs: Value(jsonEncode(s.inputs)),
        ),
      );

  Future<List<ExerciseSession>> recent(int days) async {
    final rows = await _db.sessionDao.recentSessions(days);
    return rows.map(_toDomain).toList();
  }

  Future<List<ExerciseSession>> all() async {
    final rows = await _db.sessionDao.allSessions();
    return rows.map(_toDomain).toList();
  }

  Future<void> deleteAll() => _db.sessionDao.deleteAll();

  ExerciseSession _toDomain(Session row) => ExerciseSession(
        id: row.id,
        techniqueId: row.techniqueId,
        startedAt: row.startedAt,
        completedAt: row.completedAt,
        preMood: row.preMood,
        postMood: row.postMood,
        inputs: Map<String, String>.from(
            jsonDecode(row.inputs) as Map),
      );
}
