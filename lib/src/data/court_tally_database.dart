import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/scoring/scoring.dart';

part 'court_tally_database.g.dart';

@DataClassName('RulesPresetRow')
class RulesPresets extends Table {
  @override
  String get tableName => 'rules_presets';

  TextColumn get id => text()();
  IntColumn get version => integer()();
  TextColumn get name => text()();
  TextColumn get sport => text()();
  IntColumn get unitsToWin => integer()();
  IntColumn get pointsToWinGame => integer()();
  IntColumn get winBy => integer()();
  IntColumn get pointCap => integer().nullable()();
  IntColumn get gamesToWinSet => integer().nullable()();
  IntColumn get tiebreakAtGames => integer().nullable()();
  IntColumn get tiebreakPoints => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id, version};
}

@DataClassName('ParticipantRow')
class Participants extends Table {
  @override
  String get tableName => 'participants';

  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('StoredMatchRow')
class StoredMatches extends Table {
  @override
  String get tableName => 'matches';

  TextColumn get id => text()();
  IntColumn get rowSchemaVersion =>
      integer().named('schema_version').withDefault(const Constant(1))();
  TextColumn get presetId => text()();
  IntColumn get presetVersion => integer()();
  TextColumn get sport => text()();
  TextColumn get sideOneName => text()();
  TextColumn get sideTwoName => text()();
  TextColumn get participantSearchText => text()();
  TextColumn get status => text()();
  TextColumn get winner => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get lastEventSequence =>
      integer().withDefault(const Constant(-1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('MatchParticipantRow')
class MatchParticipants extends Table {
  @override
  String get tableName => 'match_participants';

  TextColumn get matchId =>
      text().references(StoredMatches, #id, onDelete: KeyAction.cascade)();
  TextColumn get participantId => text().references(Participants, #id)();
  TextColumn get participantName => text()();
  TextColumn get side => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    matchId,
    side,
    position,
  };
}

@DataClassName('ScoreEventRow')
class ScoreEvents extends Table {
  @override
  String get tableName => 'score_events';

  TextColumn get matchId =>
      text().references(StoredMatches, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequence => integer()();
  TextColumn get eventType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{matchId, sequence};
}

@DriftDatabase(
  tables: <Type>[
    RulesPresets,
    Participants,
    StoredMatches,
    MatchParticipants,
    ScoreEvents,
  ],
)
class CourtTallyDatabase extends _$CourtTallyDatabase {
  CourtTallyDatabase(super.executor);

  CourtTallyDatabase.forFile(File file)
    : super(NativeDatabase.createInBackground(file));

  CourtTallyDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await _seedRulesPresets();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      // Version 1 is the initial, additive schema. Future migrations belong in
      // explicit `if (from < N)` blocks; destructive fallback is forbidden.
      if (from < 1) {
        await migrator.createAll();
        await _seedRulesPresets();
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      final result = await customSelect('PRAGMA quick_check').getSingle();
      if (result.data.values.single != 'ok') {
        throw StateError('SQLite integrity check failed.');
      }
    },
  );

  Future<void> ensureInitialized() async {
    await customSelect('SELECT 1').getSingle();
  }

  Future<void> _seedRulesPresets() async {
    await batch((Batch batch) {
      batch.insertAll(
        rulesPresets,
        RulesPreset.all.map(_presetCompanion).toList(growable: false),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  static RulesPresetsCompanion _presetCompanion(RulesPreset preset) {
    return RulesPresetsCompanion.insert(
      id: preset.id,
      version: preset.version,
      name: preset.name,
      sport: preset.sport.name,
      unitsToWin: preset.unitsToWin,
      pointsToWinGame: preset.pointsToWinGame,
      winBy: preset.winBy,
      pointCap: Value<int?>(preset.pointCap),
      gamesToWinSet: Value<int?>(preset.gamesToWinSet),
      tiebreakAtGames: Value<int?>(preset.tiebreakAtGames),
      tiebreakPoints: Value<int?>(preset.tiebreakPoints),
    );
  }
}

LazyDatabase openCourtTallyDatabase({String fileName = 'court_tally.sqlite'}) {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return NativeDatabase.createInBackground(
      File('${directory.path}/$fileName'),
    );
  });
}
