import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/data_backup_codec.dart';
import 'package:court_tally/src/data/data_ownership_service.dart';
import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'all supported presets complete through persistence and backup replay',
    () async {
      final repository = InMemoryMatchRepository();
      _success<void>(await repository.initialize());
      final completed = <PersistedMatch>[];

      for (final preset in RulesPreset.all) {
        final id = 'complete-${preset.id}';
        var match = _success<PersistedMatch>(
          await repository.createMatch(
            _configuration(id, preset),
            createdAt: _origin,
            initialServer: SideId.one,
          ),
        );
        match = await _exerciseBoundary(repository, match);
        var safety = 0;
        while (!match.state.isComplete && safety < 500) {
          if (match.state.sideChangePrompt != null) {
            match = await _append(repository, match, const SidesChanged());
          }
          match = await _append(
            repository,
            match,
            const PointAwarded(SideId.one),
          );
          safety += 1;
        }

        expect(match.state.isComplete, isTrue, reason: preset.id);
        expect(match.state.winner, SideId.one, reason: preset.id);
        completed.add(match);
      }

      expect(completed, hasLength(RulesPreset.all.length));
      expect(
        completed.map((match) => match.configuration.preset.sport).toSet(),
        Sport.values.toSet(),
      );
      final backup = _success<String>(
        await DataOwnershipService(repository)
            .createJsonBackup(exportedAt: _origin.add(const Duration(days: 1))),
      );
      final decoded = const DataBackupCodec().decode(backup);
      expect(decoded.matches, hasLength(RulesPreset.all.length));
      for (final restored in decoded.matches) {
        expect(restored.state.isComplete, isTrue);
        expect(restored.state.winner, SideId.one);
      }
    },
  );
}

final _origin = DateTime.utc(2026, 8, 25);

Future<PersistedMatch> _exerciseBoundary(
  MatchRepository repository,
  PersistedMatch match,
) async {
  switch (match.configuration.preset.sport) {
    case Sport.pickleball:
      match = await _append(repository, match, const PointAwarded(SideId.two));
      expect(match.state.pointsTwo, 0);
      match = await _append(repository, match, const PointAwarded(SideId.one));
      expect(match.state.pointsOne, 0);
    case Sport.tennis:
      for (var point = 0; point < 3; point += 1) {
        match = await _append(
          repository,
          match,
          const PointAwarded(SideId.one),
        );
        match = await _append(
          repository,
          match,
          const PointAwarded(SideId.two),
        );
      }
      expect(match.state.pointLabelFor(SideId.one), '40');
      expect(match.state.pointLabelFor(SideId.two), '40');
      match = await _append(repository, match, const PointAwarded(SideId.one));
      expect(match.state.pointLabelFor(SideId.one), 'AD');
      match = await _append(repository, match, const PointAwarded(SideId.two));
      expect(match.state.pointLabelFor(SideId.one), '40');
    case Sport.badminton:
      for (var point = 0; point < 29; point += 1) {
        match = await _append(
          repository,
          match,
          const PointAwarded(SideId.one),
        );
        match = await _append(
          repository,
          match,
          const PointAwarded(SideId.two),
        );
      }
      expect(match.state.pointsOne, 29);
      expect(match.state.pointsTwo, 29);
      match = await _append(repository, match, const PointAwarded(SideId.one));
      expect(match.state.completedGames.single.pointsOne, 30);
    case Sport.tableTennis:
      for (var point = 0; point < 10; point += 1) {
        match = await _append(
          repository,
          match,
          const PointAwarded(SideId.one),
        );
        match = await _append(
          repository,
          match,
          const PointAwarded(SideId.two),
        );
      }
      expect(match.state.pointsOne, 10);
      expect(match.state.pointsTwo, 10);
      match = await _append(repository, match, const PointAwarded(SideId.one));
      match = await _append(repository, match, const PointAwarded(SideId.one));
      expect(match.state.completedGames.single.pointsOne, 12);
  }
  return match;
}

MatchConfiguration _configuration(
  String id,
  RulesPreset preset,
) => MatchConfiguration(
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
  preset: preset,
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
      occurredAt: _origin.add(Duration(seconds: match.nextSequence + 1)),
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
