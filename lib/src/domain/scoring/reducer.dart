part of 'scoring.dart';

/// Deterministically derives match state from an ordered event stream.
final class MatchReducer {
  const MatchReducer();

  /// Starts a validated match or returns all validation failures.
  MatchCreation create(MatchConfiguration configuration) {
    final errors = configuration.validate();
    if (errors.isNotEmpty) {
      return MatchCreationRejected(errors);
    }
    return MatchCreated(MatchState.waiting(configuration));
  }

  /// Replays an entire stream and stops at the first rejected event.
  ScoreTransition replay(
    MatchConfiguration configuration,
    Iterable<ScoreEvent> events,
  ) {
    final creation = create(configuration);
    if (creation case MatchCreationRejected(:final errors)) {
      return ScoreRejected(
        state: MatchState.waiting(configuration),
        error: errors.first,
      );
    }
    var state = (creation as MatchCreated).state;
    for (final event in events) {
      final transition = apply(state, event);
      if (transition case ScoreRejected()) {
        return transition;
      }
      state = (transition as ScoreAccepted).state;
    }
    return ScoreAccepted(state);
  }

  ScoreTransition apply(MatchState state, ScoreEvent event) {
    return switch (event) {
      InitialServerChosen() => _chooseInitialServer(state, event.side),
      PointAwarded() => _awardPoint(state, event),
      SidesChanged() => _acknowledgeSideChange(state),
      PointUndone() => _undo(state),
      PointRedone() => _redo(state),
    };
  }

  ScoreTransition _chooseInitialServer(MatchState state, SideId server) {
    if (state.status != MatchStatus.awaitingInitialServer) {
      return _reject(
        state,
        ScoringErrorCode.initialServerAlreadyChosen,
        'The initial server has already been chosen.',
      );
    }
    final pickleball = state.configuration.preset.sport == Sport.pickleball;
    final pickleballServiceNumber = pickleball
        ? (state.configuration.sideOne.participants.length == 2 ? 2 : 1)
        : 0;
    return ScoreAccepted(
      state._copyWith(
        status: MatchStatus.inProgress,
        initialServer: server,
        server: server,
        gameInitialServer: server,
        pickleballServiceNumber: pickleballServiceNumber,
      ),
    );
  }

  ScoreTransition _awardPoint(MatchState state, PointAwarded event) {
    if (state.status == MatchStatus.awaitingInitialServer) {
      return _reject(
        state,
        ScoringErrorCode.initialServerRequired,
        'Choose the initial server before recording a point.',
      );
    }
    if (state.isComplete) {
      return _reject(
        state,
        ScoringErrorCode.matchCompleted,
        'No points can be added after match completion.',
      );
    }
    if (state.sideChangePrompt != null) {
      return _reject(
        state,
        ScoringErrorCode.sideChangeRequired,
        'Confirm the pending change of ends before recording another point.',
      );
    }

    final scored = _rulesetFor(state.configuration.preset)
        .awardPoint(state, event.side);
    return ScoreAccepted(
      scored._copyWith(
        pointHistory: <PointAwarded>[...state.pointHistory, event],
        redoStack: const <RedoPoint>[],
      ),
    );
  }

  ScoreTransition _acknowledgeSideChange(MatchState state) {
    if (state.sideChangePrompt == null) {
      return _reject(
        state,
        ScoringErrorCode.sideChangeNotRequired,
        'There is no pending change-of-ends prompt.',
      );
    }
    return ScoreAccepted(
      state._copyWith(
        sideChangesCompleted: state.sideChangesCompleted + 1,
        acknowledgedSideChangesAfterPoint: <int>{
          ...state.acknowledgedSideChangesAfterPoint,
          state.pointHistory.length,
        },
        clearSideChangePrompt: true,
      ),
    );
  }

  ScoreTransition _undo(MatchState state) {
    if (state.status == MatchStatus.awaitingInitialServer ||
        state.pointHistory.isEmpty) {
      return _reject(
        state,
        ScoringErrorCode.undoUnavailable,
        'There is no awarded point to undo.',
      );
    }
    final points = state.pointHistory.toList()..removeLast();
    final undone = state.pointHistory.last;
    final removedPointCount = state.pointHistory.length;
    final acknowledgedAfterUndone = state.acknowledgedSideChangesAfterPoint
        .contains(removedPointCount);
    final acknowledgements = state.acknowledgedSideChangesAfterPoint
        .where((pointCount) => pointCount <= points.length)
        .toSet();
    final rebuilt = _rebuild(
      state.configuration,
      state.initialServer!,
      points,
      acknowledgements,
    );
    return ScoreAccepted(
      rebuilt._copyWith(
        pointHistory: points,
        redoStack: <RedoPoint>[
          ...state.redoStack,
          RedoPoint(
            point: undone,
            acknowledgedSideChange: acknowledgedAfterUndone,
          ),
        ],
      ),
    );
  }

  ScoreTransition _redo(MatchState state) {
    if (state.redoStack.isEmpty) {
      return _reject(
        state,
        ScoringErrorCode.redoUnavailable,
        'There is no undone point to redo.',
      );
    }
    final redoStack = state.redoStack.toList();
    final restored = redoStack.removeLast();
    final points = <PointAwarded>[...state.pointHistory, restored.point];
    final acknowledgements = <int>{
      ...state.acknowledgedSideChangesAfterPoint,
      if (restored.acknowledgedSideChange) points.length,
    };
    final rebuilt = _rebuild(
      state.configuration,
      state.initialServer!,
      points,
      acknowledgements,
    );
    return ScoreAccepted(
      rebuilt._copyWith(pointHistory: points, redoStack: redoStack),
    );
  }

  MatchState _rebuild(
    MatchConfiguration configuration,
    SideId initialServer,
    List<PointAwarded> points,
    Set<int> acknowledgements,
  ) {
    var state = MatchState.waiting(configuration)._copyWith(
      status: MatchStatus.inProgress,
      initialServer: initialServer,
      server: initialServer,
      gameInitialServer: initialServer,
      pickleballServiceNumber: configuration.preset.sport == Sport.pickleball
          ? (configuration.sideOne.participants.length == 2 ? 2 : 1)
          : 0,
    );
    for (var index = 0; index < points.length; index += 1) {
      final point = points[index];
      state = _rulesetFor(configuration.preset).awardPoint(state, point.side);
      final pointCount = index + 1;
      if (state.sideChangePrompt != null &&
          acknowledgements.contains(pointCount)) {
        state = state._copyWith(
          sideChangesCompleted: state.sideChangesCompleted + 1,
          acknowledgedSideChangesAfterPoint: <int>{
            ...state.acknowledgedSideChangesAfterPoint,
            pointCount,
          },
          clearSideChangePrompt: true,
        );
      }
    }
    return state;
  }

  ScoreRejected _reject(
    MatchState state,
    ScoringErrorCode code,
    String message,
  ) {
    return ScoreRejected(
      state: state,
      error: ScoringError(code: code, message: message),
    );
  }
}

/// Result of validating and creating the initial state.
sealed class MatchCreation {
  const MatchCreation();
}

final class MatchCreated extends MatchCreation {
  const MatchCreated(this.state);

  final MatchState state;
}

final class MatchCreationRejected extends MatchCreation {
  MatchCreationRejected(List<ScoringError> errors)
    : errors = List<ScoringError>.unmodifiable(errors);

  final List<ScoringError> errors;
}
