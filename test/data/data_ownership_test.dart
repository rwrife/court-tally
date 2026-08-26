import 'dart:convert';

import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/court_tally_database.dart';
import 'package:court_tally/src/data/data_backup_codec.dart';
import 'package:court_tally/src/data/data_ownership_service.dart';
import 'package:court_tally/src/data/drift_match_repository.dart';
import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/data/match_csv_codec.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('versioned JSON backup', () {
    test(
      'round trips participants, presets, matches, and ordered events',
      () async {
        final repository = InMemoryMatchRepository();
        await repository.initialize();
        final match = await _completedMatch(
          repository,
          id: 'round-trip',
          one: 'North, "Ace"\nClub',
          two: 'South',
        );
        final codec = const DataBackupCodec();
        final exportedAt = DateTime.utc(2026, 8, 26, 12);

        final encoded = codec.encode(<PersistedMatch>[
          match,
        ], exportedAt: exportedAt);
        final decoded = codec.decode(encoded);
        final reencoded = codec.encode(
          decoded.matches,
          exportedAt: decoded.exportedAt,
        );

        expect(decoded.exportedAt, exportedAt);
        expect(decoded.matches, hasLength(1));
        expect(
          decoded.matches.single.configuration.sideOne.name,
          'North, "Ace"\nClub',
        );
        expect(decoded.matches.single.events, hasLength(match.events.length));
        expect(decoded.matches.single.state.isComplete, isTrue);
        expect(decoded.matches.single.state.winner, SideId.one);
        expect(reencoded, encoded);

        final root = jsonDecode(encoded) as Map<String, dynamic>;
        expect(root['format'], courtTallyBackupFormat);
        expect(root['schemaVersion'], courtTallyBackupSchemaVersion);
        expect(root['presets'], hasLength(RulesPreset.all.length));
        expect(root['participants'], hasLength(2));
      },
    );

    test('rejects unsupported schema versions', () {
      final source = jsonEncode(<String, Object?>{
        'format': courtTallyBackupFormat,
        'schemaVersion': 999,
        'exportedAt': DateTime.utc(2026).toIso8601String(),
        'presets': <Object?>[],
        'participants': <Object?>[],
        'matches': <Object?>[],
      });

      expect(
        () => const DataBackupCodec().decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Unsupported backup schema version'),
          ),
        ),
      );
    });

    test('rejects timestamps without an explicit UTC marker', () async {
      final repository = InMemoryMatchRepository();
      await repository.initialize();
      final match = _success<PersistedMatch>(
        await repository.createMatch(
          _configuration('utc-required'),
          createdAt: DateTime.utc(2026, 8, 26),
        ),
      );
      final root = jsonDecode(
        const DataBackupCodec().encode(<PersistedMatch>[
          match,
        ], exportedAt: DateTime.utc(2026, 8, 26)),
      ) as Map<String, dynamic>;
      root['exportedAt'] = '2026-08-26';

      expect(
        () => const DataBackupCodec().decode(jsonEncode(root)),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('explicit UTC'),
          ),
        ),
      );
    });

    test('rejects corrupt JSON without changing existing data', () async {
      final repository = InMemoryMatchRepository();
      await repository.initialize();
      await repository.createMatch(
        _configuration('existing'),
        createdAt: DateTime.utc(2026, 8, 26),
        initialServer: SideId.one,
      );
      final service = DataOwnershipService(repository);

      final preview = await service.previewImport('{broken');

      expect(preview, isA<RepositoryFailure<ImportPreview>>());
      final history = _success<List<PersistedMatch>>(
        await repository.queryHistory(const MatchHistoryFilter()),
      );
      expect(history.single.configuration.id, 'existing');
    });

    test('rejects an invalid event stream before any write', () async {
      final sourceRepository = InMemoryMatchRepository();
      await sourceRepository.initialize();
      final sourceMatch = _success<PersistedMatch>(
        await sourceRepository.createMatch(
          _configuration('invalid-stream'),
          createdAt: DateTime.utc(2026, 8, 26),
          initialServer: SideId.one,
        ),
      );
      final codec = const DataBackupCodec();
      final root = jsonDecode(
        codec.encode(<PersistedMatch>[
          sourceMatch,
        ], exportedAt: DateTime.utc(2026, 8, 26)),
      ) as Map<String, dynamic>;
      final matches = root['matches']! as List<dynamic>;
      final match = matches.single as Map<String, dynamic>;
      final events = match['events']! as List<dynamic>;
      final first = events.single as Map<String, dynamic>;
      first['type'] = 'point_awarded';

      final target = InMemoryMatchRepository();
      await target.initialize();
      await target.createMatch(
        _configuration('keep-me'),
        createdAt: DateTime.utc(2026, 8, 25),
      );
      final preview = await DataOwnershipService(target)
          .previewImport(jsonEncode(root));

      expect(preview, isA<RepositoryFailure<ImportPreview>>());
      final history = _success<List<PersistedMatch>>(
        await target.queryHistory(const MatchHistoryFilter()),
      );
      expect(history.map((value) => value.configuration.id), <String>[
        'keep-me',
      ]);
    });
  });

  group('transactional import modes', () {
    test('merge keeps matching ids and adds only new matches', () async {
      final target = InMemoryMatchRepository();
      await target.initialize();
      await target.createMatch(
        _configuration('same-id', one: 'Existing'),
        createdAt: DateTime.utc(2026, 8, 24),
      );
      final source = InMemoryMatchRepository();
      await source.initialize();
      await source.createMatch(
        _configuration('same-id', one: 'From backup'),
        createdAt: DateTime.utc(2026, 8, 23),
      );
      await source.createMatch(
        _configuration('new-id'),
        createdAt: DateTime.utc(2026, 8, 25),
      );
      final sourceMatches = _success<List<PersistedMatch>>(
        await source.queryHistory(const MatchHistoryFilter()),
      );
      final service = DataOwnershipService(target);
      final preview = _success<ImportPreview>(
        await service.previewImport(
          const DataBackupCodec().encode(
            sourceMatches,
            exportedAt: DateTime.utc(2026, 8, 26),
          ),
        ),
      );

      final result = _success<MatchImportResult>(
        await service.applyImport(preview, MatchImportMode.merge),
      );

      expect(result.imported, 1);
      expect(result.skipped, 1);
      expect(result.removed, 0);
      final same = _success<PersistedMatch>(await target.loadMatch('same-id'));
      expect(same.configuration.sideOne.name, 'Existing');
    });

    test(
      'replace removes current data and imports the staged backup',
      () async {
        final target = InMemoryMatchRepository();
        await target.initialize();
        await target.createMatch(
          _configuration('old-id'),
          createdAt: DateTime.utc(2026, 8, 24),
        );
        final source = InMemoryMatchRepository();
        await source.initialize();
        await source.createMatch(
          _configuration('restored-id'),
          createdAt: DateTime.utc(2026, 8, 25),
        );
        final sourceMatches = _success<List<PersistedMatch>>(
          await source.queryHistory(const MatchHistoryFilter()),
        );
        final service = DataOwnershipService(target);
        final preview = _success<ImportPreview>(
          await service.previewImport(
            const DataBackupCodec().encode(
              sourceMatches,
              exportedAt: DateTime.utc(2026, 8, 26),
            ),
          ),
        );

        final result = _success<MatchImportResult>(
          await service.applyImport(preview, MatchImportMode.replace),
        );

        expect(result.imported, 1);
        expect(result.removed, 1);
        expect(
          await target.loadMatch('old-id'),
          isA<RepositoryFailure<PersistedMatch>>(),
        );
        expect(
          _success<PersistedMatch>(await target.loadMatch('restored-id'))
              .configuration
              .id,
          'restored-id',
        );
      },
    );

    test(
      'Drift rolls back the complete import if a later insert fails',
      () async {
        final database = CourtTallyDatabase.inMemory();
        addTearDown(database.close);
        final target = DriftMatchRepository(database);
        _success<void>(await target.initialize());
        final source = InMemoryMatchRepository();
        await source.initialize();
        await source.createMatch(
          _configuration('first-import'),
          createdAt: DateTime.utc(2026, 8, 24),
        );
        await source.createMatch(
          _configuration('fail-import'),
          createdAt: DateTime.utc(2026, 8, 25),
        );
        final staged = _success<List<PersistedMatch>>(
          await source.queryHistory(const MatchHistoryFilter()),
        )..sort((left, right) => left.createdAt.compareTo(right.createdAt));
        await database.customStatement('''
        CREATE TRIGGER fail_second_import
        BEFORE INSERT ON matches
        WHEN NEW.id = 'fail-import'
        BEGIN
          SELECT RAISE(ABORT, 'simulated import interruption');
        END
      ''');

        final result = await target.importMatches(
          matches: staged,
          mode: MatchImportMode.merge,
        );

        expect(result, isA<RepositoryFailure<MatchImportResult>>());
        final history = _success<List<PersistedMatch>>(
          await target.queryHistory(const MatchHistoryFilter()),
        );
        expect(history, isEmpty);
      },
    );

    test('Drift rejects out-of-order staged event timestamps', () async {
      final source = InMemoryMatchRepository();
      await source.initialize();
      var sourceMatch = _success<PersistedMatch>(
        await source.createMatch(
          _configuration('out-of-order'),
          createdAt: DateTime.utc(2026, 8, 26),
          initialServer: SideId.one,
        ),
      );
      sourceMatch = _success<PersistedMatch>(
        await source.appendEvent(
          matchId: sourceMatch.configuration.id,
          event: const PointAwarded(SideId.one),
          expectedSequence: sourceMatch.nextSequence,
          occurredAt: DateTime.utc(2026, 8, 26, 0, 0, 2),
        ),
      );
      final invalid = PersistedMatch(
        configuration: sourceMatch.configuration,
        events: <PersistedScoreEvent>[
          PersistedScoreEvent(
            sequence: 0,
            event: sourceMatch.events[0].event,
            occurredAt: DateTime.utc(2026, 8, 26, 0, 0, 2),
          ),
          PersistedScoreEvent(
            sequence: 1,
            event: sourceMatch.events[1].event,
            occurredAt: DateTime.utc(2026, 8, 26, 0, 0, 1),
          ),
        ],
        state: sourceMatch.state,
        createdAt: sourceMatch.createdAt,
        updatedAt: DateTime.utc(2026, 8, 26, 0, 0, 1),
        completedAt: null,
      );
      final database = CourtTallyDatabase.inMemory();
      addTearDown(database.close);
      final target = DriftMatchRepository(database);
      _success<void>(await target.initialize());

      final result = await target.importMatches(
        matches: <PersistedMatch>[invalid],
        mode: MatchImportMode.merge,
      );

      expect(result, isA<RepositoryFailure<MatchImportResult>>());
      expect(
        _success<List<PersistedMatch>>(
          await target.queryHistory(const MatchHistoryFilter()),
        ),
        isEmpty,
      );
    });
  });

  test('CSV correctly escapes text and neutralizes formulas', () async {
    final repository = InMemoryMatchRepository();
    await repository.initialize();
    final match = _success<PersistedMatch>(
      await repository.createMatch(
        _configuration('csv', one: 'North, "Ace"\nClub', two: '=2+2'),
        createdAt: DateTime.utc(2026, 8, 26),
        initialServer: SideId.one,
      ),
    );

    final csv = const MatchCsvCodec().encode(<PersistedMatch>[match]);

    expect(csv, contains('"North, ""Ace""\nClub"'));
    expect(csv, contains("'=2+2"));
    expect(csv, isNot(contains(',=2+2,')));
    expect(csv, startsWith('match_id,sport,preset,status'));
    expect(csv, endsWith('\r\n'));
  });
}

Future<PersistedMatch> _completedMatch(
  MatchRepository repository, {
  required String id,
  required String one,
  required String two,
}) async {
  var match = _success<PersistedMatch>(
    await repository.createMatch(
      _configuration(id, one: one, two: two),
      createdAt: DateTime.utc(2026, 8, 26),
      initialServer: SideId.one,
    ),
  );
  for (var point = 0; point < 15; point += 1) {
    match = await _append(repository, match, const PointAwarded(SideId.one));
    if (match.state.sideChangePrompt != null) {
      match = await _append(repository, match, const SidesChanged());
    }
  }
  return match;
}

MatchConfiguration _configuration(
  String id, {
  String one = 'North',
  String two = 'South',
}) {
  return MatchConfiguration(
    id: id,
    sideOne: MatchSide(
      id: SideId.one,
      name: one,
      participants: <Participant>[Participant(id: '$id-one', name: one)],
    ),
    sideTwo: MatchSide(
      id: SideId.two,
      name: two,
      participants: <Participant>[Participant(id: '$id-two', name: two)],
    ),
    preset: RulesPreset.pickleballSingleGame15,
  );
}

Future<PersistedMatch> _append(
  MatchRepository repository,
  PersistedMatch match,
  ScoreEvent event,
) async {
  return _success<PersistedMatch>(
    await repository.appendEvent(
      matchId: match.configuration.id,
      event: event,
      expectedSequence: match.nextSequence,
      occurredAt: DateTime.utc(2026, 8, 26, 0, 0, match.nextSequence + 1),
    ),
  );
}

T _success<T>(RepositoryResult<T> result) {
  if (result case RepositorySuccess<T>(:final value)) {
    return value;
  }
  final failure = result as RepositoryFailure<T>;
  fail('Unexpected repository failure: ${failure.message}; ${failure.cause}');
}
