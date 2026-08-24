import 'dart:io';
import 'dart:typed_data';

import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/court_tally_database.dart';
import 'package:court_tally/src/data/drift_match_repository.dart';
import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  group('initial schema migration', () {
    test('creates the versioned schema and seeds named presets', () async {
      final database = CourtTallyDatabase.inMemory();
      addTearDown(database.close);
      final repository = DriftMatchRepository(database);

      expect(await repository.initialize(), isA<RepositorySuccess<void>>());

      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.single, 1);
      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          )
          .map((row) => row.read<String>('name'))
          .get();
      expect(
        tables,
        containsAll(<String>[
          'rules_presets',
          'participants',
          'matches',
          'match_participants',
          'score_events',
        ]),
      );
      expect(
        await database.select(database.rulesPresets).get(),
        hasLength(RulesPreset.all.length),
      );
    });

    test('initial migration preserves unrelated existing user data', () async {
      final directory = await Directory.systemTemp.createTemp(
        'court-tally-migrate-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/legacy.sqlite');
      final legacy = sqlite.sqlite3.open(file.path);
      legacy.execute('CREATE TABLE legacy_marker (value TEXT NOT NULL)');
      legacy.execute("INSERT INTO legacy_marker VALUES ('keep-me')");
      legacy.close();

      final database = CourtTallyDatabase.forFile(file);
      addTearDown(database.close);
      final result = await DriftMatchRepository(database).initialize();

      expect(result, isA<RepositorySuccess<void>>());
      final marker = await database
          .customSelect('SELECT value FROM legacy_marker')
          .getSingle();
      expect(marker.read<String>('value'), 'keep-me');
    });

    test(
      'corrupt databases return a recoverable error without replacement',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'court-tally-corrupt-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final file = File('${directory.path}/court_tally.sqlite');
        final original = Uint8List.fromList(<int>[0, 1, 2, 3, 4, 5, 6, 7]);
        await file.writeAsBytes(original, flush: true);
        final database = CourtTallyDatabase.forFile(file);

        final result = await DriftMatchRepository(database).initialize();
        await database.close();

        expect(result, isA<RepositoryFailure<void>>());
        final failure = result as RepositoryFailure<void>;
        expect(failure.code, RepositoryFailureCode.migration);
        expect(failure.isRecoverable, isTrue);
        expect(await file.readAsBytes(), original);
      },
    );
  });

  group('DriftMatchRepository', () {
    late CourtTallyDatabase database;
    late DriftMatchRepository repository;

    setUp(() async {
      database = CourtTallyDatabase.inMemory();
      repository = DriftMatchRepository(database);
      _success<void>(await repository.initialize());
    });

    tearDown(() => database.close());

    test('rolls back an interrupted event transaction', () async {
      final configuration = _configuration(
        'rollback-match',
        RulesPreset.badmintonBestOfThree,
        oneName: 'Alex',
        twoName: 'Blair',
      );
      _success<PersistedMatch>(
        await repository.createMatch(
          configuration,
          createdAt: DateTime.utc(2026, 8, 20),
        ),
      );
      await database.customStatement('''
        CREATE TRIGGER simulate_interruption
        BEFORE UPDATE ON matches
        BEGIN
          SELECT RAISE(ABORT, 'simulated interruption');
        END
      ''');

      final result = await repository.appendEvent(
        matchId: configuration.id,
        event: const InitialServerChosen(SideId.one),
        expectedSequence: 0,
        occurredAt: DateTime.utc(2026, 8, 20, 0, 1),
      );

      expect(result, isA<RepositoryFailure<PersistedMatch>>());
      expect(
        (result as RepositoryFailure<PersistedMatch>).isRecoverable,
        isTrue,
      );
      final eventCount = await database
          .customSelect('SELECT COUNT(*) AS count FROM score_events')
          .getSingle();
      expect(eventCount.read<int>('count'), 0);
      final match = await database.select(database.storedMatches).getSingle();
      expect(match.lastEventSequence, -1);
      expect(match.status, MatchStatus.awaitingInitialServer.name);
    });

    test(
      'restores an interrupted match and replay equals pre-close state',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'court-tally-resume-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final file = File('${directory.path}/court_tally.sqlite');
        final firstDatabase = CourtTallyDatabase.forFile(file);
        final firstRepository = DriftMatchRepository(firstDatabase);
        _success<void>(await firstRepository.initialize());
        final configuration = _configuration(
          'resume-match',
          RulesPreset.badmintonBestOfThree,
          oneName: 'Casey',
          twoName: 'Drew',
        );
        var saved = _success<PersistedMatch>(
          await firstRepository.createMatch(
            configuration,
            createdAt: DateTime.utc(2026, 8, 21),
          ),
        );
        saved = await _append(
          firstRepository,
          saved,
          const InitialServerChosen(SideId.two),
          1,
        );
        saved = await _append(
          firstRepository,
          saved,
          const PointAwarded(SideId.one),
          2,
        );
        saved = await _append(
          firstRepository,
          saved,
          const PointAwarded(SideId.two),
          3,
        );
        final beforeRestart = _fingerprint(saved.state);
        await firstDatabase.close();

        final reopenedDatabase = CourtTallyDatabase.forFile(file);
        addTearDown(reopenedDatabase.close);
        final reopenedRepository = DriftMatchRepository(reopenedDatabase);
        _success<void>(await reopenedRepository.initialize());
        final resumed = _success<PersistedMatch?>(
          await reopenedRepository.loadResumableMatch(),
        );

        expect(resumed, isNotNull);
        expect(resumed!.configuration.id, configuration.id);
        expect(_fingerprint(resumed.state), beforeRestart);
        final replayed = _successState(
          const MatchReducer().replay(
            resumed.configuration,
            resumed.events.map((event) => event.event),
          ),
        );
        expect(_fingerprint(replayed), beforeRestart);
      },
    );

    test('rejects invalid events without appending them', () async {
      final configuration = _configuration(
        'rejected-match',
        RulesPreset.tableTennisBestOfFive,
      );
      final created = _success<PersistedMatch>(
        await repository.createMatch(
          configuration,
          createdAt: DateTime.utc(2026, 8, 21),
        ),
      );

      final rejected = await repository.appendEvent(
        matchId: configuration.id,
        event: const PointAwarded(SideId.one),
        expectedSequence: created.nextSequence,
        occurredAt: DateTime.utc(2026, 8, 21, 0, 1),
      );

      expect(rejected, isA<RepositoryFailure<PersistedMatch>>());
      expect(
        (rejected as RepositoryFailure<PersistedMatch>).code,
        RepositoryFailureCode.rejectedEvent,
      );
      final loaded = _success<PersistedMatch>(
        await repository.loadMatch(configuration.id),
      );
      expect(loaded.events, isEmpty);
    });
  });

  for (final adapter in <_RepositoryAdapter>[
    _RepositoryAdapter(
      name: 'in-memory',
      create: () async => _RepositoryFixture(InMemoryMatchRepository(), null),
    ),
    _RepositoryAdapter(
      name: 'Drift',
      create: () async {
        final database = CourtTallyDatabase.inMemory();
        return _RepositoryFixture(
          DriftMatchRepository(database),
          database.close,
        );
      },
    ),
  ]) {
    group('${adapter.name} repository contract', () {
      late _RepositoryFixture fixture;

      setUp(() async {
        fixture = await adapter.create();
        _success<void>(await fixture.repository.initialize());
      });

      tearDown(() async => fixture.close?.call());

      test(
        'queries by date, sport, participant name, and completion',
        () async {
          final completedConfiguration = _configuration(
            'completed-match',
            RulesPreset.pickleballSingleGame15,
            oneName: 'Morgan Lee',
            twoName: 'Riley',
          );
          var completed = _success<PersistedMatch>(
            await fixture.repository.createMatch(
              completedConfiguration,
              createdAt: DateTime.utc(2026, 8),
            ),
          );
          completed = await _append(
            fixture.repository,
            completed,
            const InitialServerChosen(SideId.one),
            1,
          );
          for (var point = 0; point < 15; point += 1) {
            completed = await _append(
              fixture.repository,
              completed,
              const PointAwarded(SideId.one),
              point + 2,
            );
            if (completed.state.sideChangePrompt != null) {
              completed = await _append(
                fixture.repository,
                completed,
                const SidesChanged(),
                point + 2,
              );
            }
          }
          expect(completed.state.isComplete, isTrue);

          final activeConfiguration = _configuration(
            'active-match',
            RulesPreset.badmintonBestOfThree,
            oneName: 'Taylor',
            twoName: 'Jordan',
          );
          _success<PersistedMatch>(
            await fixture.repository.createMatch(
              activeConfiguration,
              createdAt: DateTime.utc(2026, 8, 15),
            ),
          );

          final completedQuery = _success<List<PersistedMatch>>(
            await fixture.repository.queryHistory(
              MatchHistoryFilter(
                fromInclusive: _augustStart,
                toExclusive: _augustTenth,
                sport: Sport.pickleball,
                participantName: 'morgan',
                completion: MatchCompletionFilter.completed,
              ),
            ),
          );
          expect(
            completedQuery.map((match) => match.configuration.id),
            <String>['completed-match'],
          );

          final activeQuery = _success<List<PersistedMatch>>(
            await fixture.repository.queryHistory(
              const MatchHistoryFilter(
                participantName: 'TAYL',
                completion: MatchCompletionFilter.inProgress,
              ),
            ),
          );
          expect(activeQuery.map((match) => match.configuration.id), <String>[
            'active-match',
          ]);
          final resumable = _success<PersistedMatch?>(
            await fixture.repository.loadResumableMatch(),
          );
          expect(resumable?.configuration.id, 'active-match');
        },
      );

      test(
        'preserves historical names when a participant id is reused',
        () async {
          final firstConfiguration = _configuration(
            'historical-name-match',
            RulesPreset.badmintonBestOfThree,
            oneName: 'Original Name',
            oneId: 'shared-participant',
          );
          final secondConfiguration = _configuration(
            'renamed-participant-match',
            RulesPreset.badmintonBestOfThree,
            oneName: 'Updated Name',
            oneId: 'shared-participant',
          );
          _success<PersistedMatch>(
            await fixture.repository.createMatch(
              firstConfiguration,
              createdAt: DateTime.utc(2026, 8, 20),
            ),
          );
          _success<PersistedMatch>(
            await fixture.repository.createMatch(
              secondConfiguration,
              createdAt: DateTime.utc(2026, 8, 21),
            ),
          );

          final historical = _success<PersistedMatch>(
            await fixture.repository.loadMatch(firstConfiguration.id),
          );
          final current = _success<PersistedMatch>(
            await fixture.repository.loadMatch(secondConfiguration.id),
          );
          expect(
            historical.configuration.sideOne.participants.single.name,
            'Original Name',
          );
          expect(
            current.configuration.sideOne.participants.single.name,
            'Updated Name',
          );
        },
      );

      test(
        'uses optimistic sequence checks to prevent duplicate writes',
        () async {
          final configuration = _configuration(
            'duplicate-match',
            RulesPreset.badmintonBestOfThree,
          );
          final created = _success<PersistedMatch>(
            await fixture.repository.createMatch(
              configuration,
              createdAt: DateTime.utc(2026, 8, 22),
            ),
          );
          final first = await _append(
            fixture.repository,
            created,
            const InitialServerChosen(SideId.one),
            1,
          );

          final duplicate = await fixture.repository.appendEvent(
            matchId: configuration.id,
            event: const InitialServerChosen(SideId.one),
            expectedSequence: 0,
            occurredAt: DateTime.utc(2026, 8, 22, 0, 2),
          );

          expect(duplicate, isA<RepositoryFailure<PersistedMatch>>());
          expect(
            (duplicate as RepositoryFailure<PersistedMatch>).code,
            RepositoryFailureCode.conflict,
          );
          final loaded = _success<PersistedMatch>(
            await fixture.repository.loadMatch(configuration.id),
          );
          expect(loaded.events, hasLength(1));
          expect(_fingerprint(loaded.state), _fingerprint(first.state));
        },
      );
    });
  }
}

final _augustStart = DateTime.utc(2026, 8);
final _augustTenth = DateTime.utc(2026, 8, 10);

final class _RepositoryAdapter {
  const _RepositoryAdapter({required this.name, required this.create});

  final String name;
  final Future<_RepositoryFixture> Function() create;
}

final class _RepositoryFixture {
  const _RepositoryFixture(this.repository, this.close);

  final MatchRepository repository;
  final Future<void> Function()? close;
}

MatchConfiguration _configuration(
  String id,
  RulesPreset preset, {
  String oneName = 'North',
  String twoName = 'South',
  String? oneId,
  String? twoId,
}) {
  return MatchConfiguration(
    id: id,
    sideOne: MatchSide(
      id: SideId.one,
      name: oneName,
      participants: <Participant>[
        Participant(id: oneId ?? '$id-one', name: oneName),
      ],
    ),
    sideTwo: MatchSide(
      id: SideId.two,
      name: twoName,
      participants: <Participant>[
        Participant(id: twoId ?? '$id-two', name: twoName),
      ],
    ),
    preset: preset,
  );
}

T _success<T>(RepositoryResult<T> result) {
  if (result case RepositorySuccess<T>(:final value)) {
    return value;
  }
  final failure = result as RepositoryFailure<T>;
  fail('Unexpected repository failure: ${failure.message}; ${failure.cause}');
}

MatchState _successState(ScoreTransition transition) {
  if (transition case ScoreAccepted(:final state)) {
    return state;
  }
  final rejection = transition as ScoreRejected;
  fail('Unexpected scoring rejection: ${rejection.error.message}');
}

Future<PersistedMatch> _append(
  MatchRepository repository,
  PersistedMatch match,
  ScoreEvent event,
  int minute,
) async {
  return _success<PersistedMatch>(
    await repository.appendEvent(
      matchId: match.configuration.id,
      event: event,
      expectedSequence: match.nextSequence,
      occurredAt: DateTime.utc(2026, 8, 21, 0, minute),
    ),
  );
}

String _fingerprint(MatchState state) {
  return <Object?>[
    state.status,
    state.server,
    state.pointsOne,
    state.pointsTwo,
    state.gamesOne,
    state.gamesTwo,
    state.setsOne,
    state.setsTwo,
    state.gameNumber,
    state.setNumber,
    state.sideChangePrompt?.reason,
    state.sideChangesCompleted,
    state.winner,
    state.pointHistory.map((point) => point.side).join(','),
    state.redoStack.length,
  ].join('|');
}
