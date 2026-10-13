import 'package:drift/drift.dart';

// ─── checkins ───────────────────────────────────────────────────────────────
class Checkins extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get ts => dateTime()();
  IntColumn get mood => integer()();    // 1..5
  IntColumn get energy => integer()();  // 1..5
  IntColumn get stress => integer()();  // 1..5
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON array
}

// ─── health_days ─────────────────────────────────────────────────────────────
class HealthDays extends Table {
  TextColumn get date => text()();  // yyyy-MM-dd, PK
  IntColumn get sleepMin => integer().nullable()();
  RealColumn get hrvMs => real().nullable()();
  IntColumn get restingHr => integer().nullable()();
  IntColumn get steps => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant('mock'))();

  @override
  Set<Column> get primaryKey => {date};
}

// ─── sessions ────────────────────────────────────────────────────────────────
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get techniqueId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get preMood => integer().nullable()();
  IntColumn get postMood => integer().nullable()();
  TextColumn get inputs => text().withDefault(const Constant('{}'))(); // JSON map
}
