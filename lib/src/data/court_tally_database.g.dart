// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'court_tally_database.dart';

// ignore_for_file: type=lint
class $RulesPresetsTable extends RulesPresets
    with TableInfo<$RulesPresetsTable, RulesPresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sportMeta = const VerificationMeta('sport');
  @override
  late final GeneratedColumn<String> sport = GeneratedColumn<String>(
    'sport',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsToWinMeta = const VerificationMeta(
    'unitsToWin',
  );
  @override
  late final GeneratedColumn<int> unitsToWin = GeneratedColumn<int>(
    'units_to_win',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsToWinGameMeta = const VerificationMeta(
    'pointsToWinGame',
  );
  @override
  late final GeneratedColumn<int> pointsToWinGame = GeneratedColumn<int>(
    'points_to_win_game',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winByMeta = const VerificationMeta('winBy');
  @override
  late final GeneratedColumn<int> winBy = GeneratedColumn<int>(
    'win_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointCapMeta = const VerificationMeta(
    'pointCap',
  );
  @override
  late final GeneratedColumn<int> pointCap = GeneratedColumn<int>(
    'point_cap',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gamesToWinSetMeta = const VerificationMeta(
    'gamesToWinSet',
  );
  @override
  late final GeneratedColumn<int> gamesToWinSet = GeneratedColumn<int>(
    'games_to_win_set',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tiebreakAtGamesMeta = const VerificationMeta(
    'tiebreakAtGames',
  );
  @override
  late final GeneratedColumn<int> tiebreakAtGames = GeneratedColumn<int>(
    'tiebreak_at_games',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tiebreakPointsMeta = const VerificationMeta(
    'tiebreakPoints',
  );
  @override
  late final GeneratedColumn<int> tiebreakPoints = GeneratedColumn<int>(
    'tiebreak_points',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    name,
    sport,
    unitsToWin,
    pointsToWinGame,
    winBy,
    pointCap,
    gamesToWinSet,
    tiebreakAtGames,
    tiebreakPoints,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<RulesPresetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sport')) {
      context.handle(
        _sportMeta,
        sport.isAcceptableOrUnknown(data['sport']!, _sportMeta),
      );
    } else if (isInserting) {
      context.missing(_sportMeta);
    }
    if (data.containsKey('units_to_win')) {
      context.handle(
        _unitsToWinMeta,
        unitsToWin.isAcceptableOrUnknown(
          data['units_to_win']!,
          _unitsToWinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitsToWinMeta);
    }
    if (data.containsKey('points_to_win_game')) {
      context.handle(
        _pointsToWinGameMeta,
        pointsToWinGame.isAcceptableOrUnknown(
          data['points_to_win_game']!,
          _pointsToWinGameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsToWinGameMeta);
    }
    if (data.containsKey('win_by')) {
      context.handle(
        _winByMeta,
        winBy.isAcceptableOrUnknown(data['win_by']!, _winByMeta),
      );
    } else if (isInserting) {
      context.missing(_winByMeta);
    }
    if (data.containsKey('point_cap')) {
      context.handle(
        _pointCapMeta,
        pointCap.isAcceptableOrUnknown(data['point_cap']!, _pointCapMeta),
      );
    }
    if (data.containsKey('games_to_win_set')) {
      context.handle(
        _gamesToWinSetMeta,
        gamesToWinSet.isAcceptableOrUnknown(
          data['games_to_win_set']!,
          _gamesToWinSetMeta,
        ),
      );
    }
    if (data.containsKey('tiebreak_at_games')) {
      context.handle(
        _tiebreakAtGamesMeta,
        tiebreakAtGames.isAcceptableOrUnknown(
          data['tiebreak_at_games']!,
          _tiebreakAtGamesMeta,
        ),
      );
    }
    if (data.containsKey('tiebreak_points')) {
      context.handle(
        _tiebreakPointsMeta,
        tiebreakPoints.isAcceptableOrUnknown(
          data['tiebreak_points']!,
          _tiebreakPointsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, version};
  @override
  RulesPresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RulesPresetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sport'],
      )!,
      unitsToWin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_to_win'],
      )!,
      pointsToWinGame: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_to_win_game'],
      )!,
      winBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}win_by'],
      )!,
      pointCap: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_cap'],
      ),
      gamesToWinSet: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}games_to_win_set'],
      ),
      tiebreakAtGames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tiebreak_at_games'],
      ),
      tiebreakPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tiebreak_points'],
      ),
    );
  }

  @override
  $RulesPresetsTable createAlias(String alias) {
    return $RulesPresetsTable(attachedDatabase, alias);
  }
}

class RulesPresetRow extends DataClass implements Insertable<RulesPresetRow> {
  final String id;
  final int version;
  final String name;
  final String sport;
  final int unitsToWin;
  final int pointsToWinGame;
  final int winBy;
  final int? pointCap;
  final int? gamesToWinSet;
  final int? tiebreakAtGames;
  final int? tiebreakPoints;
  const RulesPresetRow({
    required this.id,
    required this.version,
    required this.name,
    required this.sport,
    required this.unitsToWin,
    required this.pointsToWinGame,
    required this.winBy,
    this.pointCap,
    this.gamesToWinSet,
    this.tiebreakAtGames,
    this.tiebreakPoints,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['name'] = Variable<String>(name);
    map['sport'] = Variable<String>(sport);
    map['units_to_win'] = Variable<int>(unitsToWin);
    map['points_to_win_game'] = Variable<int>(pointsToWinGame);
    map['win_by'] = Variable<int>(winBy);
    if (!nullToAbsent || pointCap != null) {
      map['point_cap'] = Variable<int>(pointCap);
    }
    if (!nullToAbsent || gamesToWinSet != null) {
      map['games_to_win_set'] = Variable<int>(gamesToWinSet);
    }
    if (!nullToAbsent || tiebreakAtGames != null) {
      map['tiebreak_at_games'] = Variable<int>(tiebreakAtGames);
    }
    if (!nullToAbsent || tiebreakPoints != null) {
      map['tiebreak_points'] = Variable<int>(tiebreakPoints);
    }
    return map;
  }

  RulesPresetsCompanion toCompanion(bool nullToAbsent) {
    return RulesPresetsCompanion(
      id: Value(id),
      version: Value(version),
      name: Value(name),
      sport: Value(sport),
      unitsToWin: Value(unitsToWin),
      pointsToWinGame: Value(pointsToWinGame),
      winBy: Value(winBy),
      pointCap: pointCap == null && nullToAbsent
          ? const Value.absent()
          : Value(pointCap),
      gamesToWinSet: gamesToWinSet == null && nullToAbsent
          ? const Value.absent()
          : Value(gamesToWinSet),
      tiebreakAtGames: tiebreakAtGames == null && nullToAbsent
          ? const Value.absent()
          : Value(tiebreakAtGames),
      tiebreakPoints: tiebreakPoints == null && nullToAbsent
          ? const Value.absent()
          : Value(tiebreakPoints),
    );
  }

  factory RulesPresetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RulesPresetRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      sport: serializer.fromJson<String>(json['sport']),
      unitsToWin: serializer.fromJson<int>(json['unitsToWin']),
      pointsToWinGame: serializer.fromJson<int>(json['pointsToWinGame']),
      winBy: serializer.fromJson<int>(json['winBy']),
      pointCap: serializer.fromJson<int?>(json['pointCap']),
      gamesToWinSet: serializer.fromJson<int?>(json['gamesToWinSet']),
      tiebreakAtGames: serializer.fromJson<int?>(json['tiebreakAtGames']),
      tiebreakPoints: serializer.fromJson<int?>(json['tiebreakPoints']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'name': serializer.toJson<String>(name),
      'sport': serializer.toJson<String>(sport),
      'unitsToWin': serializer.toJson<int>(unitsToWin),
      'pointsToWinGame': serializer.toJson<int>(pointsToWinGame),
      'winBy': serializer.toJson<int>(winBy),
      'pointCap': serializer.toJson<int?>(pointCap),
      'gamesToWinSet': serializer.toJson<int?>(gamesToWinSet),
      'tiebreakAtGames': serializer.toJson<int?>(tiebreakAtGames),
      'tiebreakPoints': serializer.toJson<int?>(tiebreakPoints),
    };
  }

  RulesPresetRow copyWith({
    String? id,
    int? version,
    String? name,
    String? sport,
    int? unitsToWin,
    int? pointsToWinGame,
    int? winBy,
    Value<int?> pointCap = const Value.absent(),
    Value<int?> gamesToWinSet = const Value.absent(),
    Value<int?> tiebreakAtGames = const Value.absent(),
    Value<int?> tiebreakPoints = const Value.absent(),
  }) => RulesPresetRow(
    id: id ?? this.id,
    version: version ?? this.version,
    name: name ?? this.name,
    sport: sport ?? this.sport,
    unitsToWin: unitsToWin ?? this.unitsToWin,
    pointsToWinGame: pointsToWinGame ?? this.pointsToWinGame,
    winBy: winBy ?? this.winBy,
    pointCap: pointCap.present ? pointCap.value : this.pointCap,
    gamesToWinSet: gamesToWinSet.present
        ? gamesToWinSet.value
        : this.gamesToWinSet,
    tiebreakAtGames: tiebreakAtGames.present
        ? tiebreakAtGames.value
        : this.tiebreakAtGames,
    tiebreakPoints: tiebreakPoints.present
        ? tiebreakPoints.value
        : this.tiebreakPoints,
  );
  RulesPresetRow copyWithCompanion(RulesPresetsCompanion data) {
    return RulesPresetRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      sport: data.sport.present ? data.sport.value : this.sport,
      unitsToWin: data.unitsToWin.present
          ? data.unitsToWin.value
          : this.unitsToWin,
      pointsToWinGame: data.pointsToWinGame.present
          ? data.pointsToWinGame.value
          : this.pointsToWinGame,
      winBy: data.winBy.present ? data.winBy.value : this.winBy,
      pointCap: data.pointCap.present ? data.pointCap.value : this.pointCap,
      gamesToWinSet: data.gamesToWinSet.present
          ? data.gamesToWinSet.value
          : this.gamesToWinSet,
      tiebreakAtGames: data.tiebreakAtGames.present
          ? data.tiebreakAtGames.value
          : this.tiebreakAtGames,
      tiebreakPoints: data.tiebreakPoints.present
          ? data.tiebreakPoints.value
          : this.tiebreakPoints,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RulesPresetRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('sport: $sport, ')
          ..write('unitsToWin: $unitsToWin, ')
          ..write('pointsToWinGame: $pointsToWinGame, ')
          ..write('winBy: $winBy, ')
          ..write('pointCap: $pointCap, ')
          ..write('gamesToWinSet: $gamesToWinSet, ')
          ..write('tiebreakAtGames: $tiebreakAtGames, ')
          ..write('tiebreakPoints: $tiebreakPoints')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    name,
    sport,
    unitsToWin,
    pointsToWinGame,
    winBy,
    pointCap,
    gamesToWinSet,
    tiebreakAtGames,
    tiebreakPoints,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RulesPresetRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.name == this.name &&
          other.sport == this.sport &&
          other.unitsToWin == this.unitsToWin &&
          other.pointsToWinGame == this.pointsToWinGame &&
          other.winBy == this.winBy &&
          other.pointCap == this.pointCap &&
          other.gamesToWinSet == this.gamesToWinSet &&
          other.tiebreakAtGames == this.tiebreakAtGames &&
          other.tiebreakPoints == this.tiebreakPoints);
}

class RulesPresetsCompanion extends UpdateCompanion<RulesPresetRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> name;
  final Value<String> sport;
  final Value<int> unitsToWin;
  final Value<int> pointsToWinGame;
  final Value<int> winBy;
  final Value<int?> pointCap;
  final Value<int?> gamesToWinSet;
  final Value<int?> tiebreakAtGames;
  final Value<int?> tiebreakPoints;
  final Value<int> rowid;
  const RulesPresetsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.sport = const Value.absent(),
    this.unitsToWin = const Value.absent(),
    this.pointsToWinGame = const Value.absent(),
    this.winBy = const Value.absent(),
    this.pointCap = const Value.absent(),
    this.gamesToWinSet = const Value.absent(),
    this.tiebreakAtGames = const Value.absent(),
    this.tiebreakPoints = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RulesPresetsCompanion.insert({
    required String id,
    required int version,
    required String name,
    required String sport,
    required int unitsToWin,
    required int pointsToWinGame,
    required int winBy,
    this.pointCap = const Value.absent(),
    this.gamesToWinSet = const Value.absent(),
    this.tiebreakAtGames = const Value.absent(),
    this.tiebreakPoints = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       version = Value(version),
       name = Value(name),
       sport = Value(sport),
       unitsToWin = Value(unitsToWin),
       pointsToWinGame = Value(pointsToWinGame),
       winBy = Value(winBy);
  static Insertable<RulesPresetRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? name,
    Expression<String>? sport,
    Expression<int>? unitsToWin,
    Expression<int>? pointsToWinGame,
    Expression<int>? winBy,
    Expression<int>? pointCap,
    Expression<int>? gamesToWinSet,
    Expression<int>? tiebreakAtGames,
    Expression<int>? tiebreakPoints,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (name != null) 'name': name,
      if (sport != null) 'sport': sport,
      if (unitsToWin != null) 'units_to_win': unitsToWin,
      if (pointsToWinGame != null) 'points_to_win_game': pointsToWinGame,
      if (winBy != null) 'win_by': winBy,
      if (pointCap != null) 'point_cap': pointCap,
      if (gamesToWinSet != null) 'games_to_win_set': gamesToWinSet,
      if (tiebreakAtGames != null) 'tiebreak_at_games': tiebreakAtGames,
      if (tiebreakPoints != null) 'tiebreak_points': tiebreakPoints,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RulesPresetsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? name,
    Value<String>? sport,
    Value<int>? unitsToWin,
    Value<int>? pointsToWinGame,
    Value<int>? winBy,
    Value<int?>? pointCap,
    Value<int?>? gamesToWinSet,
    Value<int?>? tiebreakAtGames,
    Value<int?>? tiebreakPoints,
    Value<int>? rowid,
  }) {
    return RulesPresetsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      unitsToWin: unitsToWin ?? this.unitsToWin,
      pointsToWinGame: pointsToWinGame ?? this.pointsToWinGame,
      winBy: winBy ?? this.winBy,
      pointCap: pointCap ?? this.pointCap,
      gamesToWinSet: gamesToWinSet ?? this.gamesToWinSet,
      tiebreakAtGames: tiebreakAtGames ?? this.tiebreakAtGames,
      tiebreakPoints: tiebreakPoints ?? this.tiebreakPoints,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sport.present) {
      map['sport'] = Variable<String>(sport.value);
    }
    if (unitsToWin.present) {
      map['units_to_win'] = Variable<int>(unitsToWin.value);
    }
    if (pointsToWinGame.present) {
      map['points_to_win_game'] = Variable<int>(pointsToWinGame.value);
    }
    if (winBy.present) {
      map['win_by'] = Variable<int>(winBy.value);
    }
    if (pointCap.present) {
      map['point_cap'] = Variable<int>(pointCap.value);
    }
    if (gamesToWinSet.present) {
      map['games_to_win_set'] = Variable<int>(gamesToWinSet.value);
    }
    if (tiebreakAtGames.present) {
      map['tiebreak_at_games'] = Variable<int>(tiebreakAtGames.value);
    }
    if (tiebreakPoints.present) {
      map['tiebreak_points'] = Variable<int>(tiebreakPoints.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesPresetsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('sport: $sport, ')
          ..write('unitsToWin: $unitsToWin, ')
          ..write('pointsToWinGame: $pointsToWinGame, ')
          ..write('winBy: $winBy, ')
          ..write('pointCap: $pointCap, ')
          ..write('gamesToWinSet: $gamesToWinSet, ')
          ..write('tiebreakAtGames: $tiebreakAtGames, ')
          ..write('tiebreakPoints: $tiebreakPoints, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, ParticipantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParticipantRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParticipantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParticipantRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class ParticipantRow extends DataClass implements Insertable<ParticipantRow> {
  final String id;
  final String name;
  final DateTime updatedAt;
  const ParticipantRow({
    required this.id,
    required this.name,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      name: Value(name),
      updatedAt: Value(updatedAt),
    );
  }

  factory ParticipantRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParticipantRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ParticipantRow copyWith({String? id, String? name, DateTime? updatedAt}) =>
      ParticipantRow(
        id: id ?? this.id,
        name: name ?? this.name,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ParticipantRow copyWithCompanion(ParticipantsCompanion data) {
    return ParticipantRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticipantRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.updatedAt == this.updatedAt);
}

class ParticipantsCompanion extends UpdateCompanion<ParticipantRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    required String id,
    required String name,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<ParticipantRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParticipantsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredMatchesTable extends StoredMatches
    with TableInfo<$StoredMatchesTable, StoredMatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredMatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowSchemaVersionMeta = const VerificationMeta(
    'rowSchemaVersion',
  );
  @override
  late final GeneratedColumn<int> rowSchemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetVersionMeta = const VerificationMeta(
    'presetVersion',
  );
  @override
  late final GeneratedColumn<int> presetVersion = GeneratedColumn<int>(
    'preset_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sportMeta = const VerificationMeta('sport');
  @override
  late final GeneratedColumn<String> sport = GeneratedColumn<String>(
    'sport',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideOneNameMeta = const VerificationMeta(
    'sideOneName',
  );
  @override
  late final GeneratedColumn<String> sideOneName = GeneratedColumn<String>(
    'side_one_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideTwoNameMeta = const VerificationMeta(
    'sideTwoName',
  );
  @override
  late final GeneratedColumn<String> sideTwoName = GeneratedColumn<String>(
    'side_two_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantSearchTextMeta =
      const VerificationMeta('participantSearchText');
  @override
  late final GeneratedColumn<String> participantSearchText =
      GeneratedColumn<String>(
        'participant_search_text',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
    'winner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastEventSequenceMeta = const VerificationMeta(
    'lastEventSequence',
  );
  @override
  late final GeneratedColumn<int> lastEventSequence = GeneratedColumn<int>(
    'last_event_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rowSchemaVersion,
    presetId,
    presetVersion,
    sport,
    sideOneName,
    sideTwoName,
    participantSearchText,
    status,
    winner,
    createdAt,
    updatedAt,
    completedAt,
    lastEventSequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredMatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _rowSchemaVersionMeta,
        rowSchemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _rowSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('preset_version')) {
      context.handle(
        _presetVersionMeta,
        presetVersion.isAcceptableOrUnknown(
          data['preset_version']!,
          _presetVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_presetVersionMeta);
    }
    if (data.containsKey('sport')) {
      context.handle(
        _sportMeta,
        sport.isAcceptableOrUnknown(data['sport']!, _sportMeta),
      );
    } else if (isInserting) {
      context.missing(_sportMeta);
    }
    if (data.containsKey('side_one_name')) {
      context.handle(
        _sideOneNameMeta,
        sideOneName.isAcceptableOrUnknown(
          data['side_one_name']!,
          _sideOneNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sideOneNameMeta);
    }
    if (data.containsKey('side_two_name')) {
      context.handle(
        _sideTwoNameMeta,
        sideTwoName.isAcceptableOrUnknown(
          data['side_two_name']!,
          _sideTwoNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sideTwoNameMeta);
    }
    if (data.containsKey('participant_search_text')) {
      context.handle(
        _participantSearchTextMeta,
        participantSearchText.isAcceptableOrUnknown(
          data['participant_search_text']!,
          _participantSearchTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantSearchTextMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('winner')) {
      context.handle(
        _winnerMeta,
        winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_event_sequence')) {
      context.handle(
        _lastEventSequenceMeta,
        lastEventSequence.isAcceptableOrUnknown(
          data['last_event_sequence']!,
          _lastEventSequenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredMatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredMatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rowSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      presetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preset_version'],
      )!,
      sport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sport'],
      )!,
      sideOneName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side_one_name'],
      )!,
      sideTwoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side_two_name'],
      )!,
      participantSearchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participant_search_text'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      winner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      lastEventSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_event_sequence'],
      )!,
    );
  }

  @override
  $StoredMatchesTable createAlias(String alias) {
    return $StoredMatchesTable(attachedDatabase, alias);
  }
}

class StoredMatchRow extends DataClass implements Insertable<StoredMatchRow> {
  final String id;
  final int rowSchemaVersion;
  final String presetId;
  final int presetVersion;
  final String sport;
  final String sideOneName;
  final String sideTwoName;
  final String participantSearchText;
  final String status;
  final String? winner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int lastEventSequence;
  const StoredMatchRow({
    required this.id,
    required this.rowSchemaVersion,
    required this.presetId,
    required this.presetVersion,
    required this.sport,
    required this.sideOneName,
    required this.sideTwoName,
    required this.participantSearchText,
    required this.status,
    this.winner,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.lastEventSequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schema_version'] = Variable<int>(rowSchemaVersion);
    map['preset_id'] = Variable<String>(presetId);
    map['preset_version'] = Variable<int>(presetVersion);
    map['sport'] = Variable<String>(sport);
    map['side_one_name'] = Variable<String>(sideOneName);
    map['side_two_name'] = Variable<String>(sideTwoName);
    map['participant_search_text'] = Variable<String>(participantSearchText);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || winner != null) {
      map['winner'] = Variable<String>(winner);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['last_event_sequence'] = Variable<int>(lastEventSequence);
    return map;
  }

  StoredMatchesCompanion toCompanion(bool nullToAbsent) {
    return StoredMatchesCompanion(
      id: Value(id),
      rowSchemaVersion: Value(rowSchemaVersion),
      presetId: Value(presetId),
      presetVersion: Value(presetVersion),
      sport: Value(sport),
      sideOneName: Value(sideOneName),
      sideTwoName: Value(sideTwoName),
      participantSearchText: Value(participantSearchText),
      status: Value(status),
      winner: winner == null && nullToAbsent
          ? const Value.absent()
          : Value(winner),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      lastEventSequence: Value(lastEventSequence),
    );
  }

  factory StoredMatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredMatchRow(
      id: serializer.fromJson<String>(json['id']),
      rowSchemaVersion: serializer.fromJson<int>(json['rowSchemaVersion']),
      presetId: serializer.fromJson<String>(json['presetId']),
      presetVersion: serializer.fromJson<int>(json['presetVersion']),
      sport: serializer.fromJson<String>(json['sport']),
      sideOneName: serializer.fromJson<String>(json['sideOneName']),
      sideTwoName: serializer.fromJson<String>(json['sideTwoName']),
      participantSearchText: serializer.fromJson<String>(
        json['participantSearchText'],
      ),
      status: serializer.fromJson<String>(json['status']),
      winner: serializer.fromJson<String?>(json['winner']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      lastEventSequence: serializer.fromJson<int>(json['lastEventSequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rowSchemaVersion': serializer.toJson<int>(rowSchemaVersion),
      'presetId': serializer.toJson<String>(presetId),
      'presetVersion': serializer.toJson<int>(presetVersion),
      'sport': serializer.toJson<String>(sport),
      'sideOneName': serializer.toJson<String>(sideOneName),
      'sideTwoName': serializer.toJson<String>(sideTwoName),
      'participantSearchText': serializer.toJson<String>(participantSearchText),
      'status': serializer.toJson<String>(status),
      'winner': serializer.toJson<String?>(winner),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'lastEventSequence': serializer.toJson<int>(lastEventSequence),
    };
  }

  StoredMatchRow copyWith({
    String? id,
    int? rowSchemaVersion,
    String? presetId,
    int? presetVersion,
    String? sport,
    String? sideOneName,
    String? sideTwoName,
    String? participantSearchText,
    String? status,
    Value<String?> winner = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    int? lastEventSequence,
  }) => StoredMatchRow(
    id: id ?? this.id,
    rowSchemaVersion: rowSchemaVersion ?? this.rowSchemaVersion,
    presetId: presetId ?? this.presetId,
    presetVersion: presetVersion ?? this.presetVersion,
    sport: sport ?? this.sport,
    sideOneName: sideOneName ?? this.sideOneName,
    sideTwoName: sideTwoName ?? this.sideTwoName,
    participantSearchText: participantSearchText ?? this.participantSearchText,
    status: status ?? this.status,
    winner: winner.present ? winner.value : this.winner,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    lastEventSequence: lastEventSequence ?? this.lastEventSequence,
  );
  StoredMatchRow copyWithCompanion(StoredMatchesCompanion data) {
    return StoredMatchRow(
      id: data.id.present ? data.id.value : this.id,
      rowSchemaVersion: data.rowSchemaVersion.present
          ? data.rowSchemaVersion.value
          : this.rowSchemaVersion,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      presetVersion: data.presetVersion.present
          ? data.presetVersion.value
          : this.presetVersion,
      sport: data.sport.present ? data.sport.value : this.sport,
      sideOneName: data.sideOneName.present
          ? data.sideOneName.value
          : this.sideOneName,
      sideTwoName: data.sideTwoName.present
          ? data.sideTwoName.value
          : this.sideTwoName,
      participantSearchText: data.participantSearchText.present
          ? data.participantSearchText.value
          : this.participantSearchText,
      status: data.status.present ? data.status.value : this.status,
      winner: data.winner.present ? data.winner.value : this.winner,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      lastEventSequence: data.lastEventSequence.present
          ? data.lastEventSequence.value
          : this.lastEventSequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredMatchRow(')
          ..write('id: $id, ')
          ..write('rowSchemaVersion: $rowSchemaVersion, ')
          ..write('presetId: $presetId, ')
          ..write('presetVersion: $presetVersion, ')
          ..write('sport: $sport, ')
          ..write('sideOneName: $sideOneName, ')
          ..write('sideTwoName: $sideTwoName, ')
          ..write('participantSearchText: $participantSearchText, ')
          ..write('status: $status, ')
          ..write('winner: $winner, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastEventSequence: $lastEventSequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rowSchemaVersion,
    presetId,
    presetVersion,
    sport,
    sideOneName,
    sideTwoName,
    participantSearchText,
    status,
    winner,
    createdAt,
    updatedAt,
    completedAt,
    lastEventSequence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredMatchRow &&
          other.id == this.id &&
          other.rowSchemaVersion == this.rowSchemaVersion &&
          other.presetId == this.presetId &&
          other.presetVersion == this.presetVersion &&
          other.sport == this.sport &&
          other.sideOneName == this.sideOneName &&
          other.sideTwoName == this.sideTwoName &&
          other.participantSearchText == this.participantSearchText &&
          other.status == this.status &&
          other.winner == this.winner &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.lastEventSequence == this.lastEventSequence);
}

class StoredMatchesCompanion extends UpdateCompanion<StoredMatchRow> {
  final Value<String> id;
  final Value<int> rowSchemaVersion;
  final Value<String> presetId;
  final Value<int> presetVersion;
  final Value<String> sport;
  final Value<String> sideOneName;
  final Value<String> sideTwoName;
  final Value<String> participantSearchText;
  final Value<String> status;
  final Value<String?> winner;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<int> lastEventSequence;
  final Value<int> rowid;
  const StoredMatchesCompanion({
    this.id = const Value.absent(),
    this.rowSchemaVersion = const Value.absent(),
    this.presetId = const Value.absent(),
    this.presetVersion = const Value.absent(),
    this.sport = const Value.absent(),
    this.sideOneName = const Value.absent(),
    this.sideTwoName = const Value.absent(),
    this.participantSearchText = const Value.absent(),
    this.status = const Value.absent(),
    this.winner = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.lastEventSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredMatchesCompanion.insert({
    required String id,
    this.rowSchemaVersion = const Value.absent(),
    required String presetId,
    required int presetVersion,
    required String sport,
    required String sideOneName,
    required String sideTwoName,
    required String participantSearchText,
    required String status,
    this.winner = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.lastEventSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       presetId = Value(presetId),
       presetVersion = Value(presetVersion),
       sport = Value(sport),
       sideOneName = Value(sideOneName),
       sideTwoName = Value(sideTwoName),
       participantSearchText = Value(participantSearchText),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StoredMatchRow> custom({
    Expression<String>? id,
    Expression<int>? rowSchemaVersion,
    Expression<String>? presetId,
    Expression<int>? presetVersion,
    Expression<String>? sport,
    Expression<String>? sideOneName,
    Expression<String>? sideTwoName,
    Expression<String>? participantSearchText,
    Expression<String>? status,
    Expression<String>? winner,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? lastEventSequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowSchemaVersion != null) 'schema_version': rowSchemaVersion,
      if (presetId != null) 'preset_id': presetId,
      if (presetVersion != null) 'preset_version': presetVersion,
      if (sport != null) 'sport': sport,
      if (sideOneName != null) 'side_one_name': sideOneName,
      if (sideTwoName != null) 'side_two_name': sideTwoName,
      if (participantSearchText != null)
        'participant_search_text': participantSearchText,
      if (status != null) 'status': status,
      if (winner != null) 'winner': winner,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (lastEventSequence != null) 'last_event_sequence': lastEventSequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredMatchesCompanion copyWith({
    Value<String>? id,
    Value<int>? rowSchemaVersion,
    Value<String>? presetId,
    Value<int>? presetVersion,
    Value<String>? sport,
    Value<String>? sideOneName,
    Value<String>? sideTwoName,
    Value<String>? participantSearchText,
    Value<String>? status,
    Value<String?>? winner,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<int>? lastEventSequence,
    Value<int>? rowid,
  }) {
    return StoredMatchesCompanion(
      id: id ?? this.id,
      rowSchemaVersion: rowSchemaVersion ?? this.rowSchemaVersion,
      presetId: presetId ?? this.presetId,
      presetVersion: presetVersion ?? this.presetVersion,
      sport: sport ?? this.sport,
      sideOneName: sideOneName ?? this.sideOneName,
      sideTwoName: sideTwoName ?? this.sideTwoName,
      participantSearchText:
          participantSearchText ?? this.participantSearchText,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      lastEventSequence: lastEventSequence ?? this.lastEventSequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rowSchemaVersion.present) {
      map['schema_version'] = Variable<int>(rowSchemaVersion.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (presetVersion.present) {
      map['preset_version'] = Variable<int>(presetVersion.value);
    }
    if (sport.present) {
      map['sport'] = Variable<String>(sport.value);
    }
    if (sideOneName.present) {
      map['side_one_name'] = Variable<String>(sideOneName.value);
    }
    if (sideTwoName.present) {
      map['side_two_name'] = Variable<String>(sideTwoName.value);
    }
    if (participantSearchText.present) {
      map['participant_search_text'] = Variable<String>(
        participantSearchText.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (lastEventSequence.present) {
      map['last_event_sequence'] = Variable<int>(lastEventSequence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredMatchesCompanion(')
          ..write('id: $id, ')
          ..write('rowSchemaVersion: $rowSchemaVersion, ')
          ..write('presetId: $presetId, ')
          ..write('presetVersion: $presetVersion, ')
          ..write('sport: $sport, ')
          ..write('sideOneName: $sideOneName, ')
          ..write('sideTwoName: $sideTwoName, ')
          ..write('participantSearchText: $participantSearchText, ')
          ..write('status: $status, ')
          ..write('winner: $winner, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastEventSequence: $lastEventSequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchParticipantsTable extends MatchParticipants
    with TableInfo<$MatchParticipantsTable, MatchParticipantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES matches (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<String> participantId = GeneratedColumn<String>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id)',
    ),
  );
  static const VerificationMeta _participantNameMeta = const VerificationMeta(
    'participantName',
  );
  @override
  late final GeneratedColumn<String> participantName = GeneratedColumn<String>(
    'participant_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    matchId,
    participantId,
    participantName,
    side,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchParticipantRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('participant_name')) {
      context.handle(
        _participantNameMeta,
        participantName.isAcceptableOrUnknown(
          data['participant_name']!,
          _participantNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantNameMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, side, position};
  @override
  MatchParticipantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchParticipantRow(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participant_id'],
      )!,
      participantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participant_name'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $MatchParticipantsTable createAlias(String alias) {
    return $MatchParticipantsTable(attachedDatabase, alias);
  }
}

class MatchParticipantRow extends DataClass
    implements Insertable<MatchParticipantRow> {
  final String matchId;
  final String participantId;
  final String participantName;
  final String side;
  final int position;
  const MatchParticipantRow({
    required this.matchId,
    required this.participantId,
    required this.participantName,
    required this.side,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['participant_id'] = Variable<String>(participantId);
    map['participant_name'] = Variable<String>(participantName);
    map['side'] = Variable<String>(side);
    map['position'] = Variable<int>(position);
    return map;
  }

  MatchParticipantsCompanion toCompanion(bool nullToAbsent) {
    return MatchParticipantsCompanion(
      matchId: Value(matchId),
      participantId: Value(participantId),
      participantName: Value(participantName),
      side: Value(side),
      position: Value(position),
    );
  }

  factory MatchParticipantRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchParticipantRow(
      matchId: serializer.fromJson<String>(json['matchId']),
      participantId: serializer.fromJson<String>(json['participantId']),
      participantName: serializer.fromJson<String>(json['participantName']),
      side: serializer.fromJson<String>(json['side']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'participantId': serializer.toJson<String>(participantId),
      'participantName': serializer.toJson<String>(participantName),
      'side': serializer.toJson<String>(side),
      'position': serializer.toJson<int>(position),
    };
  }

  MatchParticipantRow copyWith({
    String? matchId,
    String? participantId,
    String? participantName,
    String? side,
    int? position,
  }) => MatchParticipantRow(
    matchId: matchId ?? this.matchId,
    participantId: participantId ?? this.participantId,
    participantName: participantName ?? this.participantName,
    side: side ?? this.side,
    position: position ?? this.position,
  );
  MatchParticipantRow copyWithCompanion(MatchParticipantsCompanion data) {
    return MatchParticipantRow(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      participantName: data.participantName.present
          ? data.participantName.value
          : this.participantName,
      side: data.side.present ? data.side.value : this.side,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchParticipantRow(')
          ..write('matchId: $matchId, ')
          ..write('participantId: $participantId, ')
          ..write('participantName: $participantName, ')
          ..write('side: $side, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(matchId, participantId, participantName, side, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchParticipantRow &&
          other.matchId == this.matchId &&
          other.participantId == this.participantId &&
          other.participantName == this.participantName &&
          other.side == this.side &&
          other.position == this.position);
}

class MatchParticipantsCompanion extends UpdateCompanion<MatchParticipantRow> {
  final Value<String> matchId;
  final Value<String> participantId;
  final Value<String> participantName;
  final Value<String> side;
  final Value<int> position;
  final Value<int> rowid;
  const MatchParticipantsCompanion({
    this.matchId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.participantName = const Value.absent(),
    this.side = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchParticipantsCompanion.insert({
    required String matchId,
    required String participantId,
    required String participantName,
    required String side,
    required int position,
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       participantId = Value(participantId),
       participantName = Value(participantName),
       side = Value(side),
       position = Value(position);
  static Insertable<MatchParticipantRow> custom({
    Expression<String>? matchId,
    Expression<String>? participantId,
    Expression<String>? participantName,
    Expression<String>? side,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (participantId != null) 'participant_id': participantId,
      if (participantName != null) 'participant_name': participantName,
      if (side != null) 'side': side,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchParticipantsCompanion copyWith({
    Value<String>? matchId,
    Value<String>? participantId,
    Value<String>? participantName,
    Value<String>? side,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return MatchParticipantsCompanion(
      matchId: matchId ?? this.matchId,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      side: side ?? this.side,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<String>(participantId.value);
    }
    if (participantName.present) {
      map['participant_name'] = Variable<String>(participantName.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchParticipantsCompanion(')
          ..write('matchId: $matchId, ')
          ..write('participantId: $participantId, ')
          ..write('participantName: $participantName, ')
          ..write('side: $side, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScoreEventsTable extends ScoreEvents
    with TableInfo<$ScoreEventsTable, ScoreEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoreEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES matches (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    matchId,
    sequence,
    eventType,
    payloadJson,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'score_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScoreEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, sequence};
  @override
  ScoreEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoreEventRow(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $ScoreEventsTable createAlias(String alias) {
    return $ScoreEventsTable(attachedDatabase, alias);
  }
}

class ScoreEventRow extends DataClass implements Insertable<ScoreEventRow> {
  final String matchId;
  final int sequence;
  final String eventType;
  final String payloadJson;
  final DateTime occurredAt;
  const ScoreEventRow({
    required this.matchId,
    required this.sequence,
    required this.eventType,
    required this.payloadJson,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['sequence'] = Variable<int>(sequence);
    map['event_type'] = Variable<String>(eventType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  ScoreEventsCompanion toCompanion(bool nullToAbsent) {
    return ScoreEventsCompanion(
      matchId: Value(matchId),
      sequence: Value(sequence),
      eventType: Value(eventType),
      payloadJson: Value(payloadJson),
      occurredAt: Value(occurredAt),
    );
  }

  factory ScoreEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoreEventRow(
      matchId: serializer.fromJson<String>(json['matchId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'sequence': serializer.toJson<int>(sequence),
      'eventType': serializer.toJson<String>(eventType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  ScoreEventRow copyWith({
    String? matchId,
    int? sequence,
    String? eventType,
    String? payloadJson,
    DateTime? occurredAt,
  }) => ScoreEventRow(
    matchId: matchId ?? this.matchId,
    sequence: sequence ?? this.sequence,
    eventType: eventType ?? this.eventType,
    payloadJson: payloadJson ?? this.payloadJson,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  ScoreEventRow copyWithCompanion(ScoreEventsCompanion data) {
    return ScoreEventRow(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEventRow(')
          ..write('matchId: $matchId, ')
          ..write('sequence: $sequence, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(matchId, sequence, eventType, payloadJson, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreEventRow &&
          other.matchId == this.matchId &&
          other.sequence == this.sequence &&
          other.eventType == this.eventType &&
          other.payloadJson == this.payloadJson &&
          other.occurredAt == this.occurredAt);
}

class ScoreEventsCompanion extends UpdateCompanion<ScoreEventRow> {
  final Value<String> matchId;
  final Value<int> sequence;
  final Value<String> eventType;
  final Value<String> payloadJson;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const ScoreEventsCompanion({
    this.matchId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScoreEventsCompanion.insert({
    required String matchId,
    required int sequence,
    required String eventType,
    required String payloadJson,
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       sequence = Value(sequence),
       eventType = Value(eventType),
       payloadJson = Value(payloadJson),
       occurredAt = Value(occurredAt);
  static Insertable<ScoreEventRow> custom({
    Expression<String>? matchId,
    Expression<int>? sequence,
    Expression<String>? eventType,
    Expression<String>? payloadJson,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (sequence != null) 'sequence': sequence,
      if (eventType != null) 'event_type': eventType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScoreEventsCompanion copyWith({
    Value<String>? matchId,
    Value<int>? sequence,
    Value<String>? eventType,
    Value<String>? payloadJson,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return ScoreEventsCompanion(
      matchId: matchId ?? this.matchId,
      sequence: sequence ?? this.sequence,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEventsCompanion(')
          ..write('matchId: $matchId, ')
          ..write('sequence: $sequence, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CourtTallyDatabase extends GeneratedDatabase {
  _$CourtTallyDatabase(QueryExecutor e) : super(e);
  $CourtTallyDatabaseManager get managers => $CourtTallyDatabaseManager(this);
  late final $RulesPresetsTable rulesPresets = $RulesPresetsTable(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $StoredMatchesTable storedMatches = $StoredMatchesTable(this);
  late final $MatchParticipantsTable matchParticipants =
      $MatchParticipantsTable(this);
  late final $ScoreEventsTable scoreEvents = $ScoreEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rulesPresets,
    participants,
    storedMatches,
    matchParticipants,
    scoreEvents,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'matches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('match_participants', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'matches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('score_events', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RulesPresetsTableCreateCompanionBuilder =
    RulesPresetsCompanion Function({
      required String id,
      required int version,
      required String name,
      required String sport,
      required int unitsToWin,
      required int pointsToWinGame,
      required int winBy,
      Value<int?> pointCap,
      Value<int?> gamesToWinSet,
      Value<int?> tiebreakAtGames,
      Value<int?> tiebreakPoints,
      Value<int> rowid,
    });
typedef $$RulesPresetsTableUpdateCompanionBuilder =
    RulesPresetsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> name,
      Value<String> sport,
      Value<int> unitsToWin,
      Value<int> pointsToWinGame,
      Value<int> winBy,
      Value<int?> pointCap,
      Value<int?> gamesToWinSet,
      Value<int?> tiebreakAtGames,
      Value<int?> tiebreakPoints,
      Value<int> rowid,
    });

class $$RulesPresetsTableFilterComposer
    extends Composer<_$CourtTallyDatabase, $RulesPresetsTable> {
  $$RulesPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsToWin => $composableBuilder(
    column: $table.unitsToWin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsToWinGame => $composableBuilder(
    column: $table.pointsToWinGame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get winBy => $composableBuilder(
    column: $table.winBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointCap => $composableBuilder(
    column: $table.pointCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamesToWinSet => $composableBuilder(
    column: $table.gamesToWinSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tiebreakAtGames => $composableBuilder(
    column: $table.tiebreakAtGames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tiebreakPoints => $composableBuilder(
    column: $table.tiebreakPoints,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RulesPresetsTableOrderingComposer
    extends Composer<_$CourtTallyDatabase, $RulesPresetsTable> {
  $$RulesPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsToWin => $composableBuilder(
    column: $table.unitsToWin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsToWinGame => $composableBuilder(
    column: $table.pointsToWinGame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get winBy => $composableBuilder(
    column: $table.winBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointCap => $composableBuilder(
    column: $table.pointCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamesToWinSet => $composableBuilder(
    column: $table.gamesToWinSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tiebreakAtGames => $composableBuilder(
    column: $table.tiebreakAtGames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tiebreakPoints => $composableBuilder(
    column: $table.tiebreakPoints,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RulesPresetsTableAnnotationComposer
    extends Composer<_$CourtTallyDatabase, $RulesPresetsTable> {
  $$RulesPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sport =>
      $composableBuilder(column: $table.sport, builder: (column) => column);

  GeneratedColumn<int> get unitsToWin => $composableBuilder(
    column: $table.unitsToWin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointsToWinGame => $composableBuilder(
    column: $table.pointsToWinGame,
    builder: (column) => column,
  );

  GeneratedColumn<int> get winBy =>
      $composableBuilder(column: $table.winBy, builder: (column) => column);

  GeneratedColumn<int> get pointCap =>
      $composableBuilder(column: $table.pointCap, builder: (column) => column);

  GeneratedColumn<int> get gamesToWinSet => $composableBuilder(
    column: $table.gamesToWinSet,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tiebreakAtGames => $composableBuilder(
    column: $table.tiebreakAtGames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tiebreakPoints => $composableBuilder(
    column: $table.tiebreakPoints,
    builder: (column) => column,
  );
}

class $$RulesPresetsTableTableManager
    extends
        RootTableManager<
          _$CourtTallyDatabase,
          $RulesPresetsTable,
          RulesPresetRow,
          $$RulesPresetsTableFilterComposer,
          $$RulesPresetsTableOrderingComposer,
          $$RulesPresetsTableAnnotationComposer,
          $$RulesPresetsTableCreateCompanionBuilder,
          $$RulesPresetsTableUpdateCompanionBuilder,
          (
            RulesPresetRow,
            BaseReferences<
              _$CourtTallyDatabase,
              $RulesPresetsTable,
              RulesPresetRow
            >,
          ),
          RulesPresetRow,
          PrefetchHooks Function()
        > {
  $$RulesPresetsTableTableManager(
    _$CourtTallyDatabase db,
    $RulesPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulesPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulesPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulesPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sport = const Value.absent(),
                Value<int> unitsToWin = const Value.absent(),
                Value<int> pointsToWinGame = const Value.absent(),
                Value<int> winBy = const Value.absent(),
                Value<int?> pointCap = const Value.absent(),
                Value<int?> gamesToWinSet = const Value.absent(),
                Value<int?> tiebreakAtGames = const Value.absent(),
                Value<int?> tiebreakPoints = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RulesPresetsCompanion(
                id: id,
                version: version,
                name: name,
                sport: sport,
                unitsToWin: unitsToWin,
                pointsToWinGame: pointsToWinGame,
                winBy: winBy,
                pointCap: pointCap,
                gamesToWinSet: gamesToWinSet,
                tiebreakAtGames: tiebreakAtGames,
                tiebreakPoints: tiebreakPoints,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int version,
                required String name,
                required String sport,
                required int unitsToWin,
                required int pointsToWinGame,
                required int winBy,
                Value<int?> pointCap = const Value.absent(),
                Value<int?> gamesToWinSet = const Value.absent(),
                Value<int?> tiebreakAtGames = const Value.absent(),
                Value<int?> tiebreakPoints = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RulesPresetsCompanion.insert(
                id: id,
                version: version,
                name: name,
                sport: sport,
                unitsToWin: unitsToWin,
                pointsToWinGame: pointsToWinGame,
                winBy: winBy,
                pointCap: pointCap,
                gamesToWinSet: gamesToWinSet,
                tiebreakAtGames: tiebreakAtGames,
                tiebreakPoints: tiebreakPoints,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RulesPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$CourtTallyDatabase,
      $RulesPresetsTable,
      RulesPresetRow,
      $$RulesPresetsTableFilterComposer,
      $$RulesPresetsTableOrderingComposer,
      $$RulesPresetsTableAnnotationComposer,
      $$RulesPresetsTableCreateCompanionBuilder,
      $$RulesPresetsTableUpdateCompanionBuilder,
      (
        RulesPresetRow,
        BaseReferences<
          _$CourtTallyDatabase,
          $RulesPresetsTable,
          RulesPresetRow
        >,
      ),
      RulesPresetRow,
      PrefetchHooks Function()
    >;
typedef $$ParticipantsTableCreateCompanionBuilder =
    ParticipantsCompanion Function({
      required String id,
      required String name,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ParticipantsTableUpdateCompanionBuilder =
    ParticipantsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ParticipantsTableReferences
    extends
        BaseReferences<
          _$CourtTallyDatabase,
          $ParticipantsTable,
          ParticipantRow
        > {
  $$ParticipantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MatchParticipantsTable, List<MatchParticipantRow>>
  _matchParticipantsRefsTable(_$CourtTallyDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.matchParticipants,
        aliasName: 'participants__id__match_participants__participant_id',
      );

  $$MatchParticipantsTableProcessedTableManager get matchParticipantsRefs {
    final manager = $$MatchParticipantsTableTableManager(
      $_db,
      $_db.matchParticipants,
    ).filter((f) => f.participantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _matchParticipantsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ParticipantsTableFilterComposer
    extends Composer<_$CourtTallyDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> matchParticipantsRefs(
    Expression<bool> Function($$MatchParticipantsTableFilterComposer f) f,
  ) {
    final $$MatchParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchParticipants,
      getReferencedColumn: (t) => t.participantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.matchParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParticipantsTableOrderingComposer
    extends Composer<_$CourtTallyDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParticipantsTableAnnotationComposer
    extends Composer<_$CourtTallyDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> matchParticipantsRefs<T extends Object>(
    Expression<T> Function($$MatchParticipantsTableAnnotationComposer a) f,
  ) {
    final $$MatchParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.matchParticipants,
          getReferencedColumn: (t) => t.participantId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MatchParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.matchParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ParticipantsTableTableManager
    extends
        RootTableManager<
          _$CourtTallyDatabase,
          $ParticipantsTable,
          ParticipantRow,
          $$ParticipantsTableFilterComposer,
          $$ParticipantsTableOrderingComposer,
          $$ParticipantsTableAnnotationComposer,
          $$ParticipantsTableCreateCompanionBuilder,
          $$ParticipantsTableUpdateCompanionBuilder,
          (ParticipantRow, $$ParticipantsTableReferences),
          ParticipantRow,
          PrefetchHooks Function({bool matchParticipantsRefs})
        > {
  $$ParticipantsTableTableManager(
    _$CourtTallyDatabase db,
    $ParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParticipantsCompanion(
                id: id,
                name: name,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ParticipantsCompanion.insert(
                id: id,
                name: name,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({matchParticipantsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (matchParticipantsRefs) db.matchParticipants,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (matchParticipantsRefs)
                    await $_getPrefetchedData<
                      ParticipantRow,
                      $ParticipantsTable,
                      MatchParticipantRow
                    >(
                      currentTable: table,
                      referencedTable: $$ParticipantsTableReferences
                          ._matchParticipantsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ParticipantsTableReferences(
                            db,
                            table,
                            p0,
                          ).matchParticipantsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.participantId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$CourtTallyDatabase,
      $ParticipantsTable,
      ParticipantRow,
      $$ParticipantsTableFilterComposer,
      $$ParticipantsTableOrderingComposer,
      $$ParticipantsTableAnnotationComposer,
      $$ParticipantsTableCreateCompanionBuilder,
      $$ParticipantsTableUpdateCompanionBuilder,
      (ParticipantRow, $$ParticipantsTableReferences),
      ParticipantRow,
      PrefetchHooks Function({bool matchParticipantsRefs})
    >;
typedef $$StoredMatchesTableCreateCompanionBuilder =
    StoredMatchesCompanion Function({
      required String id,
      Value<int> rowSchemaVersion,
      required String presetId,
      required int presetVersion,
      required String sport,
      required String sideOneName,
      required String sideTwoName,
      required String participantSearchText,
      required String status,
      Value<String?> winner,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
      Value<int> lastEventSequence,
      Value<int> rowid,
    });
typedef $$StoredMatchesTableUpdateCompanionBuilder =
    StoredMatchesCompanion Function({
      Value<String> id,
      Value<int> rowSchemaVersion,
      Value<String> presetId,
      Value<int> presetVersion,
      Value<String> sport,
      Value<String> sideOneName,
      Value<String> sideTwoName,
      Value<String> participantSearchText,
      Value<String> status,
      Value<String?> winner,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<int> lastEventSequence,
      Value<int> rowid,
    });

final class $$StoredMatchesTableReferences
    extends
        BaseReferences<
          _$CourtTallyDatabase,
          $StoredMatchesTable,
          StoredMatchRow
        > {
  $$StoredMatchesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MatchParticipantsTable, List<MatchParticipantRow>>
  _matchParticipantsRefsTable(_$CourtTallyDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.matchParticipants,
        aliasName: 'matches__id__match_participants__match_id',
      );

  $$MatchParticipantsTableProcessedTableManager get matchParticipantsRefs {
    final manager = $$MatchParticipantsTableTableManager(
      $_db,
      $_db.matchParticipants,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _matchParticipantsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScoreEventsTable, List<ScoreEventRow>>
  _scoreEventsRefsTable(_$CourtTallyDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scoreEvents,
        aliasName: 'matches__id__score_events__match_id',
      );

  $$ScoreEventsTableProcessedTableManager get scoreEventsRefs {
    final manager = $$ScoreEventsTableTableManager(
      $_db,
      $_db.scoreEvents,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scoreEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoredMatchesTableFilterComposer
    extends Composer<_$CourtTallyDatabase, $StoredMatchesTable> {
  $$StoredMatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowSchemaVersion => $composableBuilder(
    column: $table.rowSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get presetVersion => $composableBuilder(
    column: $table.presetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sideOneName => $composableBuilder(
    column: $table.sideOneName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sideTwoName => $composableBuilder(
    column: $table.sideTwoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get participantSearchText => $composableBuilder(
    column: $table.participantSearchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastEventSequence => $composableBuilder(
    column: $table.lastEventSequence,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> matchParticipantsRefs(
    Expression<bool> Function($$MatchParticipantsTableFilterComposer f) f,
  ) {
    final $$MatchParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchParticipants,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.matchParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scoreEventsRefs(
    Expression<bool> Function($$ScoreEventsTableFilterComposer f) f,
  ) {
    final $$ScoreEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEvents,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEventsTableFilterComposer(
            $db: $db,
            $table: $db.scoreEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoredMatchesTableOrderingComposer
    extends Composer<_$CourtTallyDatabase, $StoredMatchesTable> {
  $$StoredMatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowSchemaVersion => $composableBuilder(
    column: $table.rowSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get presetVersion => $composableBuilder(
    column: $table.presetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sideOneName => $composableBuilder(
    column: $table.sideOneName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sideTwoName => $composableBuilder(
    column: $table.sideTwoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get participantSearchText => $composableBuilder(
    column: $table.participantSearchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastEventSequence => $composableBuilder(
    column: $table.lastEventSequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredMatchesTableAnnotationComposer
    extends Composer<_$CourtTallyDatabase, $StoredMatchesTable> {
  $$StoredMatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rowSchemaVersion => $composableBuilder(
    column: $table.rowSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<int> get presetVersion => $composableBuilder(
    column: $table.presetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sport =>
      $composableBuilder(column: $table.sport, builder: (column) => column);

  GeneratedColumn<String> get sideOneName => $composableBuilder(
    column: $table.sideOneName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sideTwoName => $composableBuilder(
    column: $table.sideTwoName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get participantSearchText => $composableBuilder(
    column: $table.participantSearchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastEventSequence => $composableBuilder(
    column: $table.lastEventSequence,
    builder: (column) => column,
  );

  Expression<T> matchParticipantsRefs<T extends Object>(
    Expression<T> Function($$MatchParticipantsTableAnnotationComposer a) f,
  ) {
    final $$MatchParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.matchParticipants,
          getReferencedColumn: (t) => t.matchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MatchParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.matchParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> scoreEventsRefs<T extends Object>(
    Expression<T> Function($$ScoreEventsTableAnnotationComposer a) f,
  ) {
    final $$ScoreEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEvents,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.scoreEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoredMatchesTableTableManager
    extends
        RootTableManager<
          _$CourtTallyDatabase,
          $StoredMatchesTable,
          StoredMatchRow,
          $$StoredMatchesTableFilterComposer,
          $$StoredMatchesTableOrderingComposer,
          $$StoredMatchesTableAnnotationComposer,
          $$StoredMatchesTableCreateCompanionBuilder,
          $$StoredMatchesTableUpdateCompanionBuilder,
          (StoredMatchRow, $$StoredMatchesTableReferences),
          StoredMatchRow,
          PrefetchHooks Function({
            bool matchParticipantsRefs,
            bool scoreEventsRefs,
          })
        > {
  $$StoredMatchesTableTableManager(
    _$CourtTallyDatabase db,
    $StoredMatchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredMatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredMatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredMatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> rowSchemaVersion = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<int> presetVersion = const Value.absent(),
                Value<String> sport = const Value.absent(),
                Value<String> sideOneName = const Value.absent(),
                Value<String> sideTwoName = const Value.absent(),
                Value<String> participantSearchText = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> winner = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> lastEventSequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredMatchesCompanion(
                id: id,
                rowSchemaVersion: rowSchemaVersion,
                presetId: presetId,
                presetVersion: presetVersion,
                sport: sport,
                sideOneName: sideOneName,
                sideTwoName: sideTwoName,
                participantSearchText: participantSearchText,
                status: status,
                winner: winner,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                lastEventSequence: lastEventSequence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> rowSchemaVersion = const Value.absent(),
                required String presetId,
                required int presetVersion,
                required String sport,
                required String sideOneName,
                required String sideTwoName,
                required String participantSearchText,
                required String status,
                Value<String?> winner = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> lastEventSequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredMatchesCompanion.insert(
                id: id,
                rowSchemaVersion: rowSchemaVersion,
                presetId: presetId,
                presetVersion: presetVersion,
                sport: sport,
                sideOneName: sideOneName,
                sideTwoName: sideTwoName,
                participantSearchText: participantSearchText,
                status: status,
                winner: winner,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                lastEventSequence: lastEventSequence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoredMatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({matchParticipantsRefs = false, scoreEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (matchParticipantsRefs) db.matchParticipants,
                    if (scoreEventsRefs) db.scoreEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchParticipantsRefs)
                        await $_getPrefetchedData<
                          StoredMatchRow,
                          $StoredMatchesTable,
                          MatchParticipantRow
                        >(
                          currentTable: table,
                          referencedTable: $$StoredMatchesTableReferences
                              ._matchParticipantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoredMatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).matchParticipantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.matchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scoreEventsRefs)
                        await $_getPrefetchedData<
                          StoredMatchRow,
                          $StoredMatchesTable,
                          ScoreEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$StoredMatchesTableReferences
                              ._scoreEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoredMatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).scoreEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.matchId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StoredMatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$CourtTallyDatabase,
      $StoredMatchesTable,
      StoredMatchRow,
      $$StoredMatchesTableFilterComposer,
      $$StoredMatchesTableOrderingComposer,
      $$StoredMatchesTableAnnotationComposer,
      $$StoredMatchesTableCreateCompanionBuilder,
      $$StoredMatchesTableUpdateCompanionBuilder,
      (StoredMatchRow, $$StoredMatchesTableReferences),
      StoredMatchRow,
      PrefetchHooks Function({bool matchParticipantsRefs, bool scoreEventsRefs})
    >;
typedef $$MatchParticipantsTableCreateCompanionBuilder =
    MatchParticipantsCompanion Function({
      required String matchId,
      required String participantId,
      required String participantName,
      required String side,
      required int position,
      Value<int> rowid,
    });
typedef $$MatchParticipantsTableUpdateCompanionBuilder =
    MatchParticipantsCompanion Function({
      Value<String> matchId,
      Value<String> participantId,
      Value<String> participantName,
      Value<String> side,
      Value<int> position,
      Value<int> rowid,
    });

final class $$MatchParticipantsTableReferences
    extends
        BaseReferences<
          _$CourtTallyDatabase,
          $MatchParticipantsTable,
          MatchParticipantRow
        > {
  $$MatchParticipantsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StoredMatchesTable _matchIdTable(_$CourtTallyDatabase db) =>
      db.storedMatches.createAlias('match_participants__match_id__matches__id');

  $$StoredMatchesTableProcessedTableManager get matchId {
    final $_column = $_itemColumn<String>('match_id')!;

    final manager = $$StoredMatchesTableTableManager(
      $_db,
      $_db.storedMatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ParticipantsTable _participantIdTable(_$CourtTallyDatabase db) => db
      .participants
      .createAlias('match_participants__participant_id__participants__id');

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<String>('participant_id')!;

    final manager = $$ParticipantsTableTableManager(
      $_db,
      $_db.participants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MatchParticipantsTableFilterComposer
    extends Composer<_$CourtTallyDatabase, $MatchParticipantsTable> {
  $$MatchParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get participantName => $composableBuilder(
    column: $table.participantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$StoredMatchesTableFilterComposer get matchId {
    final $$StoredMatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.storedMatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMatchesTableFilterComposer(
            $db: $db,
            $table: $db.storedMatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchParticipantsTableOrderingComposer
    extends Composer<_$CourtTallyDatabase, $MatchParticipantsTable> {
  $$MatchParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get participantName => $composableBuilder(
    column: $table.participantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoredMatchesTableOrderingComposer get matchId {
    final $$StoredMatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.storedMatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMatchesTableOrderingComposer(
            $db: $db,
            $table: $db.storedMatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableOrderingComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchParticipantsTableAnnotationComposer
    extends Composer<_$CourtTallyDatabase, $MatchParticipantsTable> {
  $$MatchParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get participantName => $composableBuilder(
    column: $table.participantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$StoredMatchesTableAnnotationComposer get matchId {
    final $$StoredMatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.storedMatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.storedMatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableAnnotationComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchParticipantsTableTableManager
    extends
        RootTableManager<
          _$CourtTallyDatabase,
          $MatchParticipantsTable,
          MatchParticipantRow,
          $$MatchParticipantsTableFilterComposer,
          $$MatchParticipantsTableOrderingComposer,
          $$MatchParticipantsTableAnnotationComposer,
          $$MatchParticipantsTableCreateCompanionBuilder,
          $$MatchParticipantsTableUpdateCompanionBuilder,
          (MatchParticipantRow, $$MatchParticipantsTableReferences),
          MatchParticipantRow,
          PrefetchHooks Function({bool matchId, bool participantId})
        > {
  $$MatchParticipantsTableTableManager(
    _$CourtTallyDatabase db,
    $MatchParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> matchId = const Value.absent(),
                Value<String> participantId = const Value.absent(),
                Value<String> participantName = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchParticipantsCompanion(
                matchId: matchId,
                participantId: participantId,
                participantName: participantName,
                side: side,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String matchId,
                required String participantId,
                required String participantName,
                required String side,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => MatchParticipantsCompanion.insert(
                matchId: matchId,
                participantId: participantId,
                participantName: participantName,
                side: side,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MatchParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({matchId = false, participantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (matchId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.matchId,
                        referencedTable: $$MatchParticipantsTableReferences
                            ._matchIdTable(db),
                        referencedColumn: $$MatchParticipantsTableReferences
                            ._matchIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (participantId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.participantId,
                        referencedTable: $$MatchParticipantsTableReferences
                            ._participantIdTable(db),
                        referencedColumn: $$MatchParticipantsTableReferences
                            ._participantIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MatchParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$CourtTallyDatabase,
      $MatchParticipantsTable,
      MatchParticipantRow,
      $$MatchParticipantsTableFilterComposer,
      $$MatchParticipantsTableOrderingComposer,
      $$MatchParticipantsTableAnnotationComposer,
      $$MatchParticipantsTableCreateCompanionBuilder,
      $$MatchParticipantsTableUpdateCompanionBuilder,
      (MatchParticipantRow, $$MatchParticipantsTableReferences),
      MatchParticipantRow,
      PrefetchHooks Function({bool matchId, bool participantId})
    >;
typedef $$ScoreEventsTableCreateCompanionBuilder =
    ScoreEventsCompanion Function({
      required String matchId,
      required int sequence,
      required String eventType,
      required String payloadJson,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$ScoreEventsTableUpdateCompanionBuilder =
    ScoreEventsCompanion Function({
      Value<String> matchId,
      Value<int> sequence,
      Value<String> eventType,
      Value<String> payloadJson,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

final class $$ScoreEventsTableReferences
    extends
        BaseReferences<_$CourtTallyDatabase, $ScoreEventsTable, ScoreEventRow> {
  $$ScoreEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StoredMatchesTable _matchIdTable(_$CourtTallyDatabase db) =>
      db.storedMatches.createAlias('score_events__match_id__matches__id');

  $$StoredMatchesTableProcessedTableManager get matchId {
    final $_column = $_itemColumn<String>('match_id')!;

    final manager = $$StoredMatchesTableTableManager(
      $_db,
      $_db.storedMatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScoreEventsTableFilterComposer
    extends Composer<_$CourtTallyDatabase, $ScoreEventsTable> {
  $$ScoreEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StoredMatchesTableFilterComposer get matchId {
    final $$StoredMatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.storedMatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMatchesTableFilterComposer(
            $db: $db,
            $table: $db.storedMatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEventsTableOrderingComposer
    extends Composer<_$CourtTallyDatabase, $ScoreEventsTable> {
  $$ScoreEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoredMatchesTableOrderingComposer get matchId {
    final $$StoredMatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.storedMatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMatchesTableOrderingComposer(
            $db: $db,
            $table: $db.storedMatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEventsTableAnnotationComposer
    extends Composer<_$CourtTallyDatabase, $ScoreEventsTable> {
  $$ScoreEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  $$StoredMatchesTableAnnotationComposer get matchId {
    final $$StoredMatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.storedMatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredMatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.storedMatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEventsTableTableManager
    extends
        RootTableManager<
          _$CourtTallyDatabase,
          $ScoreEventsTable,
          ScoreEventRow,
          $$ScoreEventsTableFilterComposer,
          $$ScoreEventsTableOrderingComposer,
          $$ScoreEventsTableAnnotationComposer,
          $$ScoreEventsTableCreateCompanionBuilder,
          $$ScoreEventsTableUpdateCompanionBuilder,
          (ScoreEventRow, $$ScoreEventsTableReferences),
          ScoreEventRow,
          PrefetchHooks Function({bool matchId})
        > {
  $$ScoreEventsTableTableManager(
    _$CourtTallyDatabase db,
    $ScoreEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoreEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoreEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoreEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> matchId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScoreEventsCompanion(
                matchId: matchId,
                sequence: sequence,
                eventType: eventType,
                payloadJson: payloadJson,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String matchId,
                required int sequence,
                required String eventType,
                required String payloadJson,
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => ScoreEventsCompanion.insert(
                matchId: matchId,
                sequence: sequence,
                eventType: eventType,
                payloadJson: payloadJson,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScoreEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({matchId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (matchId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.matchId,
                        referencedTable: $$ScoreEventsTableReferences
                            ._matchIdTable(db),
                        referencedColumn: $$ScoreEventsTableReferences
                            ._matchIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScoreEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CourtTallyDatabase,
      $ScoreEventsTable,
      ScoreEventRow,
      $$ScoreEventsTableFilterComposer,
      $$ScoreEventsTableOrderingComposer,
      $$ScoreEventsTableAnnotationComposer,
      $$ScoreEventsTableCreateCompanionBuilder,
      $$ScoreEventsTableUpdateCompanionBuilder,
      (ScoreEventRow, $$ScoreEventsTableReferences),
      ScoreEventRow,
      PrefetchHooks Function({bool matchId})
    >;

class $CourtTallyDatabaseManager {
  final _$CourtTallyDatabase _db;
  $CourtTallyDatabaseManager(this._db);
  $$RulesPresetsTableTableManager get rulesPresets =>
      $$RulesPresetsTableTableManager(_db, _db.rulesPresets);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$StoredMatchesTableTableManager get storedMatches =>
      $$StoredMatchesTableTableManager(_db, _db.storedMatches);
  $$MatchParticipantsTableTableManager get matchParticipants =>
      $$MatchParticipantsTableTableManager(_db, _db.matchParticipants);
  $$ScoreEventsTableTableManager get scoreEvents =>
      $$ScoreEventsTableTableManager(_db, _db.scoreEvents);
}
