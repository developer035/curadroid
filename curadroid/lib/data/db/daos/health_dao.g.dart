// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_dao.dart';

// ignore_for_file: type=lint
mixin _$HealthDaoMixin on DatabaseAccessor<AppDatabase> {
  $HealthDaysTable get healthDays => attachedDatabase.healthDays;
  HealthDaoManager get managers => HealthDaoManager(this);
}

class HealthDaoManager {
  final _$HealthDaoMixin _db;
  HealthDaoManager(this._db);
  $$HealthDaysTableTableManager get healthDays =>
      $$HealthDaysTableTableManager(_db.attachedDatabase, _db.healthDays);
}
