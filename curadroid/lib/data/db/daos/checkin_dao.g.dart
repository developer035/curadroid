// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_dao.dart';

// ignore_for_file: type=lint
mixin _$CheckinDaoMixin on DatabaseAccessor<AppDatabase> {
  $CheckinsTable get checkins => attachedDatabase.checkins;
  CheckinDaoManager get managers => CheckinDaoManager(this);
}

class CheckinDaoManager {
  final _$CheckinDaoMixin _db;
  CheckinDaoManager(this._db);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db.attachedDatabase, _db.checkins);
}
