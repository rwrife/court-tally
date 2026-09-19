part of 'scoring.dart';

/// Sports with deterministic scoring support in Court Tally.
enum Sport { pickleball, tennis, badminton, tableTennis }

/// Stable identifiers for the two sides in a match.
enum SideId {
  one,
  two;

  SideId get opponent => this == one ? two : one;
}

/// Lifecycle of a scoreable match.
enum MatchStatus { awaitingInitialServer, inProgress, completed }

/// Why the players should change ends.
enum SideChangeReason {
  betweenGames,
  betweenSets,
  decidingGameInterval,
  tiebreakInterval,
}

/// Machine-readable rejection categories for invalid transitions.
enum ScoringErrorCode {
  invalidConfiguration,
  initialServerRequired,
  initialServerAlreadyChosen,
  matchCompleted,
  sideChangeRequired,
  sideChangeNotRequired,
  undoUnavailable,
  redoUnavailable,
}

/// A person taking part in a match.
final class Participant {
  const Participant({required this.id, required this.name});

  final String id;
  final String name;
}

/// One player or a doubles team.
final class MatchSide {
  MatchSide({
    required this.id,
    required this.name,
    required List<Participant> participants,
  }) : participants = List<Participant>.unmodifiable(participants);

  final SideId id;
  final String name;
  final List<Participant> participants;
}

/// A named, versioned rules contract.
///
/// Only the constants below are supported. Callers cannot silently create an
/// unverified variant; adding one requires a new preset and rule tests.
final class RulesPreset {
  const RulesPreset._({
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

  static const pickleballBestOfThree = RulesPreset._(
    id: 'pickleball.usap.side-out.best-of-3-to-11',
    version: 1,
    name: 'Pickleball side-out: best of 3 to 11',
    sport: Sport.pickleball,
    unitsToWin: 2,
    pointsToWinGame: 11,
    winBy: 2,
  );

  static const pickleballSingleGame15 = RulesPreset._(
    id: 'pickleball.usap.side-out.single-to-15',
    version: 1,
    name: 'Pickleball side-out: single game to 15',
    sport: Sport.pickleball,
    unitsToWin: 1,
    pointsToWinGame: 15,
    winBy: 2,
  );

  static const pickleballSingleGame21 = RulesPreset._(
    id: 'pickleball.usap.side-out.single-to-21',
    version: 1,
    name: 'Pickleball side-out: single game to 21',
    sport: Sport.pickleball,
    unitsToWin: 1,
    pointsToWinGame: 21,
    winBy: 2,
  );

  static const tennisBestOfThree = RulesPreset._(
    id: 'tennis.itf.advantage.best-of-3',
    version: 1,
    name: 'Tennis advantage sets: best of 3',
    sport: Sport.tennis,
    unitsToWin: 2,
    pointsToWinGame: 4,
    winBy: 2,
    gamesToWinSet: 6,
    tiebreakAtGames: 6,
    tiebreakPoints: 7,
  );

  static const badmintonBestOfThree = RulesPreset._(
    id: 'badminton.bwf.best-of-3-to-21',
    version: 1,
    name: 'Badminton: best of 3 to 21',
    sport: Sport.badminton,
    unitsToWin: 2,
    pointsToWinGame: 21,
    winBy: 2,
    pointCap: 30,
  );

  static const tableTennisBestOfFive = RulesPreset._(
    id: 'table-tennis.ittf.best-of-5-to-11',
    version: 1,
    name: 'Table tennis: best of 5 to 11',
    sport: Sport.tableTennis,
    unitsToWin: 3,
    pointsToWinGame: 11,
    winBy: 2,
  );

  static const all = <RulesPreset>[
    pickleballBestOfThree,
    pickleballSingleGame15,
    pickleballSingleGame21,
    tennisBestOfThree,
    badmintonBestOfThree,
    tableTennisBestOfFive,
  ];

  final String id;
  final int version;
  final String name;
  final Sport sport;

  /// Games needed to win, except in tennis where this is sets needed to win.
  final int unitsToWin;
  final int pointsToWinGame;
  final int winBy;
  final int? pointCap;
  final int? gamesToWinSet;
  final int? tiebreakAtGames;
  final int? tiebreakPoints;
}

/// Inputs that are fixed for the lifetime of a match.
final class MatchConfiguration {
  const MatchConfiguration({
    required this.id,
    required this.sideOne,
    required this.sideTwo,
    required this.preset,
  });

  final String id;
  final MatchSide sideOne;
  final MatchSide sideTwo;
  final RulesPreset preset;

  List<ScoringError> validate() {
    final errors = <ScoringError>[];
    if (id.trim().isEmpty) {
      errors.add(
        const ScoringError(
          code: ScoringErrorCode.invalidConfiguration,
          message: 'Match id must not be empty.',
        ),
      );
    }
    if (sideOne.id != SideId.one || sideTwo.id != SideId.two) {
      errors.add(
        const ScoringError(
          code: ScoringErrorCode.invalidConfiguration,
          message: 'Sides must use the stable one and two identifiers.',
        ),
      );
    }
    final participantIds = <String>{};
    for (final side in <MatchSide>[sideOne, sideTwo]) {
      if (side.name.trim().isEmpty) {
        errors.add(
          ScoringError(
            code: ScoringErrorCode.invalidConfiguration,
            message: '${side.id.name} must have a display name.',
          ),
        );
      }
      if (side.participants.isEmpty || side.participants.length > 2) {
        errors.add(
          ScoringError(
            code: ScoringErrorCode.invalidConfiguration,
            message: '${side.name} must contain one or two participants.',
          ),
        );
      }
      for (final participant in side.participants) {
        if (participant.id.trim().isEmpty || participant.name.trim().isEmpty) {
          errors.add(
            const ScoringError(
              code: ScoringErrorCode.invalidConfiguration,
              message: 'Participant ids and names must not be empty.',
            ),
          );
        } else if (!participantIds.add(participant.id)) {
          errors.add(
            ScoringError(
              code: ScoringErrorCode.invalidConfiguration,
              message: 'Participant id ${participant.id} is duplicated.',
            ),
          );
        }
      }
    }
    if (sideOne.participants.length != sideTwo.participants.length) {
      errors.add(
        const ScoringError(
          code: ScoringErrorCode.invalidConfiguration,
          message: 'Both sides must use the same singles or doubles format.',
        ),
      );
    }
    if (!RulesPreset.all.any(
      (candidate) =>
          candidate.id == preset.id && candidate.version == preset.version,
    )) {
      errors.add(
        ScoringError(
          code: ScoringErrorCode.invalidConfiguration,
          message:
              'Unsupported rules preset ${preset.id} v${preset.version}. '
              'Select a named Court Tally preset.',
        ),
      );
    }
    return List<ScoringError>.unmodifiable(errors);
  }
}

/// A durable scoring-domain event.
sealed class ScoreEvent {
  const ScoreEvent();
}

/// Chooses the side that serves the first rally.
final class InitialServerChosen extends ScoreEvent {
  const InitialServerChosen(this.side);

  final SideId side;
}

/// Records the winner of one rally.
final class PointAwarded extends ScoreEvent {
  const PointAwarded(this.side);

  final SideId side;
}

/// Confirms that players followed the pending change-ends prompt.
final class SidesChanged extends ScoreEvent {
  const SidesChanged();
}

/// Removes the latest awarded point from the effective event stream.
final class PointUndone extends ScoreEvent {
  const PointUndone();
}

/// Reapplies the latest undone point.
final class PointRedone extends ScoreEvent {
  const PointRedone();
}

/// A point waiting to be redone, including its following prompt acknowledgement.
final class RedoPoint {
  const RedoPoint({required this.point, required this.acknowledgedSideChange});

  final PointAwarded point;
  final bool acknowledgedSideChange;
}

/// An immutable, explainable invalid transition.
final class ScoringError {
  const ScoringError({required this.code, required this.message});

  final ScoringErrorCode code;
  final String message;
}

/// A prompt generated by the rules rather than inferred by the UI.
final class SideChangePrompt {
  const SideChangePrompt({required this.reason, required this.description});

  final SideChangeReason reason;
  final String description;
}

/// A completed game, retained for deterministic summaries and persistence.
final class GameResult {
  const GameResult({
    required this.gameNumber,
    required this.setNumber,
    required this.pointsOne,
    required this.pointsTwo,
    required this.winner,
    required this.wasTiebreak,
  });

  final int gameNumber;
  final int setNumber;
  final int pointsOne;
  final int pointsTwo;
  final SideId winner;
  final bool wasTiebreak;
}

/// A completed tennis set.
final class SetResult {
  const SetResult({
    required this.setNumber,
    required this.gamesOne,
    required this.gamesTwo,
    required this.winner,
  });

  final int setNumber;
  final int gamesOne;
  final int gamesTwo;
  final SideId winner;
}

/// Fully derived match state. Lists are defensively immutable.
final class MatchState {
  MatchState._reduced({
    required this.configuration,
    required this.status,
    required this.initialServer,
    required this.server,
    required this.gameInitialServer,
    required this.pointsOne,
    required this.pointsTwo,
    required this.gamesOne,
    required this.gamesTwo,
    required this.setsOne,
    required this.setsTwo,
    required this.gameNumber,
    required this.setNumber,
    required this.isTiebreak,
    required this.tiebreakInitialServer,
    required this.pickleballServiceNumber,
    required this.decidingGameIntervalReached,
    required this.sideChangePrompt,
    required this.sideChangesCompleted,
    required Set<int> acknowledgedSideChangesAfterPoint,
    required this.winner,
    required List<GameResult> completedGames,
    required List<SetResult> completedSets,
    required List<PointAwarded> pointHistory,
    required List<RedoPoint> redoStack,
  }) : completedGames = List<GameResult>.unmodifiable(completedGames),
       completedSets = List<SetResult>.unmodifiable(completedSets),
       pointHistory = List<PointAwarded>.unmodifiable(pointHistory),
       acknowledgedSideChangesAfterPoint = Set<int>.unmodifiable(
         acknowledgedSideChangesAfterPoint,
       ),
       redoStack = List<RedoPoint>.unmodifiable(redoStack);

  factory MatchState.waiting(MatchConfiguration configuration) {
    return MatchState._reduced(
      configuration: configuration,
      status: MatchStatus.awaitingInitialServer,
      initialServer: null,
      server: null,
      gameInitialServer: null,
      pointsOne: 0,
      pointsTwo: 0,
      gamesOne: 0,
      gamesTwo: 0,
      setsOne: 0,
      setsTwo: 0,
      gameNumber: 1,
      setNumber: 1,
      isTiebreak: false,
      tiebreakInitialServer: null,
      pickleballServiceNumber: 0,
      decidingGameIntervalReached: false,
      sideChangePrompt: null,
      sideChangesCompleted: 0,
      acknowledgedSideChangesAfterPoint: const <int>{},
      winner: null,
      completedGames: const <GameResult>[],
      completedSets: const <SetResult>[],
      pointHistory: const <PointAwarded>[],
      redoStack: const <RedoPoint>[],
    );
  }

  final MatchConfiguration configuration;
  final MatchStatus status;
  final SideId? initialServer;
  final SideId? server;
  final SideId? gameInitialServer;
  final int pointsOne;
  final int pointsTwo;
  final int gamesOne;
  final int gamesTwo;
  final int setsOne;
  final int setsTwo;
  final int gameNumber;
  final int setNumber;
  final bool isTiebreak;
  final SideId? tiebreakInitialServer;
  final int pickleballServiceNumber;
  final bool decidingGameIntervalReached;
  final SideChangePrompt? sideChangePrompt;
  final int sideChangesCompleted;
  final Set<int> acknowledgedSideChangesAfterPoint;
  final SideId? winner;
  final List<GameResult> completedGames;
  final List<SetResult> completedSets;
  final List<PointAwarded> pointHistory;
  final List<RedoPoint> redoStack;

  bool get isComplete => status == MatchStatus.completed;

  int pointsFor(SideId side) => side == SideId.one ? pointsOne : pointsTwo;
  int gamesFor(SideId side) => side == SideId.one ? gamesOne : gamesTwo;
  int setsFor(SideId side) => side == SideId.one ? setsOne : setsTwo;

  /// Human-readable point display. Tennis maps raw counters to tennis terms.
  String pointLabelFor(SideId side) {
    if (configuration.preset.sport != Sport.tennis || isTiebreak) {
      return pointsFor(side).toString();
    }
    final mine = pointsFor(side);
    final theirs = pointsFor(side.opponent);
    if (mine >= 3 && theirs >= 3) {
      if (mine == theirs) {
        return '40';
      }
      return mine > theirs ? 'AD' : '40';
    }
    return const <String>['0', '15', '30', '40'][mine];
  }

  MatchState _copyWith({
    MatchStatus? status,
    SideId? initialServer,
    SideId? server,
    SideId? gameInitialServer,
    int? pointsOne,
    int? pointsTwo,
    int? gamesOne,
    int? gamesTwo,
    int? setsOne,
    int? setsTwo,
    int? gameNumber,
    int? setNumber,
    bool? isTiebreak,
    SideId? tiebreakInitialServer,
    int? pickleballServiceNumber,
    bool? decidingGameIntervalReached,
    SideChangePrompt? sideChangePrompt,
    int? sideChangesCompleted,
    Set<int>? acknowledgedSideChangesAfterPoint,
    SideId? winner,
    List<GameResult>? completedGames,
    List<SetResult>? completedSets,
    List<PointAwarded>? pointHistory,
    List<RedoPoint>? redoStack,
    bool clearSideChangePrompt = false,
    bool clearTiebreakInitialServer = false,
    bool clearWinner = false,
  }) {
    return MatchState._reduced(
      configuration: configuration,
      status: status ?? this.status,
      initialServer: initialServer ?? this.initialServer,
      server: server ?? this.server,
      gameInitialServer: gameInitialServer ?? this.gameInitialServer,
      pointsOne: pointsOne ?? this.pointsOne,
      pointsTwo: pointsTwo ?? this.pointsTwo,
      gamesOne: gamesOne ?? this.gamesOne,
      gamesTwo: gamesTwo ?? this.gamesTwo,
      setsOne: setsOne ?? this.setsOne,
      setsTwo: setsTwo ?? this.setsTwo,
      gameNumber: gameNumber ?? this.gameNumber,
      setNumber: setNumber ?? this.setNumber,
      isTiebreak: isTiebreak ?? this.isTiebreak,
      tiebreakInitialServer: clearTiebreakInitialServer
          ? null
          : (tiebreakInitialServer ?? this.tiebreakInitialServer),
      pickleballServiceNumber:
          pickleballServiceNumber ?? this.pickleballServiceNumber,
      decidingGameIntervalReached:
          decidingGameIntervalReached ?? this.decidingGameIntervalReached,
      sideChangePrompt: clearSideChangePrompt
          ? null
          : (sideChangePrompt ?? this.sideChangePrompt),
      sideChangesCompleted: sideChangesCompleted ?? this.sideChangesCompleted,
      acknowledgedSideChangesAfterPoint:
          acknowledgedSideChangesAfterPoint ??
          this.acknowledgedSideChangesAfterPoint,
      winner: clearWinner ? null : (winner ?? this.winner),
      completedGames: completedGames ?? this.completedGames,
      completedSets: completedSets ?? this.completedSets,
      pointHistory: pointHistory ?? this.pointHistory,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

/// Result of applying one event without throwing for user input mistakes.
sealed class ScoreTransition {
  const ScoreTransition();
}

final class ScoreAccepted extends ScoreTransition {
  const ScoreAccepted(this.state);

  final MatchState state;
}

final class ScoreRejected extends ScoreTransition {
  const ScoreRejected({required this.state, required this.error});

  final MatchState state;
  final ScoringError error;
}
