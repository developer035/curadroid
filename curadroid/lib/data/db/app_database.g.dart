// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CheckinsTable extends Checkins with TableInfo<$CheckinsTable, Checkin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<int> stress = GeneratedColumn<int>(
    'stress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ts,
    mood,
    energy,
    stress,
    note,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<Checkin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('stress')) {
      context.handle(
        _stressMeta,
        stress.isAcceptableOrUnknown(data['stress']!, _stressMeta),
      );
    } else if (isInserting) {
      context.missing(_stressMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Checkin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Checkin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ts'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      stress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stress'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
    );
  }

  @override
  $CheckinsTable createAlias(String alias) {
    return $CheckinsTable(attachedDatabase, alias);
  }
}

class Checkin extends DataClass implements Insertable<Checkin> {
  final int id;
  final DateTime ts;
  final int mood;
  final int energy;
  final int stress;
  final String? note;
  final String tags;
  const Checkin({
    required this.id,
    required this.ts,
    required this.mood,
    required this.energy,
    required this.stress,
    this.note,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ts'] = Variable<DateTime>(ts);
    map['mood'] = Variable<int>(mood);
    map['energy'] = Variable<int>(energy);
    map['stress'] = Variable<int>(stress);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['tags'] = Variable<String>(tags);
    return map;
  }

  CheckinsCompanion toCompanion(bool nullToAbsent) {
    return CheckinsCompanion(
      id: Value(id),
      ts: Value(ts),
      mood: Value(mood),
      energy: Value(energy),
      stress: Value(stress),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: Value(tags),
    );
  }

  factory Checkin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Checkin(
      id: serializer.fromJson<int>(json['id']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      mood: serializer.fromJson<int>(json['mood']),
      energy: serializer.fromJson<int>(json['energy']),
      stress: serializer.fromJson<int>(json['stress']),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ts': serializer.toJson<DateTime>(ts),
      'mood': serializer.toJson<int>(mood),
      'energy': serializer.toJson<int>(energy),
      'stress': serializer.toJson<int>(stress),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<String>(tags),
    };
  }

  Checkin copyWith({
    int? id,
    DateTime? ts,
    int? mood,
    int? energy,
    int? stress,
    Value<String?> note = const Value.absent(),
    String? tags,
  }) => Checkin(
    id: id ?? this.id,
    ts: ts ?? this.ts,
    mood: mood ?? this.mood,
    energy: energy ?? this.energy,
    stress: stress ?? this.stress,
    note: note.present ? note.value : this.note,
    tags: tags ?? this.tags,
  );
  Checkin copyWithCompanion(CheckinsCompanion data) {
    return Checkin(
      id: data.id.present ? data.id.value : this.id,
      ts: data.ts.present ? data.ts.value : this.ts,
      mood: data.mood.present ? data.mood.value : this.mood,
      energy: data.energy.present ? data.energy.value : this.energy,
      stress: data.stress.present ? data.stress.value : this.stress,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Checkin(')
          ..write('id: $id, ')
          ..write('ts: $ts, ')
          ..write('mood: $mood, ')
          ..write('energy: $energy, ')
          ..write('stress: $stress, ')
          ..write('note: $note, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ts, mood, energy, stress, note, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Checkin &&
          other.id == this.id &&
          other.ts == this.ts &&
          other.mood == this.mood &&
          other.energy == this.energy &&
          other.stress == this.stress &&
          other.note == this.note &&
          other.tags == this.tags);
}

class CheckinsCompanion extends UpdateCompanion<Checkin> {
  final Value<int> id;
  final Value<DateTime> ts;
  final Value<int> mood;
  final Value<int> energy;
  final Value<int> stress;
  final Value<String?> note;
  final Value<String> tags;
  const CheckinsCompanion({
    this.id = const Value.absent(),
    this.ts = const Value.absent(),
    this.mood = const Value.absent(),
    this.energy = const Value.absent(),
    this.stress = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
  });
  CheckinsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime ts,
    required int mood,
    required int energy,
    required int stress,
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
  }) : ts = Value(ts),
       mood = Value(mood),
       energy = Value(energy),
       stress = Value(stress);
  static Insertable<Checkin> custom({
    Expression<int>? id,
    Expression<DateTime>? ts,
    Expression<int>? mood,
    Expression<int>? energy,
    Expression<int>? stress,
    Expression<String>? note,
    Expression<String>? tags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ts != null) 'ts': ts,
      if (mood != null) 'mood': mood,
      if (energy != null) 'energy': energy,
      if (stress != null) 'stress': stress,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
    });
  }

  CheckinsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? ts,
    Value<int>? mood,
    Value<int>? energy,
    Value<int>? stress,
    Value<String?>? note,
    Value<String>? tags,
  }) {
    return CheckinsCompanion(
      id: id ?? this.id,
      ts: ts ?? this.ts,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (stress.present) {
      map['stress'] = Variable<int>(stress.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckinsCompanion(')
          ..write('id: $id, ')
          ..write('ts: $ts, ')
          ..write('mood: $mood, ')
          ..write('energy: $energy, ')
          ..write('stress: $stress, ')
          ..write('note: $note, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class $HealthDaysTable extends HealthDays
    with TableInfo<$HealthDaysTable, HealthDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepMinMeta = const VerificationMeta(
    'sleepMin',
  );
  @override
  late final GeneratedColumn<int> sleepMin = GeneratedColumn<int>(
    'sleep_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrvMsMeta = const VerificationMeta('hrvMs');
  @override
  late final GeneratedColumn<double> hrvMs = GeneratedColumn<double>(
    'hrv_ms',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restingHrMeta = const VerificationMeta(
    'restingHr',
  );
  @override
  late final GeneratedColumn<int> restingHr = GeneratedColumn<int>(
    'resting_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mock'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    sleepMin,
    hrvMs,
    restingHr,
    steps,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sleep_min')) {
      context.handle(
        _sleepMinMeta,
        sleepMin.isAcceptableOrUnknown(data['sleep_min']!, _sleepMinMeta),
      );
    }
    if (data.containsKey('hrv_ms')) {
      context.handle(
        _hrvMsMeta,
        hrvMs.isAcceptableOrUnknown(data['hrv_ms']!, _hrvMsMeta),
      );
    }
    if (data.containsKey('resting_hr')) {
      context.handle(
        _restingHrMeta,
        restingHr.isAcceptableOrUnknown(data['resting_hr']!, _restingHrMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  HealthDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthDay(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      sleepMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_min'],
      ),
      hrvMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_ms'],
      ),
      restingHr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resting_hr'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $HealthDaysTable createAlias(String alias) {
    return $HealthDaysTable(attachedDatabase, alias);
  }
}

class HealthDay extends DataClass implements Insertable<HealthDay> {
  final String date;
  final int? sleepMin;
  final double? hrvMs;
  final int? restingHr;
  final int? steps;
  final String source;
  const HealthDay({
    required this.date,
    this.sleepMin,
    this.hrvMs,
    this.restingHr,
    this.steps,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || sleepMin != null) {
      map['sleep_min'] = Variable<int>(sleepMin);
    }
    if (!nullToAbsent || hrvMs != null) {
      map['hrv_ms'] = Variable<double>(hrvMs);
    }
    if (!nullToAbsent || restingHr != null) {
      map['resting_hr'] = Variable<int>(restingHr);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<int>(steps);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  HealthDaysCompanion toCompanion(bool nullToAbsent) {
    return HealthDaysCompanion(
      date: Value(date),
      sleepMin: sleepMin == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepMin),
      hrvMs: hrvMs == null && nullToAbsent
          ? const Value.absent()
          : Value(hrvMs),
      restingHr: restingHr == null && nullToAbsent
          ? const Value.absent()
          : Value(restingHr),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
      source: Value(source),
    );
  }

  factory HealthDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthDay(
      date: serializer.fromJson<String>(json['date']),
      sleepMin: serializer.fromJson<int?>(json['sleepMin']),
      hrvMs: serializer.fromJson<double?>(json['hrvMs']),
      restingHr: serializer.fromJson<int?>(json['restingHr']),
      steps: serializer.fromJson<int?>(json['steps']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'sleepMin': serializer.toJson<int?>(sleepMin),
      'hrvMs': serializer.toJson<double?>(hrvMs),
      'restingHr': serializer.toJson<int?>(restingHr),
      'steps': serializer.toJson<int?>(steps),
      'source': serializer.toJson<String>(source),
    };
  }

  HealthDay copyWith({
    String? date,
    Value<int?> sleepMin = const Value.absent(),
    Value<double?> hrvMs = const Value.absent(),
    Value<int?> restingHr = const Value.absent(),
    Value<int?> steps = const Value.absent(),
    String? source,
  }) => HealthDay(
    date: date ?? this.date,
    sleepMin: sleepMin.present ? sleepMin.value : this.sleepMin,
    hrvMs: hrvMs.present ? hrvMs.value : this.hrvMs,
    restingHr: restingHr.present ? restingHr.value : this.restingHr,
    steps: steps.present ? steps.value : this.steps,
    source: source ?? this.source,
  );
  HealthDay copyWithCompanion(HealthDaysCompanion data) {
    return HealthDay(
      date: data.date.present ? data.date.value : this.date,
      sleepMin: data.sleepMin.present ? data.sleepMin.value : this.sleepMin,
      hrvMs: data.hrvMs.present ? data.hrvMs.value : this.hrvMs,
      restingHr: data.restingHr.present ? data.restingHr.value : this.restingHr,
      steps: data.steps.present ? data.steps.value : this.steps,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthDay(')
          ..write('date: $date, ')
          ..write('sleepMin: $sleepMin, ')
          ..write('hrvMs: $hrvMs, ')
          ..write('restingHr: $restingHr, ')
          ..write('steps: $steps, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, sleepMin, hrvMs, restingHr, steps, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthDay &&
          other.date == this.date &&
          other.sleepMin == this.sleepMin &&
          other.hrvMs == this.hrvMs &&
          other.restingHr == this.restingHr &&
          other.steps == this.steps &&
          other.source == this.source);
}

class HealthDaysCompanion extends UpdateCompanion<HealthDay> {
  final Value<String> date;
  final Value<int?> sleepMin;
  final Value<double?> hrvMs;
  final Value<int?> restingHr;
  final Value<int?> steps;
  final Value<String> source;
  final Value<int> rowid;
  const HealthDaysCompanion({
    this.date = const Value.absent(),
    this.sleepMin = const Value.absent(),
    this.hrvMs = const Value.absent(),
    this.restingHr = const Value.absent(),
    this.steps = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthDaysCompanion.insert({
    required String date,
    this.sleepMin = const Value.absent(),
    this.hrvMs = const Value.absent(),
    this.restingHr = const Value.absent(),
    this.steps = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<HealthDay> custom({
    Expression<String>? date,
    Expression<int>? sleepMin,
    Expression<double>? hrvMs,
    Expression<int>? restingHr,
    Expression<int>? steps,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (sleepMin != null) 'sleep_min': sleepMin,
      if (hrvMs != null) 'hrv_ms': hrvMs,
      if (restingHr != null) 'resting_hr': restingHr,
      if (steps != null) 'steps': steps,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthDaysCompanion copyWith({
    Value<String>? date,
    Value<int?>? sleepMin,
    Value<double?>? hrvMs,
    Value<int?>? restingHr,
    Value<int?>? steps,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return HealthDaysCompanion(
      date: date ?? this.date,
      sleepMin: sleepMin ?? this.sleepMin,
      hrvMs: hrvMs ?? this.hrvMs,
      restingHr: restingHr ?? this.restingHr,
      steps: steps ?? this.steps,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (sleepMin.present) {
      map['sleep_min'] = Variable<int>(sleepMin.value);
    }
    if (hrvMs.present) {
      map['hrv_ms'] = Variable<double>(hrvMs.value);
    }
    if (restingHr.present) {
      map['resting_hr'] = Variable<int>(restingHr.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthDaysCompanion(')
          ..write('date: $date, ')
          ..write('sleepMin: $sleepMin, ')
          ..write('hrvMs: $hrvMs, ')
          ..write('restingHr: $restingHr, ')
          ..write('steps: $steps, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _techniqueIdMeta = const VerificationMeta(
    'techniqueId',
  );
  @override
  late final GeneratedColumn<String> techniqueId = GeneratedColumn<String>(
    'technique_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preMoodMeta = const VerificationMeta(
    'preMood',
  );
  @override
  late final GeneratedColumn<int> preMood = GeneratedColumn<int>(
    'pre_mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postMoodMeta = const VerificationMeta(
    'postMood',
  );
  @override
  late final GeneratedColumn<int> postMood = GeneratedColumn<int>(
    'post_mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inputsMeta = const VerificationMeta('inputs');
  @override
  late final GeneratedColumn<String> inputs = GeneratedColumn<String>(
    'inputs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    techniqueId,
    startedAt,
    completedAt,
    preMood,
    postMood,
    inputs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('technique_id')) {
      context.handle(
        _techniqueIdMeta,
        techniqueId.isAcceptableOrUnknown(
          data['technique_id']!,
          _techniqueIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_techniqueIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('pre_mood')) {
      context.handle(
        _preMoodMeta,
        preMood.isAcceptableOrUnknown(data['pre_mood']!, _preMoodMeta),
      );
    }
    if (data.containsKey('post_mood')) {
      context.handle(
        _postMoodMeta,
        postMood.isAcceptableOrUnknown(data['post_mood']!, _postMoodMeta),
      );
    }
    if (data.containsKey('inputs')) {
      context.handle(
        _inputsMeta,
        inputs.isAcceptableOrUnknown(data['inputs']!, _inputsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      techniqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technique_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      preMood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pre_mood'],
      ),
      postMood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}post_mood'],
      ),
      inputs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inputs'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String techniqueId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int? preMood;
  final int? postMood;
  final String inputs;
  const Session({
    required this.id,
    required this.techniqueId,
    required this.startedAt,
    required this.completedAt,
    this.preMood,
    this.postMood,
    required this.inputs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['technique_id'] = Variable<String>(techniqueId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || preMood != null) {
      map['pre_mood'] = Variable<int>(preMood);
    }
    if (!nullToAbsent || postMood != null) {
      map['post_mood'] = Variable<int>(postMood);
    }
    map['inputs'] = Variable<String>(inputs);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      techniqueId: Value(techniqueId),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      preMood: preMood == null && nullToAbsent
          ? const Value.absent()
          : Value(preMood),
      postMood: postMood == null && nullToAbsent
          ? const Value.absent()
          : Value(postMood),
      inputs: Value(inputs),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      techniqueId: serializer.fromJson<String>(json['techniqueId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      preMood: serializer.fromJson<int?>(json['preMood']),
      postMood: serializer.fromJson<int?>(json['postMood']),
      inputs: serializer.fromJson<String>(json['inputs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'techniqueId': serializer.toJson<String>(techniqueId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'preMood': serializer.toJson<int?>(preMood),
      'postMood': serializer.toJson<int?>(postMood),
      'inputs': serializer.toJson<String>(inputs),
    };
  }

  Session copyWith({
    int? id,
    String? techniqueId,
    DateTime? startedAt,
    DateTime? completedAt,
    Value<int?> preMood = const Value.absent(),
    Value<int?> postMood = const Value.absent(),
    String? inputs,
  }) => Session(
    id: id ?? this.id,
    techniqueId: techniqueId ?? this.techniqueId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    preMood: preMood.present ? preMood.value : this.preMood,
    postMood: postMood.present ? postMood.value : this.postMood,
    inputs: inputs ?? this.inputs,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      techniqueId: data.techniqueId.present
          ? data.techniqueId.value
          : this.techniqueId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      preMood: data.preMood.present ? data.preMood.value : this.preMood,
      postMood: data.postMood.present ? data.postMood.value : this.postMood,
      inputs: data.inputs.present ? data.inputs.value : this.inputs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('techniqueId: $techniqueId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('preMood: $preMood, ')
          ..write('postMood: $postMood, ')
          ..write('inputs: $inputs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    techniqueId,
    startedAt,
    completedAt,
    preMood,
    postMood,
    inputs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.techniqueId == this.techniqueId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.preMood == this.preMood &&
          other.postMood == this.postMood &&
          other.inputs == this.inputs);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> techniqueId;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<int?> preMood;
  final Value<int?> postMood;
  final Value<String> inputs;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.techniqueId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.preMood = const Value.absent(),
    this.postMood = const Value.absent(),
    this.inputs = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String techniqueId,
    required DateTime startedAt,
    required DateTime completedAt,
    this.preMood = const Value.absent(),
    this.postMood = const Value.absent(),
    this.inputs = const Value.absent(),
  }) : techniqueId = Value(techniqueId),
       startedAt = Value(startedAt),
       completedAt = Value(completedAt);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? techniqueId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? preMood,
    Expression<int>? postMood,
    Expression<String>? inputs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (techniqueId != null) 'technique_id': techniqueId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (preMood != null) 'pre_mood': preMood,
      if (postMood != null) 'post_mood': postMood,
      if (inputs != null) 'inputs': inputs,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? techniqueId,
    Value<DateTime>? startedAt,
    Value<DateTime>? completedAt,
    Value<int?>? preMood,
    Value<int?>? postMood,
    Value<String>? inputs,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      techniqueId: techniqueId ?? this.techniqueId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      preMood: preMood ?? this.preMood,
      postMood: postMood ?? this.postMood,
      inputs: inputs ?? this.inputs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (techniqueId.present) {
      map['technique_id'] = Variable<String>(techniqueId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (preMood.present) {
      map['pre_mood'] = Variable<int>(preMood.value);
    }
    if (postMood.present) {
      map['post_mood'] = Variable<int>(postMood.value);
    }
    if (inputs.present) {
      map['inputs'] = Variable<String>(inputs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('techniqueId: $techniqueId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('preMood: $preMood, ')
          ..write('postMood: $postMood, ')
          ..write('inputs: $inputs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CheckinsTable checkins = $CheckinsTable(this);
  late final $HealthDaysTable healthDays = $HealthDaysTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final CheckinDao checkinDao = CheckinDao(this as AppDatabase);
  late final HealthDao healthDao = HealthDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    checkins,
    healthDays,
    sessions,
  ];
}

typedef $$CheckinsTableCreateCompanionBuilder = CheckinsCompanion Function({
  Value<int> id,
  required DateTime ts,
  required int mood,
  required int energy,
  required int stress,
  Value<String?> note,
  Value<String> tags,
});
typedef $$CheckinsTableUpdateCompanionBuilder = CheckinsCompanion Function({
  Value<int> id,
  Value<DateTime> ts,
  Value<int> mood,
  Value<int> energy,
  Value<int> stress,
  Value<String?> note,
  Value<String> tags,
});

class $$CheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$CheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckinsTable,
          Checkin,
          $$CheckinsTableFilterComposer,
          $$CheckinsTableOrderingComposer,
          $$CheckinsTableAnnotationComposer,
          $$CheckinsTableCreateCompanionBuilder,
          $$CheckinsTableUpdateCompanionBuilder,
          (Checkin, BaseReferences<_$AppDatabase, $CheckinsTable, Checkin>),
          Checkin,
          PrefetchHooks Function()
        > {
  $$CheckinsTableTableManager(_$AppDatabase db, $CheckinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<int> stress = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> tags = const Value.absent(),
              }) => CheckinsCompanion(
                id: id,
                ts: ts,
                mood: mood,
                energy: energy,
                stress: stress,
                note: note,
                tags: tags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime ts,
                required int mood,
                required int energy,
                required int stress,
                Value<String?> note = const Value.absent(),
                Value<String> tags = const Value.absent(),
              }) => CheckinsCompanion.insert(
                id: id,
                ts: ts,
                mood: mood,
                energy: energy,
                stress: stress,
                note: note,
                tags: tags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckinsTable, Checkin>(table),
                  BaseReferences<_$AppDatabase, $CheckinsTable, Checkin>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckinsTable,
      Checkin,
      $$CheckinsTableFilterComposer,
      $$CheckinsTableOrderingComposer,
      $$CheckinsTableAnnotationComposer,
      $$CheckinsTableCreateCompanionBuilder,
      $$CheckinsTableUpdateCompanionBuilder,
      (Checkin, BaseReferences<_$AppDatabase, $CheckinsTable, Checkin>),
      Checkin,
      PrefetchHooks Function()
    >;
typedef $$HealthDaysTableCreateCompanionBuilder = HealthDaysCompanion Function({
  required String date,
  Value<int?> sleepMin,
  Value<double?> hrvMs,
  Value<int?> restingHr,
  Value<int?> steps,
  Value<String> source,
  Value<int> rowid,
});
typedef $$HealthDaysTableUpdateCompanionBuilder = HealthDaysCompanion Function({
  Value<String> date,
  Value<int?> sleepMin,
  Value<double?> hrvMs,
  Value<int?> restingHr,
  Value<int?> steps,
  Value<String> source,
  Value<int> rowid,
});

class $$HealthDaysTableFilterComposer
    extends Composer<_$AppDatabase, $HealthDaysTable> {
  $$HealthDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepMin => $composableBuilder(
    column: $table.sleepMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvMs => $composableBuilder(
    column: $table.hrvMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restingHr => $composableBuilder(
    column: $table.restingHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthDaysTable> {
  $$HealthDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepMin => $composableBuilder(
    column: $table.sleepMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvMs => $composableBuilder(
    column: $table.hrvMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restingHr => $composableBuilder(
    column: $table.restingHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthDaysTable> {
  $$HealthDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get sleepMin =>
      $composableBuilder(column: $table.sleepMin, builder: (column) => column);

  GeneratedColumn<double> get hrvMs =>
      $composableBuilder(column: $table.hrvMs, builder: (column) => column);

  GeneratedColumn<int> get restingHr =>
      $composableBuilder(column: $table.restingHr, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$HealthDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthDaysTable,
          HealthDay,
          $$HealthDaysTableFilterComposer,
          $$HealthDaysTableOrderingComposer,
          $$HealthDaysTableAnnotationComposer,
          $$HealthDaysTableCreateCompanionBuilder,
          $$HealthDaysTableUpdateCompanionBuilder,
          (
            HealthDay,
            BaseReferences<_$AppDatabase, $HealthDaysTable, HealthDay>,
          ),
          HealthDay,
          PrefetchHooks Function()
        > {
  $$HealthDaysTableTableManager(_$AppDatabase db, $HealthDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int?> sleepMin = const Value.absent(),
                Value<double?> hrvMs = const Value.absent(),
                Value<int?> restingHr = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthDaysCompanion(
                date: date,
                sleepMin: sleepMin,
                hrvMs: hrvMs,
                restingHr: restingHr,
                steps: steps,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int?> sleepMin = const Value.absent(),
                Value<double?> hrvMs = const Value.absent(),
                Value<int?> restingHr = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthDaysCompanion.insert(
                date: date,
                sleepMin: sleepMin,
                hrvMs: hrvMs,
                restingHr: restingHr,
                steps: steps,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HealthDaysTable, HealthDay>(table),
                  BaseReferences<_$AppDatabase, $HealthDaysTable, HealthDay>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthDaysTable,
      HealthDay,
      $$HealthDaysTableFilterComposer,
      $$HealthDaysTableOrderingComposer,
      $$HealthDaysTableAnnotationComposer,
      $$HealthDaysTableCreateCompanionBuilder,
      $$HealthDaysTableUpdateCompanionBuilder,
      (HealthDay, BaseReferences<_$AppDatabase, $HealthDaysTable, HealthDay>),
      HealthDay,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required String techniqueId,
  required DateTime startedAt,
  required DateTime completedAt,
  Value<int?> preMood,
  Value<int?> postMood,
  Value<String> inputs,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String> techniqueId,
  Value<DateTime> startedAt,
  Value<DateTime> completedAt,
  Value<int?> preMood,
  Value<int?> postMood,
  Value<String> inputs,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preMood => $composableBuilder(
    column: $table.preMood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postMood => $composableBuilder(
    column: $table.postMood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputs => $composableBuilder(
    column: $table.inputs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preMood => $composableBuilder(
    column: $table.preMood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postMood => $composableBuilder(
    column: $table.postMood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputs => $composableBuilder(
    column: $table.inputs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get techniqueId => $composableBuilder(
    column: $table.techniqueId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preMood =>
      $composableBuilder(column: $table.preMood, builder: (column) => column);

  GeneratedColumn<int> get postMood =>
      $composableBuilder(column: $table.postMood, builder: (column) => column);

  GeneratedColumn<String> get inputs =>
      $composableBuilder(column: $table.inputs, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> techniqueId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int?> preMood = const Value.absent(),
                Value<int?> postMood = const Value.absent(),
                Value<String> inputs = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                techniqueId: techniqueId,
                startedAt: startedAt,
                completedAt: completedAt,
                preMood: preMood,
                postMood: postMood,
                inputs: inputs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String techniqueId,
                required DateTime startedAt,
                required DateTime completedAt,
                Value<int?> preMood = const Value.absent(),
                Value<int?> postMood = const Value.absent(),
                Value<String> inputs = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                techniqueId: techniqueId,
                startedAt: startedAt,
                completedAt: completedAt,
                preMood: preMood,
                postMood: postMood,
                inputs: inputs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, Session>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db, _db.checkins);
  $$HealthDaysTableTableManager get healthDays =>
      $$HealthDaysTableTableManager(_db, _db.healthDays);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
