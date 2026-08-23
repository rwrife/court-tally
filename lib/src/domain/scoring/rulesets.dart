part of 'scoring.dart';

/// Sport-specific point transition contract.
abstract interface class _Ruleset {
  RulesPreset get preset;

  MatchState awardPoint(MatchState state, SideId rallyWinner);
}

_Ruleset _rulesetFor(RulesPreset preset) {
  return switch (preset.sport) {
    Sport.pickleball => _PickleballRules(preset),
    Sport.tennis => _TennisRules(preset),
    Sport.badminton => _BadmintonRules(preset),
    Sport.tableTennis => _TableTennisRules(preset),
  };
}

final class _PickleballRules implements _Ruleset {
  const _PickleballRules(this.preset);

  @override
  final RulesPreset preset;

  @override
  MatchState awardPoint(MatchState state, SideId rallyWinner) {
    final server = state.server!;
    if (rallyWinner != server) {
      final isDoubles = state.configuration.sideOne.participants.length == 2;
      if (isDoubles && state.pickleballServiceNumber == 1) {
        return state._copyWith(pickleballServiceNumber: 2);
      }
      return state._copyWith(
        server: server.opponent,
        gameInitialServer: state.gameInitialServer,
        pickleballServiceNumber: 1,
      );
    }

    final nextOne = state.pointsOne + (rallyWinner == SideId.one ? 1 : 0);
    final nextTwo = state.pointsTwo + (rallyWinner == SideId.two ? 1 : 0);
    if (_winsUncappedGame(nextOne, nextTwo, rallyWinner, preset)) {
      return _completeGame(
        state,
        winner: rallyWinner,
        finalPointsOne: nextOne,
        finalPointsTwo: nextTwo,
      );
    }

    final midpoint = switch (preset.pointsToWinGame) {
      11 => 6,
      15 => 8,
      21 => 11,
      _ => throw StateError('Unsupported pickleball target.'),
    };
    final isDecidingGame = state.gameNumber == (preset.unitsToWin * 2) - 1;
    final prompt =
        isDecidingGame &&
            !state.decidingGameIntervalReached &&
            (nextOne == midpoint || nextTwo == midpoint)
        ? const SideChangePrompt(
            reason: SideChangeReason.decidingGameInterval,
            description: 'Change ends at the deciding-game midpoint.',
          )
        : null;
    return state._copyWith(
      pointsOne: nextOne,
      pointsTwo: nextTwo,
      decidingGameIntervalReached:
          state.decidingGameIntervalReached || prompt != null,
      sideChangePrompt: prompt,
    );
  }

  MatchState _completeGame(
    MatchState state, {
    required SideId winner,
    required int finalPointsOne,
    required int finalPointsTwo,
  }) {
    final gamesOne = state.gamesOne + (winner == SideId.one ? 1 : 0);
    final gamesTwo = state.gamesTwo + (winner == SideId.two ? 1 : 0);
    final results = <GameResult>[
      ...state.completedGames,
      GameResult(
        gameNumber: state.gameNumber,
        setNumber: 1,
        pointsOne: finalPointsOne,
        pointsTwo: finalPointsTwo,
        winner: winner,
        wasTiebreak: false,
      ),
    ];
    final matchWon =
        (winner == SideId.one ? gamesOne : gamesTwo) >= preset.unitsToWin;
    if (matchWon) {
      return state._copyWith(
        status: MatchStatus.completed,
        pointsOne: 0,
        pointsTwo: 0,
        gamesOne: gamesOne,
        gamesTwo: gamesTwo,
        winner: winner,
        completedGames: results,
        decidingGameIntervalReached: false,
        clearSideChangePrompt: true,
      );
    }

    final nextInitialServer = state.gameInitialServer!.opponent;
    final isDoubles = state.configuration.sideOne.participants.length == 2;
    return state._copyWith(
      pointsOne: 0,
      pointsTwo: 0,
      gamesOne: gamesOne,
      gamesTwo: gamesTwo,
      gameNumber: state.gameNumber + 1,
      server: nextInitialServer,
      gameInitialServer: nextInitialServer,
      pickleballServiceNumber: isDoubles ? 2 : 1,
      decidingGameIntervalReached: false,
      sideChangePrompt: const SideChangePrompt(
        reason: SideChangeReason.betweenGames,
        description: 'Change ends before the next game.',
      ),
      completedGames: results,
    );
  }
}

final class _BadmintonRules implements _Ruleset {
  const _BadmintonRules(this.preset);

  @override
  final RulesPreset preset;

  @override
  MatchState awardPoint(MatchState state, SideId rallyWinner) {
    final nextOne = state.pointsOne + (rallyWinner == SideId.one ? 1 : 0);
    final nextTwo = state.pointsTwo + (rallyWinner == SideId.two ? 1 : 0);
    if (_winsCappedGame(nextOne, nextTwo, rallyWinner, preset)) {
      return _completeGame(
        state,
        winner: rallyWinner,
        finalPointsOne: nextOne,
        finalPointsTwo: nextTwo,
      );
    }

    final decidingGame = state.gameNumber == (preset.unitsToWin * 2) - 1;
    final prompt =
        decidingGame &&
            !state.decidingGameIntervalReached &&
            (nextOne == 11 || nextTwo == 11)
        ? const SideChangePrompt(
            reason: SideChangeReason.decidingGameInterval,
            description: 'Change ends when a side first reaches 11.',
          )
        : null;
    return state._copyWith(
      pointsOne: nextOne,
      pointsTwo: nextTwo,
      server: rallyWinner,
      decidingGameIntervalReached:
          state.decidingGameIntervalReached || prompt != null,
      sideChangePrompt: prompt,
    );
  }

  MatchState _completeGame(
    MatchState state, {
    required SideId winner,
    required int finalPointsOne,
    required int finalPointsTwo,
  }) {
    final gamesOne = state.gamesOne + (winner == SideId.one ? 1 : 0);
    final gamesTwo = state.gamesTwo + (winner == SideId.two ? 1 : 0);
    final results = <GameResult>[
      ...state.completedGames,
      GameResult(
        gameNumber: state.gameNumber,
        setNumber: 1,
        pointsOne: finalPointsOne,
        pointsTwo: finalPointsTwo,
        winner: winner,
        wasTiebreak: false,
      ),
    ];
    final matchWon =
        (winner == SideId.one ? gamesOne : gamesTwo) >= preset.unitsToWin;
    if (matchWon) {
      return state._copyWith(
        status: MatchStatus.completed,
        pointsOne: 0,
        pointsTwo: 0,
        gamesOne: gamesOne,
        gamesTwo: gamesTwo,
        server: winner,
        winner: winner,
        completedGames: results,
        decidingGameIntervalReached: false,
        clearSideChangePrompt: true,
      );
    }
    return state._copyWith(
      pointsOne: 0,
      pointsTwo: 0,
      gamesOne: gamesOne,
      gamesTwo: gamesTwo,
      gameNumber: state.gameNumber + 1,
      server: winner,
      gameInitialServer: winner,
      decidingGameIntervalReached: false,
      sideChangePrompt: const SideChangePrompt(
        reason: SideChangeReason.betweenGames,
        description: 'Change ends before the next game.',
      ),
      completedGames: results,
    );
  }
}

final class _TableTennisRules implements _Ruleset {
  const _TableTennisRules(this.preset);

  @override
  final RulesPreset preset;

  @override
  MatchState awardPoint(MatchState state, SideId rallyWinner) {
    final nextOne = state.pointsOne + (rallyWinner == SideId.one ? 1 : 0);
    final nextTwo = state.pointsTwo + (rallyWinner == SideId.two ? 1 : 0);
    if (_winsUncappedGame(nextOne, nextTwo, rallyWinner, preset)) {
      return _completeGame(
        state,
        winner: rallyWinner,
        finalPointsOne: nextOne,
        finalPointsTwo: nextTwo,
      );
    }

    final total = nextOne + nextTwo;
    final initial = state.gameInitialServer!;
    final nextServer = nextOne >= 10 && nextTwo >= 10
        ? (total.isEven ? initial : initial.opponent)
        : ((total ~/ 2).isEven ? initial : initial.opponent);
    final decidingGame = state.gameNumber == (preset.unitsToWin * 2) - 1;
    final prompt =
        decidingGame &&
            !state.decidingGameIntervalReached &&
            (nextOne == 5 || nextTwo == 5)
        ? const SideChangePrompt(
            reason: SideChangeReason.decidingGameInterval,
            description: 'Change ends when a side first reaches 5.',
          )
        : null;
    return state._copyWith(
      pointsOne: nextOne,
      pointsTwo: nextTwo,
      server: nextServer,
      decidingGameIntervalReached:
          state.decidingGameIntervalReached || prompt != null,
      sideChangePrompt: prompt,
    );
  }

  MatchState _completeGame(
    MatchState state, {
    required SideId winner,
    required int finalPointsOne,
    required int finalPointsTwo,
  }) {
    final gamesOne = state.gamesOne + (winner == SideId.one ? 1 : 0);
    final gamesTwo = state.gamesTwo + (winner == SideId.two ? 1 : 0);
    final results = <GameResult>[
      ...state.completedGames,
      GameResult(
        gameNumber: state.gameNumber,
        setNumber: 1,
        pointsOne: finalPointsOne,
        pointsTwo: finalPointsTwo,
        winner: winner,
        wasTiebreak: false,
      ),
    ];
    final matchWon =
        (winner == SideId.one ? gamesOne : gamesTwo) >= preset.unitsToWin;
    if (matchWon) {
      return state._copyWith(
        status: MatchStatus.completed,
        pointsOne: 0,
        pointsTwo: 0,
        gamesOne: gamesOne,
        gamesTwo: gamesTwo,
        winner: winner,
        completedGames: results,
        decidingGameIntervalReached: false,
        clearSideChangePrompt: true,
      );
    }
    final nextInitialServer = state.gameInitialServer!.opponent;
    return state._copyWith(
      pointsOne: 0,
      pointsTwo: 0,
      gamesOne: gamesOne,
      gamesTwo: gamesTwo,
      gameNumber: state.gameNumber + 1,
      server: nextInitialServer,
      gameInitialServer: nextInitialServer,
      decidingGameIntervalReached: false,
      sideChangePrompt: const SideChangePrompt(
        reason: SideChangeReason.betweenGames,
        description: 'Change ends before the next game.',
      ),
      completedGames: results,
    );
  }
}

final class _TennisRules implements _Ruleset {
  const _TennisRules(this.preset);

  @override
  final RulesPreset preset;

  @override
  MatchState awardPoint(MatchState state, SideId rallyWinner) {
    final nextOne = state.pointsOne + (rallyWinner == SideId.one ? 1 : 0);
    final nextTwo = state.pointsTwo + (rallyWinner == SideId.two ? 1 : 0);
    if (state.isTiebreak) {
      if (_winsTiebreak(nextOne, nextTwo, rallyWinner)) {
        return _completeTennisGame(
          state,
          winner: rallyWinner,
          finalPointsOne: nextOne,
          finalPointsTwo: nextTwo,
          wasTiebreak: true,
        );
      }
      final total = nextOne + nextTwo;
      final initial = state.tiebreakInitialServer!;
      final block = (total - 1) ~/ 2;
      final nextServer = block.isEven ? initial.opponent : initial;
      final prompt = total % 6 == 0
          ? const SideChangePrompt(
              reason: SideChangeReason.tiebreakInterval,
              description: 'Change ends after every six tiebreak points.',
            )
          : null;
      return state._copyWith(
        pointsOne: nextOne,
        pointsTwo: nextTwo,
        server: nextServer,
        sideChangePrompt: prompt,
      );
    }

    if (_winsTennisGame(nextOne, nextTwo, rallyWinner)) {
      return _completeTennisGame(
        state,
        winner: rallyWinner,
        finalPointsOne: nextOne,
        finalPointsTwo: nextTwo,
        wasTiebreak: false,
      );
    }
    return state._copyWith(pointsOne: nextOne, pointsTwo: nextTwo);
  }

  bool _winsTennisGame(int one, int two, SideId winner) {
    final winnerPoints = winner == SideId.one ? one : two;
    final loserPoints = winner == SideId.one ? two : one;
    return winnerPoints >= 4 && winnerPoints - loserPoints >= 2;
  }

  bool _winsTiebreak(int one, int two, SideId winner) {
    final winnerPoints = winner == SideId.one ? one : two;
    final loserPoints = winner == SideId.one ? two : one;
    return winnerPoints >= preset.tiebreakPoints! &&
        winnerPoints - loserPoints >= 2;
  }

  MatchState _completeTennisGame(
    MatchState state, {
    required SideId winner,
    required int finalPointsOne,
    required int finalPointsTwo,
    required bool wasTiebreak,
  }) {
    final gamesOne = state.gamesOne + (winner == SideId.one ? 1 : 0);
    final gamesTwo = state.gamesTwo + (winner == SideId.two ? 1 : 0);
    final gameResults = <GameResult>[
      ...state.completedGames,
      GameResult(
        gameNumber: state.gameNumber,
        setNumber: state.setNumber,
        pointsOne: finalPointsOne,
        pointsTwo: finalPointsTwo,
        winner: winner,
        wasTiebreak: wasTiebreak,
      ),
    ];
    final setWon =
        wasTiebreak ||
        ((winner == SideId.one ? gamesOne : gamesTwo) >=
                preset.gamesToWinSet! &&
            (gamesOne - gamesTwo).abs() >= 2);
    final serverAfterGame = wasTiebreak
        ? state.tiebreakInitialServer!.opponent
        : state.server!.opponent;

    if (setWon) {
      return _completeTennisSet(
        state,
        winner: winner,
        finalGamesOne: gamesOne,
        finalGamesTwo: gamesTwo,
        nextServer: serverAfterGame,
        gameResults: gameResults,
      );
    }

    final enteringTiebreak =
        gamesOne == preset.tiebreakAtGames &&
        gamesTwo == preset.tiebreakAtGames;
    final gamesPlayedInSet = gamesOne + gamesTwo;
    return state._copyWith(
      pointsOne: 0,
      pointsTwo: 0,
      gamesOne: gamesOne,
      gamesTwo: gamesTwo,
      gameNumber: state.gameNumber + 1,
      server: serverAfterGame,
      gameInitialServer: serverAfterGame,
      isTiebreak: enteringTiebreak,
      tiebreakInitialServer: enteringTiebreak ? serverAfterGame : null,
      clearTiebreakInitialServer: !enteringTiebreak,
      sideChangePrompt: gamesPlayedInSet.isOdd
          ? const SideChangePrompt(
              reason: SideChangeReason.betweenGames,
              description: 'Change ends after this odd-numbered game.',
            )
          : null,
      completedGames: gameResults,
    );
  }

  MatchState _completeTennisSet(
    MatchState state, {
    required SideId winner,
    required int finalGamesOne,
    required int finalGamesTwo,
    required SideId nextServer,
    required List<GameResult> gameResults,
  }) {
    final setsOne = state.setsOne + (winner == SideId.one ? 1 : 0);
    final setsTwo = state.setsTwo + (winner == SideId.two ? 1 : 0);
    final setResults = <SetResult>[
      ...state.completedSets,
      SetResult(
        setNumber: state.setNumber,
        gamesOne: finalGamesOne,
        gamesTwo: finalGamesTwo,
        winner: winner,
      ),
    ];
    final matchWon =
        (winner == SideId.one ? setsOne : setsTwo) >= preset.unitsToWin;
    if (matchWon) {
      return state._copyWith(
        status: MatchStatus.completed,
        pointsOne: 0,
        pointsTwo: 0,
        gamesOne: finalGamesOne,
        gamesTwo: finalGamesTwo,
        setsOne: setsOne,
        setsTwo: setsTwo,
        server: nextServer,
        winner: winner,
        completedGames: gameResults,
        completedSets: setResults,
        isTiebreak: false,
        clearTiebreakInitialServer: true,
        clearSideChangePrompt: true,
      );
    }

    final setHadOddGameCount = (finalGamesOne + finalGamesTwo).isOdd;
    return state._copyWith(
      pointsOne: 0,
      pointsTwo: 0,
      gamesOne: 0,
      gamesTwo: 0,
      setsOne: setsOne,
      setsTwo: setsTwo,
      gameNumber: state.gameNumber + 1,
      setNumber: state.setNumber + 1,
      server: nextServer,
      gameInitialServer: nextServer,
      isTiebreak: false,
      clearTiebreakInitialServer: true,
      sideChangePrompt: setHadOddGameCount
          ? const SideChangePrompt(
              reason: SideChangeReason.betweenSets,
              description: 'Change ends after this set.',
            )
          : null,
      completedGames: gameResults,
      completedSets: setResults,
    );
  }
}

bool _winsUncappedGame(int one, int two, SideId winner, RulesPreset preset) {
  final winnerPoints = winner == SideId.one ? one : two;
  final loserPoints = winner == SideId.one ? two : one;
  return winnerPoints >= preset.pointsToWinGame &&
      winnerPoints - loserPoints >= preset.winBy;
}

bool _winsCappedGame(int one, int two, SideId winner, RulesPreset preset) {
  final winnerPoints = winner == SideId.one ? one : two;
  final loserPoints = winner == SideId.one ? two : one;
  return winnerPoints == preset.pointCap ||
      (winnerPoints >= preset.pointsToWinGame &&
          winnerPoints - loserPoints >= preset.winBy);
}
