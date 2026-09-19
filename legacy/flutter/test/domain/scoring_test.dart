import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const reducer = MatchReducer();

  group('model and transition validation', () {
    test('defines immutable sides and all named versioned presets', () {
      final configuration = _configuration(RulesPreset.badmintonBestOfThree);

      expect(configuration.sideOne.participants, hasLength(1));
      expect(
        () => configuration.sideOne.participants.add(
          const Participant(id: 'extra', name: 'Extra'),
        ),
        throwsUnsupportedError,
      );
      expect(
        RulesPreset.all.map((preset) => preset.id),
        containsAll(<String>[
          'pickleball.usap.side-out.best-of-3-to-11',
          'tennis.itf.advantage.best-of-3',
          'badminton.bwf.best-of-3-to-21',
          'table-tennis.ittf.best-of-5-to-11',
        ]),
      );
      expect(RulesPreset.all.every((preset) => preset.version == 1), isTrue);
    });

    test('rejects invalid configuration with an explanatory error', () {
      final configuration = MatchConfiguration(
        id: '',
        sideOne: MatchSide(
          id: SideId.two,
          name: '',
          participants: const <Participant>[],
        ),
        sideTwo: MatchSide(
          id: SideId.two,
          name: 'Two',
          participants: const <Participant>[
            Participant(id: 'duplicate', name: 'Player'),
            Participant(id: 'duplicate', name: 'Player'),
          ],
        ),
        preset: RulesPreset.tennisBestOfThree,
      );

      final creation = reducer.create(configuration);

      expect(creation, isA<MatchCreationRejected>());
      final errors = (creation as MatchCreationRejected).errors;
      expect(errors, isNotEmpty);
      expect(
        errors.every(
          (error) => error.code == ScoringErrorCode.invalidConfiguration,
        ),
        isTrue,
      );
      expect(errors.map((error) => error.message).join(' '), contains('must'));
    });

    test('requires one initial server and rejects points after completion', () {
      var state = _created(RulesPreset.pickleballSingleGame15);
      final beforeServer = reducer.apply(state, const PointAwarded(SideId.one));
      expect(beforeServer, isA<ScoreRejected>());
      expect(
        (beforeServer as ScoreRejected).error.code,
        ScoringErrorCode.initialServerRequired,
      );

      state = _accepted(
        reducer.apply(state, const InitialServerChosen(SideId.one)),
      );
      final duplicate = reducer.apply(
        state,
        const InitialServerChosen(SideId.two),
      );
      expect(
        (duplicate as ScoreRejected).error.code,
        ScoringErrorCode.initialServerAlreadyChosen,
      );

      for (var index = 0; index < 15; index += 1) {
        state = _point(reducer, state, SideId.one);
      }
      expect(state.isComplete, isTrue);
      final afterCompletion = reducer.apply(
        state,
        const PointAwarded(SideId.two),
      );
      expect(
        (afterCompletion as ScoreRejected).error.code,
        ScoringErrorCode.matchCompleted,
      );
    });
  });

  group('pickleball', () {
    test('uses side-out scoring and two-server service sequences', () {
      var state = _started(RulesPreset.pickleballBestOfThree, doubles: true);
      expect(state.server, SideId.one);
      expect(state.pickleballServiceNumber, 2);

      state = _point(reducer, state, SideId.two);
      expect(state.pointsTwo, 0);
      expect(state.server, SideId.two);
      expect(state.pickleballServiceNumber, 1);

      state = _point(reducer, state, SideId.one);
      expect(state.pointsOne, 0);
      expect(state.server, SideId.two);
      expect(state.pickleballServiceNumber, 2);

      state = _point(reducer, state, SideId.two);
      expect(state.pointsTwo, 1);
      expect(state.server, SideId.two);
    });

    test('singles side-outs do not invent a second server', () {
      var state = _started(RulesPreset.pickleballBestOfThree);
      expect(state.pickleballServiceNumber, 1);

      state = _point(reducer, state, SideId.two);

      expect(state.pointsTwo, 0);
      expect(state.server, SideId.two);
      expect(state.pickleballServiceNumber, 1);
    });

    test('wins by two and prompts at the deciding-game midpoint', () {
      var state = _started(RulesPreset.pickleballBestOfThree);
      state = _winPickleballGame(reducer, state, SideId.one);
      state = _acknowledgeIfNeeded(reducer, state);
      state = _winPickleballGame(reducer, state, SideId.two);
      state = _acknowledgeIfNeeded(reducer, state);

      expect(state.gameNumber, 3);
      for (var index = 0; index < 6; index += 1) {
        state = _ensurePickleballServe(reducer, state, SideId.one);
        state = _point(reducer, state, SideId.one, acknowledge: false);
      }
      expect(
        state.sideChangePrompt?.reason,
        SideChangeReason.decidingGameInterval,
      );
      final blocked = reducer.apply(state, const PointAwarded(SideId.one));
      expect(
        (blocked as ScoreRejected).error.code,
        ScoringErrorCode.sideChangeRequired,
      );
    });

    test(
      'single-game 15 and 21 presets prompt at their documented midpoint',
      () {
        for (final entry in <(RulesPreset, int)>[
          (RulesPreset.pickleballSingleGame15, 8),
          (RulesPreset.pickleballSingleGame21, 11),
        ]) {
          var state = _started(entry.$1);
          for (var index = 0; index < entry.$2; index += 1) {
            state = _point(reducer, state, SideId.one, acknowledge: false);
          }
          expect(
            state.sideChangePrompt?.reason,
            SideChangeReason.decidingGameInterval,
            reason: entry.$1.id,
          );
        }
      },
    );
  });

  group('tennis', () {
    test('maps deuce and advantage and alternates server by game', () {
      var state = _started(RulesPreset.tennisBestOfThree);
      for (final side in <SideId>[
        SideId.one,
        SideId.one,
        SideId.one,
        SideId.two,
        SideId.two,
        SideId.two,
      ]) {
        state = _point(reducer, state, side);
      }
      expect(state.pointLabelFor(SideId.one), '40');
      expect(state.pointLabelFor(SideId.two), '40');

      state = _point(reducer, state, SideId.one);
      expect(state.pointLabelFor(SideId.one), 'AD');
      state = _point(reducer, state, SideId.two);
      expect(state.pointLabelFor(SideId.one), '40');
      state = _point(reducer, state, SideId.one);
      state = _point(reducer, state, SideId.one, acknowledge: false);

      expect(state.gamesOne, 1);
      expect(state.pointsOne, 0);
      expect(state.server, SideId.two);
      expect(state.sideChangePrompt, isNotNull);
    });

    test('enters a 6-6 tiebreak with one-then-two service rotation', () {
      var state = _started(RulesPreset.tennisBestOfThree);
      for (var game = 0; game < 12; game += 1) {
        state = _winTennisGame(
          reducer,
          state,
          game.isEven ? SideId.one : SideId.two,
        );
        state = _acknowledgeIfNeeded(reducer, state);
      }
      expect(state.gamesOne, 6);
      expect(state.gamesTwo, 6);
      expect(state.isTiebreak, isTrue);
      final openingServer = state.server;

      state = _point(reducer, state, SideId.one);
      expect(state.server, openingServer!.opponent);
      state = _point(reducer, state, SideId.two);
      expect(state.server, openingServer.opponent);
      state = _point(reducer, state, SideId.one);
      expect(state.server, openingServer);
    });

    test('completes a tiebreak set and a straight-sets match', () {
      var state = _started(RulesPreset.tennisBestOfThree);
      for (var game = 0; game < 12; game += 1) {
        state = _winTennisGame(
          reducer,
          state,
          game.isEven ? SideId.one : SideId.two,
        );
        state = _acknowledgeIfNeeded(reducer, state);
      }
      for (var point = 0; point < 7; point += 1) {
        state = _point(reducer, state, SideId.one);
      }
      expect(state.setsOne, 1);
      expect(state.completedSets.single.gamesOne, 7);
      expect(state.completedSets.single.gamesTwo, 6);

      for (var game = 0; game < 6; game += 1) {
        state = _winTennisGame(reducer, state, SideId.one);
        state = _acknowledgeIfNeeded(reducer, state);
      }
      expect(state.isComplete, isTrue);
      expect(state.setsOne, 2);
      expect(state.winner, SideId.one);
    });
  });

  group('badminton', () {
    test('uses rally scoring, winner service, and the 30-point cap', () {
      var state = _started(RulesPreset.badmintonBestOfThree);
      for (var index = 0; index < 29; index += 1) {
        state = _point(reducer, state, SideId.one);
        state = _point(reducer, state, SideId.two);
      }
      expect(state.pointsOne, 29);
      expect(state.pointsTwo, 29);
      expect(state.server, SideId.two);

      state = _point(reducer, state, SideId.one, acknowledge: false);
      expect(state.gamesOne, 1);
      expect(state.completedGames.single.pointsOne, 30);
      expect(state.completedGames.single.pointsTwo, 29);
      expect(state.server, SideId.one);
    });

    test('prompts at 11 in the deciding game', () {
      var state = _started(RulesPreset.badmintonBestOfThree);
      state = _winRallyGame(reducer, state, SideId.one, 21);
      state = _acknowledgeIfNeeded(reducer, state);
      state = _winRallyGame(reducer, state, SideId.two, 21);
      state = _acknowledgeIfNeeded(reducer, state);
      for (var index = 0; index < 11; index += 1) {
        state = _point(reducer, state, SideId.one, acknowledge: false);
      }
      expect(
        state.sideChangePrompt?.reason,
        SideChangeReason.decidingGameInterval,
      );

      state = _acknowledgeIfNeeded(reducer, state);
      while (state.pointsTwo < 11) {
        state = _point(reducer, state, SideId.two, acknowledge: false);
      }
      expect(state.sideChangePrompt, isNull);
    });
  });

  group('table tennis', () {
    test('rotates service every two points then every point at deuce', () {
      var state = _started(RulesPreset.tableTennisBestOfFive);
      final openingServer = state.server;
      state = _point(reducer, state, SideId.one);
      expect(state.server, openingServer);
      state = _point(reducer, state, SideId.two);
      expect(state.server, openingServer!.opponent);

      while (state.pointsOne < 10 || state.pointsTwo < 10) {
        if (state.pointsOne < 10) {
          state = _point(reducer, state, SideId.one);
        }
        if (state.pointsTwo < 10) {
          state = _point(reducer, state, SideId.two);
        }
      }
      final serverAtDeuce = state.server;
      state = _point(reducer, state, SideId.one);
      expect(state.server, serverAtDeuce!.opponent);
      state = _point(reducer, state, SideId.two);
      expect(state.server, serverAtDeuce);
    });

    test('requires win by two', () {
      var state = _started(RulesPreset.tableTennisBestOfFive);
      for (var index = 0; index < 10; index += 1) {
        state = _point(reducer, state, SideId.one);
        state = _point(reducer, state, SideId.two);
      }
      state = _point(reducer, state, SideId.one);
      expect(state.gamesOne, 0);
      state = _point(reducer, state, SideId.one, acknowledge: false);
      expect(state.gamesOne, 1);
      expect(state.completedGames.single.pointsOne, 12);
      expect(state.completedGames.single.pointsTwo, 10);
    });
  });

  group('event sourcing', () {
    test('undo, redo, and a new point maintain explicit stacks', () {
      var state = _started(RulesPreset.badmintonBestOfThree);
      state = _point(reducer, state, SideId.one);
      state = _point(reducer, state, SideId.two);

      state = _accepted(reducer.apply(state, const PointUndone()));
      expect(state.pointsOne, 1);
      expect(state.pointsTwo, 0);
      expect(state.redoStack, hasLength(1));

      state = _accepted(reducer.apply(state, const PointRedone()));
      expect(state.pointsTwo, 1);
      expect(state.redoStack, isEmpty);

      state = _accepted(reducer.apply(state, const PointUndone()));
      state = _point(reducer, state, SideId.one);
      expect(state.pointsOne, 2);
      expect(state.pointsTwo, 0);
      expect(state.redoStack, isEmpty);
      expect(reducer.apply(state, const PointRedone()), isA<ScoreRejected>());
    });

    test('undo preserves an earlier acknowledged side change', () {
      var state = _started(RulesPreset.tennisBestOfThree);
      state = _winTennisGame(reducer, state, SideId.one);
      state = _accepted(reducer.apply(state, const SidesChanged()));
      state = _point(reducer, state, SideId.two);

      state = _accepted(reducer.apply(state, const PointUndone()));

      expect(state.gamesOne, 1);
      expect(state.pointsOne, 0);
      expect(state.pointsTwo, 0);
      expect(state.sideChangePrompt, isNull);
      expect(state.sideChangesCompleted, 1);
    });

    test('redo restores acknowledgement attached to a game-winning point', () {
      var state = _started(RulesPreset.tableTennisBestOfFive);
      state = _winRallyGame(reducer, state, SideId.one, 11);
      state = _accepted(reducer.apply(state, const SidesChanged()));

      state = _accepted(reducer.apply(state, const PointUndone()));
      expect(state.gamesOne, 0);
      expect(state.pointsOne, 10);

      state = _accepted(reducer.apply(state, const PointRedone()));
      expect(state.gamesOne, 1);
      expect(state.sideChangePrompt, isNull);
      expect(state.sideChangesCompleted, 1);
    });

    test('ordered replay is deterministic for every supported preset', () {
      for (final preset in RulesPreset.all) {
        final configuration = _configuration(preset);
        final events = <ScoreEvent>[
          const InitialServerChosen(SideId.one),
          const PointAwarded(SideId.one),
          const PointAwarded(SideId.two),
          const PointAwarded(SideId.one),
        ];
        final first = reducer.replay(configuration, events);
        final second = reducer.replay(configuration, events);

        expect(first, isA<ScoreAccepted>(), reason: preset.id);
        expect(second, isA<ScoreAccepted>(), reason: preset.id);
        expect(
          _fingerprint((first as ScoreAccepted).state),
          _fingerprint((second as ScoreAccepted).state),
          reason: preset.id,
        );
      }
    });

    test('replay preserves acknowledged prompts through undo and redo', () {
      final events = <ScoreEvent>[
        const InitialServerChosen(SideId.one),
        for (var index = 0; index < 21; index += 1)
          const PointAwarded(SideId.one),
        const SidesChanged(),
        const PointAwarded(SideId.two),
        const PointUndone(),
        const PointRedone(),
      ];

      final transition = reducer.replay(
        _configuration(RulesPreset.badmintonBestOfThree),
        events,
      );
      final state = _accepted(transition);

      expect(state.gamesOne, 1);
      expect(state.pointsTwo, 1);
      expect(state.server, SideId.two);
      expect(state.sideChangePrompt, isNull);
      expect(state.sideChangesCompleted, 1);
      expect(state.pointHistory, hasLength(22));
    });

    test('scores never become negative under undo and replay', () {
      for (final preset in RulesPreset.all) {
        var state = _started(preset);
        state = _point(reducer, state, SideId.one);
        state = _accepted(reducer.apply(state, const PointUndone()));

        expect(state.pointsOne, greaterThanOrEqualTo(0), reason: preset.id);
        expect(state.pointsTwo, greaterThanOrEqualTo(0), reason: preset.id);
        final rejected = reducer.apply(state, const PointUndone());
        expect(rejected, isA<ScoreRejected>(), reason: preset.id);
      }
    });

    test('all preset formats reach terminal completion', () {
      for (final preset in RulesPreset.all) {
        var state = _started(preset);
        final safetyLimit = preset.sport == Sport.tennis ? 400 : 250;
        for (var step = 0; step < safetyLimit && !state.isComplete; step += 1) {
          state = preset.sport == Sport.pickleball
              ? _ensurePickleballServe(reducer, state, SideId.one)
              : state;
          state = _point(reducer, state, SideId.one);
        }

        expect(state.isComplete, isTrue, reason: preset.id);
        expect(state.winner, SideId.one, reason: preset.id);
        expect(state.pointsOne, greaterThanOrEqualTo(0), reason: preset.id);
        expect(state.pointsTwo, greaterThanOrEqualTo(0), reason: preset.id);
      }
    });
  });
}

MatchConfiguration _configuration(RulesPreset preset, {bool doubles = false}) {
  return MatchConfiguration(
    id: 'match-${preset.id}',
    sideOne: MatchSide(
      id: SideId.one,
      name: 'North',
      participants: <Participant>[
        const Participant(id: 'north-player', name: 'North Player'),
        if (doubles)
          const Participant(id: 'north-partner', name: 'North Partner'),
      ],
    ),
    sideTwo: MatchSide(
      id: SideId.two,
      name: 'South',
      participants: <Participant>[
        const Participant(id: 'south-player', name: 'South Player'),
        if (doubles)
          const Participant(id: 'south-partner', name: 'South Partner'),
      ],
    ),
    preset: preset,
  );
}

MatchState _created(RulesPreset preset, {bool doubles = false}) {
  final creation = const MatchReducer().create(
    _configuration(preset, doubles: doubles),
  );
  return (creation as MatchCreated).state;
}

MatchState _started(RulesPreset preset, {bool doubles = false}) {
  return _accepted(
    const MatchReducer().apply(
      _created(preset, doubles: doubles),
      const InitialServerChosen(SideId.one),
    ),
  );
}

MatchState _accepted(ScoreTransition transition) {
  if (transition case ScoreAccepted(:final state)) {
    return state;
  }
  final rejected = transition as ScoreRejected;
  fail('Unexpected rejection: ${rejected.error.message}');
}

MatchState _point(
  MatchReducer reducer,
  MatchState state,
  SideId side, {
  bool acknowledge = true,
}) {
  var current = acknowledge ? _acknowledgeIfNeeded(reducer, state) : state;
  current = _accepted(reducer.apply(current, PointAwarded(side)));
  return current;
}

MatchState _acknowledgeIfNeeded(MatchReducer reducer, MatchState state) {
  if (state.sideChangePrompt == null) {
    return state;
  }
  return _accepted(reducer.apply(state, const SidesChanged()));
}

MatchState _ensurePickleballServe(
  MatchReducer reducer,
  MatchState state,
  SideId side,
) {
  var current = _acknowledgeIfNeeded(reducer, state);
  while (current.server != side) {
    current = _point(reducer, current, side);
  }
  return current;
}

MatchState _winPickleballGame(
  MatchReducer reducer,
  MatchState state,
  SideId winner,
) {
  var current = _ensurePickleballServe(reducer, state, winner);
  final target = state.configuration.preset.pointsToWinGame;
  for (var index = 0; index < target; index += 1) {
    current = _point(reducer, current, winner);
  }
  return current;
}

MatchState _winRallyGame(
  MatchReducer reducer,
  MatchState state,
  SideId winner,
  int target,
) {
  var current = state;
  for (var index = 0; index < target; index += 1) {
    current = _point(reducer, current, winner);
  }
  return current;
}

MatchState _winTennisGame(
  MatchReducer reducer,
  MatchState state,
  SideId winner,
) {
  var current = state;
  for (var index = 0; index < 4; index += 1) {
    current = _point(reducer, current, winner);
  }
  return current;
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
    state.isTiebreak,
    state.pickleballServiceNumber,
    state.decidingGameIntervalReached,
    state.sideChangePrompt?.reason,
    state.sideChangesCompleted,
    state.acknowledgedSideChangesAfterPoint.join(','),
    state.winner,
    state.pointHistory.map((point) => point.side).join(','),
  ].join('|');
}
