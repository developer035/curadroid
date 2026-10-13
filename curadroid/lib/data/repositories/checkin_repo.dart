import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../../domain/models/checkin.dart' as domain;

final checkinRepoProvider = Provider<CheckinRepository>(
  (ref) => CheckinRepository(ref.watch(dbProvider)),
);

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase());

class CheckinRepository {
  final AppDatabase _db;
  CheckinRepository(this._db);

  Future<int> save(domain.CheckIn c) => _db.checkinDao.insertCheckin(
        CheckinsCompanion(
          ts: Value(c.ts),
          mood: Value(c.mood),
          energy: Value(c.energy),
          stress: Value(c.stress),
          note: Value(c.note),
          tags: Value(jsonEncode(c.tags)),
        ),
      );

  Future<List<domain.CheckIn>> recent(int days) async {
    final rows = await _db.checkinDao.recentCheckins(days);
    return rows.map(_toDomain).toList();
  }

  Future<List<domain.CheckIn>> all() async {
    final rows = await _db.checkinDao.allCheckins();
    return rows.map(_toDomain).toList();
  }

  Future<domain.CheckIn?> todayFirst() async {
    final rows = await _db.checkinDao.todayCheckins();
    return rows.isEmpty ? null : _toDomain(rows.first);
  }

  Future<void> deleteAll() => _db.checkinDao.deleteAll();

  domain.CheckIn _toDomain(Checkin row) => domain.CheckIn(
        id: row.id,
        ts: row.ts,
        mood: row.mood,
        energy: row.energy,
        stress: row.stress,
        note: row.note,
        tags: List<String>.from(jsonDecode(row.tags) as List),
      );
}
