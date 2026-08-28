import 'dart:io';

import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/court_tally_database.dart';
import 'package:court_tally/src/data/drift_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'records reducer and Drift event-persistence workload timings',
    () async {
      const reducer = MatchReducer();
      const reducerMatches = 1000;
      const pointsPerReducerMatch = 20;
      var transitions = 0;
      final reducerWatch = Stopwatch()..start();
      for (var sample = 0; sample < reducerMatches; sample += 1) {
        final creation = reducer.create(
          _configuration('reducer-$sample', RulesPreset.badmintonBestOfThree),
        );
        var state = (creation as MatchCreated).state;
        state = _accepted(
          reducer.apply(state, const InitialServerChosen(SideId.one)),
        );
        transitions += 1;
        for (var point = 0; point < pointsPerReducerMatch; point += 1) {
          state = _accepted(
            reducer.apply(
              state,
              PointAwarded(point.isEven ? SideId.one : SideId.two),
            ),
          );
          transitions += 1;
        }
        expect(state.pointsOne, 10);
        expect(state.pointsTwo, 10);
      }
      reducerWatch.stop();

      const persistedMatches = 5;
      const appendsPerMatch = 20;
      var appends = 0;
      final database = CourtTallyDatabase.inMemory();
      final repository = DriftMatchRepository(database);
      _success<void>(await repository.initialize());
      final persistenceWatch = Stopwatch()..start();
      for (var sample = 0; sample < persistedMatches; sample += 1) {
        var match = _success<PersistedMatch>(
          await repository.createMatch(
            _configuration(
              'persisted-$sample',
              RulesPreset.badmintonBestOfThree,
            ),
            createdAt: _origin,
            initialServer: SideId.one,
          ),
        );
        for (var point = 0; point < appendsPerMatch; point += 1) {
          match = _success<PersistedMatch>(
            await repository.appendEvent(
              matchId: match.configuration.id,
              event: PointAwarded(point.isEven ? SideId.one : SideId.two),
              expectedSequence: match.nextSequence,
              occurredAt: _origin.add(Duration(seconds: appends + 1)),
            ),
          );
          appends += 1;
        }
        expect(match.state.pointsOne, 10);
        expect(match.state.pointsTwo, 10);
      }
      persistenceWatch.stop();
      await database.close();

      expect(transitions, reducerMatches * (pointsPerReducerMatch + 1));
      expect(appends, persistedMatches * appendsPerMatch);
      debugPrint(
        'RESPONSIVENESS reducer transitions=$transitions '
        'elapsed_us=${reducerWatch.elapsedMicroseconds} '
        'average_us=${reducerWatch.elapsedMicroseconds / transitions} '
        'runtime="${Platform.version}"',
      );
      debugPrint(
        'RESPONSIVENESS drift appends=$appends '
        'elapsed_us=${persistenceWatch.elapsedMicroseconds} '
        'average_us=${persistenceWatch.elapsedMicroseconds / appends} '
        'storage=in-memory-sqlite runtime="${Platform.version}"',
      );
    },
  );
}

final _origin = DateTime.utc(2026, 8, 25);

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

MatchState _accepted(ScoreTransition transition) {
  if (transition case ScoreAccepted(:final state)) {
    return state;
  }
  final rejection = transition as ScoreRejected;
  fail('Unexpected scoring rejection: ${rejection.error.message}');
}

T _success<T>(RepositoryResult<T> result) {
  if (result case RepositorySuccess<T>(:final value)) {
    return value;
  }
  final failure = result as RepositoryFailure<T>;
  fail('Unexpected repository failure: ${failure.message}; ${failure.cause}');
}
