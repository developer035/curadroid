import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';
import 'daos/checkin_dao.dart';
import 'daos/health_dao.dart';
import 'daos/session_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Checkins, HealthDays, Sessions],
  daos: [CheckinDao, HealthDao, SessionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Indexes for performance
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_checkins_ts ON checkins (ts)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_sessions_started_at ON sessions (started_at)',
          );
        },
      );

  /// Delete everything (Settings screen)
  Future<void> deleteAllData() async {
    await delete(sessions).go();
    await delete(healthDays).go();
    await delete(checkins).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'curadroid.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
