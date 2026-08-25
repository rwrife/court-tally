import '../domain/scoring/scoring.dart';

/// Stable failure categories that application code can present without
/// depending on SQLite or Drift exceptions.
enum RepositoryFailureCode {
  unavailable,
  migration,
  notFound,
  conflict,
  invalidData,
  rejectedEvent,
}

sealed class RepositoryResult<T> {
  const RepositoryResult();
}

final class RepositorySuccess<T> extends RepositoryResult<T> {
  const RepositorySuccess(this.value);

  final T value;
}

final class RepositoryFailure<T> extends RepositoryResult<T> {
  const RepositoryFailure({
    required this.code,
    required this.message,
    required this.isRecoverable,
    this.cause,
  });

  final RepositoryFailureCode code;
  final String message;
  final bool isRecoverable;

  /// Diagnostic detail for logs. Presentation must not expose this directly.
  final Object? cause;
}

/// One durably ordered event. Sequence numbers are zero-based and contiguous.
final class PersistedScoreEvent {
  const PersistedScoreEvent({
    required this.sequence,
    required this.event,
    required this.occurredAt,
  });

  final int sequence;
  final ScoreEvent event;
  final DateTime occurredAt;
}

/// Authoritative events plus their replayed, derived state.
final class PersistedMatch {
  PersistedMatch({
    required this.configuration,
    required List<PersistedScoreEvent> events,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
  }) : events = List<PersistedScoreEvent>.unmodifiable(events);

  final MatchConfiguration configuration;
  final List<PersistedScoreEvent> events;
  final MatchState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  int get nextSequence => events.length;
}

enum MatchCompletionFilter { any, inProgress, completed }

/// Domain-facing history criteria. No widget, route, or display concerns leak
/// into the repository boundary.
final class MatchHistoryFilter {
  const MatchHistoryFilter({
    this.fromInclusive,
    this.toExclusive,
    this.sport,
    this.participantName,
    this.completion = MatchCompletionFilter.any,
  });

  final DateTime? fromInclusive;
  final DateTime? toExclusive;
  final Sport? sport;
  final String? participantName;
  final MatchCompletionFilter completion;
}

/// Persistence boundary for crash-safe local scoring.
///
/// Implementations must append an accepted event and update match summary
/// metadata in one transaction. Events are authoritative; [PersistedMatch.state]
/// must always be obtained by deterministic replay.
abstract interface class MatchRepository {
  Future<RepositoryResult<void>> initialize();

  /// Creates a validated configuration. When [initialServer] is supplied, the
  /// configuration and `InitialServerChosen` event must commit atomically.
  Future<RepositoryResult<PersistedMatch>> createMatch(
    MatchConfiguration configuration, {
    required DateTime createdAt,
    SideId? initialServer,
  });

  Future<RepositoryResult<PersistedMatch>> appendEvent({
    required String matchId,
    required ScoreEvent event,
    required int expectedSequence,
    required DateTime occurredAt,
  });

  Future<RepositoryResult<PersistedMatch>> loadMatch(String matchId);

  /// Permanently removes a match after explicit user confirmation.
  Future<RepositoryResult<void>> deleteMatch(String matchId);

  /// Returns the most recently updated unfinished match, if one exists.
  Future<RepositoryResult<PersistedMatch?>> loadResumableMatch();

  Future<RepositoryResult<List<PersistedMatch>>> queryHistory(
    MatchHistoryFilter filter,
  );
}
