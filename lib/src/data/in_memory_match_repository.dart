import '../application/match_repository.dart';
import '../domain/scoring/scoring.dart';

/// Deterministic repository used by application and domain-facing tests.
///
/// It mirrors the SQLite adapter's optimistic sequence contract and always
/// reconstructs derived state from the authoritative event list.
final class InMemoryMatchRepository implements MatchRepository {
  final Map<String, _MemoryMatch> _matches = <String, _MemoryMatch>{};

  @override
  Future<RepositoryResult<void>> initialize() async {
    return const RepositorySuccess<void>(null);
  }

  @override
  Future<RepositoryResult<PersistedMatch>> createMatch(
    MatchConfiguration configuration, {
    required DateTime createdAt,
    SideId? initialServer,
  }) async {
    final creation = const MatchReducer().create(configuration);
    if (creation case MatchCreationRejected(:final errors)) {
      return RepositoryFailure<PersistedMatch>(
        code: RepositoryFailureCode.invalidData,
        message: errors.map((error) => error.message).join(' '),
        isRecoverable: true,
      );
    }
    if (_matches.containsKey(configuration.id)) {
      return const RepositoryFailure<PersistedMatch>(
        code: RepositoryFailureCode.conflict,
        message: 'A match with this identifier already exists.',
        isRecoverable: true,
      );
    }

    final memory = _MemoryMatch(
      configuration: configuration,
      createdAt: createdAt.toUtc(),
      updatedAt: createdAt.toUtc(),
    );
    if (initialServer != null) {
      memory.events.add(
        PersistedScoreEvent(
          sequence: 0,
          event: InitialServerChosen(initialServer),
          occurredAt: createdAt.toUtc(),
        ),
      );
    }
    _matches[configuration.id] = memory;
    return RepositorySuccess<PersistedMatch>(_materialize(memory));
  }

  @override
  Future<RepositoryResult<PersistedMatch>> appendEvent({
    required String matchId,
    required ScoreEvent event,
    required int expectedSequence,
    required DateTime occurredAt,
  }) async {
    final memory = _matches[matchId];
    if (memory == null) {
      return const RepositoryFailure<PersistedMatch>(
        code: RepositoryFailureCode.notFound,
        message: 'The match no longer exists.',
        isRecoverable: true,
      );
    }
    if (memory.events.length != expectedSequence) {
      return RepositoryFailure<PersistedMatch>(
        code: RepositoryFailureCode.conflict,
        message:
            'The match changed before this action could be saved. '
            'Expected event $expectedSequence but found ${memory.events.length}.',
        isRecoverable: true,
      );
    }

    final before = _replay(memory);
    final transition = const MatchReducer().apply(before, event);
    if (transition case ScoreRejected(:final error)) {
      return RepositoryFailure<PersistedMatch>(
        code: RepositoryFailureCode.rejectedEvent,
        message: error.message,
        isRecoverable: true,
      );
    }

    final nextState = (transition as ScoreAccepted).state;
    final timestamp = occurredAt.toUtc();
    memory.events.add(
      PersistedScoreEvent(
        sequence: expectedSequence,
        event: event,
        occurredAt: timestamp,
      ),
    );
    memory.updatedAt = timestamp;
    memory.completedAt = nextState.isComplete ? timestamp : null;
    return RepositorySuccess<PersistedMatch>(_materialize(memory));
  }

  @override
  Future<RepositoryResult<PersistedMatch>> loadMatch(String matchId) async {
    final memory = _matches[matchId];
    if (memory == null) {
      return const RepositoryFailure<PersistedMatch>(
        code: RepositoryFailureCode.notFound,
        message: 'The match no longer exists.',
        isRecoverable: true,
      );
    }
    return RepositorySuccess<PersistedMatch>(_materialize(memory));
  }

  @override
  Future<RepositoryResult<void>> deleteMatch(String matchId) async {
    if (_matches.remove(matchId) == null) {
      return const RepositoryFailure<void>(
        code: RepositoryFailureCode.notFound,
        message: 'The match no longer exists.',
        isRecoverable: true,
      );
    }
    return const RepositorySuccess<void>(null);
  }

  @override
  Future<RepositoryResult<PersistedMatch?>> loadResumableMatch() async {
    final candidates =
        _matches.values
            .where((match) => !_replay(match).isComplete)
            .toList(growable: false)
          ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return RepositorySuccess<PersistedMatch?>(
      candidates.isEmpty ? null : _materialize(candidates.first),
    );
  }

  @override
  Future<RepositoryResult<List<PersistedMatch>>> queryHistory(
    MatchHistoryFilter filter,
  ) async {
    final normalizedName = filter.participantName?.trim().toLowerCase();
    final matches =
        _matches.values
            .where((memory) {
              final state = _replay(memory);
              if (filter.fromInclusive != null &&
                  memory.createdAt.isBefore(filter.fromInclusive!.toUtc())) {
                return false;
              }
              if (filter.toExclusive != null &&
                  !memory.createdAt.isBefore(filter.toExclusive!.toUtc())) {
                return false;
              }
              if (filter.sport != null &&
                  memory.configuration.preset.sport != filter.sport) {
                return false;
              }
              if (normalizedName != null && normalizedName.isNotEmpty) {
                final names = <Participant>[
                  ...memory.configuration.sideOne.participants,
                  ...memory.configuration.sideTwo.participants,
                ];
                if (!names.any(
                  (participant) =>
                      participant.name.toLowerCase().contains(normalizedName),
                )) {
                  return false;
                }
              }
              return switch (filter.completion) {
                MatchCompletionFilter.any => true,
                MatchCompletionFilter.inProgress => !state.isComplete,
                MatchCompletionFilter.completed => state.isComplete,
              };
            })
            .toList(growable: false)
          ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));

    return RepositorySuccess<List<PersistedMatch>>(
      matches.map(_materialize).toList(growable: false),
    );
  }

  PersistedMatch _materialize(_MemoryMatch memory) {
    return PersistedMatch(
      configuration: memory.configuration,
      events: memory.events,
      state: _replay(memory),
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
      completedAt: memory.completedAt,
    );
  }

  MatchState _replay(_MemoryMatch memory) {
    final transition = const MatchReducer().replay(
      memory.configuration,
      memory.events.map((event) => event.event),
    );
    if (transition case ScoreAccepted(:final state)) {
      return state;
    }
    final rejected = transition as ScoreRejected;
    throw StateError(
      'In-memory repository contains an invalid event stream: '
      '${rejected.error.message}',
    );
  }
}

final class _MemoryMatch {
  _MemoryMatch({
    required this.configuration,
    required this.createdAt,
    required this.updatedAt,
  });

  final MatchConfiguration configuration;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? completedAt;
  final List<PersistedScoreEvent> events = <PersistedScoreEvent>[];
}
