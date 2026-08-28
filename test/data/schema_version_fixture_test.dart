import 'dart:io';

import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/court_tally_database.dart';
import 'package:court_tally/src/data/data_backup_codec.dart';
import 'package:court_tally/src/data/data_ownership_service.dart';
import 'package:court_tally/src/data/drift_match_repository.dart';
import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'every committed SQLite schema fixture opens without data loss',
    () async {
      const fixtures = <(int, String)>[(1, 'schema_v1.sql')];
      expect(fixtures.map((entry) => entry.$1).toSet(), <int>{1});

      for (final fixture in fixtures) {
        final directory = await Directory.systemTemp.createTemp(
          'court-tally-schema-v${fixture.$1}-',
        );
        final file = File('${directory.path}/court_tally.sqlite');
        final sql = await File('test/fixtures/database/${fixture.$2}')
            .readAsString();
        final legacy = sqlite.sqlite3.open(file.path);
        legacy.execute(sql);
        legacy.close();

        final database = CourtTallyDatabase.forFile(file);
        final repository = DriftMatchRepository(database);
        try {
          _success<void>(await repository.initialize());
          expect(database.schemaVersion, 1);
          final version = await database
              .customSelect('PRAGMA user_version')
              .getSingle();
          expect(version.data.values.single, 1);
          final match = _success<PersistedMatch>(
            await repository.loadMatch('schema-v1-match'),
          );
          expect(match.configuration.sideOne.name, 'North');
          expect(match.configuration.sideTwo.name, 'South');
          expect(match.configuration.preset, RulesPreset.badmintonBestOfThree);
          expect(match.state.status, MatchStatus.awaitingInitialServer);
        } finally {
          await database.close();
          await directory.delete(recursive: true);
        }
      }
    },
  );

  test('every committed JSON backup fixture decodes and imports', () async {
    const fixtures = <(int, String)>[(1, 'v1.json')];
    expect(fixtures.map((entry) => entry.$1).toSet(), <int>{
      courtTallyBackupSchemaVersion,
    });

    for (final fixture in fixtures) {
      final source = await File('test/fixtures/backups/${fixture.$2}')
          .readAsString();
      final decoded = const DataBackupCodec().decode(source);
      expect(decoded.matches, hasLength(1));
      expect(decoded.matches.single.configuration.id, 'backup-v1-match');

      final repository = InMemoryMatchRepository();
      _success<void>(await repository.initialize());
      final ownership = DataOwnershipService(repository);
      final preview = _success<ImportPreview>(
        await ownership.previewImport(source),
      );
      final result = _success<MatchImportResult>(
        await ownership.applyImport(preview, MatchImportMode.merge),
      );
      expect(result.imported, 1);
      final imported = _success<PersistedMatch>(
        await repository.loadMatch('backup-v1-match'),
      );
      expect(imported.state.status, MatchStatus.awaitingInitialServer);
    }
  });
}

T _success<T>(RepositoryResult<T> result) {
  if (result case RepositorySuccess<T>(:final value)) {
    return value;
  }
  final failure = result as RepositoryFailure<T>;
  fail('Unexpected repository failure: ${failure.message}; ${failure.cause}');
}
