import 'dart:io';

import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/court_tally_database.dart';
import 'package:court_tally/src/data/data_ownership_service.dart';
import 'package:court_tally/src/data/drift_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'create, persist, relaunch, resume, undo, finish, export, and import',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'court-tally-lifecycle-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final sourceFile = File('${directory.path}/source.sqlite');
      final sourceDatabase = CourtTallyDatabase.forFile(sourceFile);
      var sourceRepository = DriftMatchRepository(sourceDatabase);
      _success<void>(await sourceRepository.initialize());

      var match = _success<PersistedMatch>(
        await sourceRepository.createMatch(
          _configuration('lifecycle-match'),
          createdAt: _createdAt,
          initialServer: SideId.one,
        ),
      );
      for (var point = 0; point < 8; point += 1) {
        match = await _append(
          sourceRepository,
          match,
          const PointAwarded(SideId.one),
        );
      }
      expect(match.state.sideChangePrompt, isNotNull);
      match = await _append(sourceRepository, match, const SidesChanged());
      for (var point = 0; point < 6; point += 1) {
        match = await _append(
          sourceRepository,
          match,
          const PointAwarded(SideId.one),
        );
      }
      expect(match.state.pointsOne, 14);
      expect(match.state.isComplete, isFalse);
      await sourceDatabase.close();

      final reopenedDatabase = CourtTallyDatabase.forFile(sourceFile);
      sourceRepository = DriftMatchRepository(reopenedDatabase);
      _success<void>(await sourceRepository.initialize());
      match = _success<PersistedMatch?>(
        await sourceRepository.loadResumableMatch(),
      )!;
      expect(match.configuration.id, 'lifecycle-match');
      expect(match.state.pointsOne, 14);

      match = await _append(sourceRepository, match, const PointUndone());
      expect(match.state.pointsOne, 13);
      match = await _append(sourceRepository, match, const PointRedone());
      expect(match.state.pointsOne, 14);
      match = await _append(
        sourceRepository,
        match,
        const PointAwarded(SideId.one),
      );
      expect(match.state.isComplete, isTrue);
      expect(match.state.winner, SideId.one);
      expect(match.completedAt, isNotNull);

      final history = _success<List<PersistedMatch>>(
        await sourceRepository.queryHistory(
          const MatchHistoryFilter(completion: MatchCompletionFilter.completed),
        ),
      );
      expect(history.map((value) => value.configuration.id), <String>[
        'lifecycle-match',
      ]);

      final ownership = DataOwnershipService(sourceRepository);
      final json = _success<String>(
        await ownership.createJsonBackup(exportedAt: _exportedAt),
      );
      final csv = _success<String>(await ownership.createCsvSummary());
      expect(json, contains('"schemaVersion": 1'));
      expect(csv, contains('lifecycle-match'));
      await reopenedDatabase.close();

      final targetDatabase = CourtTallyDatabase.forFile(
        File('${directory.path}/target.sqlite'),
      );
      final targetRepository = DriftMatchRepository(targetDatabase);
      _success<void>(await targetRepository.initialize());
      final targetOwnership = DataOwnershipService(targetRepository);
      final preview = _success<ImportPreview>(
        await targetOwnership.previewImport(json),
      );
      expect(preview.additions, 1);
      expect(preview.conflicts, 0);
      final imported = _success<MatchImportResult>(
        await targetOwnership.applyImport(preview, MatchImportMode.merge),
      );
      expect(imported.imported, 1);
      final restored = _success<PersistedMatch>(
        await targetRepository.loadMatch('lifecycle-match'),
      );
      expect(restored.state.isComplete, isTrue);
      expect(restored.state.winner, SideId.one);
      expect(restored.events.length, match.events.length);
      await targetDatabase.close();
    },
  );
}

final _createdAt = DateTime.utc(2026, 8, 25, 12);
final _exportedAt = DateTime.utc(2026, 8, 26, 12);

MatchConfiguration _configuration(String id) => MatchConfiguration(
  id: id,
  sideOne: MatchSide(
    id: SideId.one,
    name: 'North',
    participants: <Participant>[Participant(id: '$id-north', name: 'North')],
  ),
  sideTwo: MatchSide(
    id: SideId.two,
    name: 'South',
    participants: <Participant>[Participant(id: '$id-south', name: 'South')],
  ),
  preset: RulesPreset.pickleballSingleGame15,
);

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
      occurredAt: _createdAt.add(Duration(seconds: match.nextSequence + 1)),
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
