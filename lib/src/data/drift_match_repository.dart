import 'package:drift/drift.dart';

import '../application/match_repository.dart';
import '../domain/scoring/scoring.dart';
import 'court_tally_database.dart';
import 'match_persistence_codec.dart';

/// Drift/SQLite implementation. Every event append and summary update occurs in
/// one SQLite transaction; no destructive recovery or migration path exists.
final class DriftMatchRepository implements MatchRepository {
  DriftMatchRepository(this.database);

  final CourtTallyDatabase database;

  @override
  Future<RepositoryResult<void>> initialize() async {
    try {
      await database.ensureInitialized();
      return const RepositorySuccess<void>(null);
    } catch (error) {
      return RepositoryFailure<void>(
        code: RepositoryFailureCode.migration,
        message:
            'The local database could not be opened or migrated. Existing '
            'data was left unchanged; retry after checking available storage.',
        isRecoverable: true,
        cause: error,
      );
    }
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

    try {
      return await database.transaction(() async {
        final existing = await (database.select(
          database.storedMatches,
        )..where((row) => row.id.equals(configuration.id))).getSingleOrNull();
        if (existing != null) {
          return const RepositoryFailure<PersistedMatch>(
            code: RepositoryFailureCode.conflict,
            message: 'A match with this identifier already exists.',
            isRecoverable: true,
          );
        }

        final timestamp = createdAt.toUtc();
        await _upsertParticipants(configuration, timestamp);
        await database
            .into(database.storedMatches)
            .insert(
              StoredMatchesCompanion.insert(
                id: configuration.id,
                presetId: configuration.preset.id,
                presetVersion: configuration.preset.version,
                sport: configuration.preset.sport.name,
                sideOneName: configuration.sideOne.name,
                sideTwoName: configuration.sideTwo.name,
                participantSearchText: normalizedParticipantSearch(
                  configuration,
                ),
                status: MatchStatus.awaitingInitialServer.name,
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );
        await _insertMatchParticipants(configuration);
        if (initialServer != null) {
          final event = InitialServerChosen(initialServer);
          final initialState = (creation as MatchCreated).state;
          final transition = const MatchReducer().apply(initialState, event);
          final nextState = (transition as ScoreAccepted).state;
          final encoded = encodeScoreEvent(event);
          await database
              .into(database.scoreEvents)
              .insert(
                ScoreEventsCompanion.insert(
                  matchId: configuration.id,
                  sequence: 0,
                  eventType: encoded.type,
                  payloadJson: encoded.payloadJson,
                  occurredAt: timestamp,
                ),
              );
          await (database.update(
            database.storedMatches,
          )..where((row) => row.id.equals(configuration.id))).write(
            StoredMatchesCompanion(
              status: Value<String>(nextState.status.name),
              updatedAt: Value<DateTime>(timestamp),
              lastEventSequence: const Value<int>(0),
            ),
          );
        }
        return RepositorySuccess<PersistedMatch>(
          await _loadMatchOrThrow(configuration.id),
        );
      });
    } catch (error) {
      return _operationFailure<PersistedMatch>(error);
    }
  }

  @override
  Future<RepositoryResult<PersistedMatch>> appendEvent({
    required String matchId,
    required ScoreEvent event,
    required int expectedSequence,
    required DateTime occurredAt,
  }) async {
    try {
      return await database.transaction(() async {
        final row =
            await (database.select(database.storedMatches)
                  ..where((candidate) => candidate.id.equals(matchId)))
                .getSingleOrNull();
        if (row == null) {
          return const RepositoryFailure<PersistedMatch>(
            code: RepositoryFailureCode.notFound,
            message: 'The match no longer exists.',
            isRecoverable: true,
          );
        }

        final persisted = await _loadMatchOrThrow(matchId);
        if (persisted.nextSequence != expectedSequence) {
          return RepositoryFailure<PersistedMatch>(
            code: RepositoryFailureCode.conflict,
            message:
                'The match changed before this action could be saved. '
                'Expected event $expectedSequence but found '
                '${persisted.nextSequence}.',
            isRecoverable: true,
          );
        }

        final transition = const MatchReducer().apply(persisted.state, event);
        if (transition case ScoreRejected(:final error)) {
          return RepositoryFailure<PersistedMatch>(
            code: RepositoryFailureCode.rejectedEvent,
            message: error.message,
            isRecoverable: true,
          );
        }
        final nextState = (transition as ScoreAccepted).state;
        final encoded = encodeScoreEvent(event);
        final timestamp = occurredAt.toUtc();

        await database
            .into(database.scoreEvents)
            .insert(
              ScoreEventsCompanion.insert(
                matchId: matchId,
                sequence: expectedSequence,
                eventType: encoded.type,
                payloadJson: encoded.payloadJson,
                occurredAt: timestamp,
              ),
            );
        await (database.update(
          database.storedMatches,
        )..where((candidate) => candidate.id.equals(matchId))).write(
          StoredMatchesCompanion(
            status: Value<String>(nextState.status.name),
            winner: Value<String?>(nextState.winner?.name),
            updatedAt: Value<DateTime>(timestamp),
            completedAt: Value<DateTime?>(
              nextState.isComplete ? timestamp : null,
            ),
            lastEventSequence: Value<int>(expectedSequence),
          ),
        );

        return RepositorySuccess<PersistedMatch>(
          await _loadMatchOrThrow(matchId),
        );
      });
    } catch (error) {
      return _operationFailure<PersistedMatch>(error);
    }
  }

  @override
  Future<RepositoryResult<PersistedMatch>> loadMatch(String matchId) async {
    try {
      final exists = await (database.select(
        database.storedMatches,
      )..where((row) => row.id.equals(matchId))).getSingleOrNull();
      if (exists == null) {
        return const RepositoryFailure<PersistedMatch>(
          code: RepositoryFailureCode.notFound,
          message: 'The match no longer exists.',
          isRecoverable: true,
        );
      }
      return RepositorySuccess<PersistedMatch>(
        await _loadMatchOrThrow(matchId),
      );
    } catch (error) {
      return _operationFailure<PersistedMatch>(error);
    }
  }

  @override
  Future<RepositoryResult<void>> deleteMatch(String matchId) async {
    try {
      return await database.transaction(() async {
        final links = await (database.select(
          database.matchParticipants,
        )..where((row) => row.matchId.equals(matchId))).get();
        final deleted = await (database.delete(
          database.storedMatches,
        )..where((row) => row.id.equals(matchId))).go();
        if (deleted == 0) {
          return const RepositoryFailure<void>(
            code: RepositoryFailureCode.notFound,
            message: 'The match no longer exists.',
            isRecoverable: true,
          );
        }
        for (final participantId
            in links.map((link) => link.participantId).toSet()) {
          final remainingReference =
              await (database.select(database.matchParticipants)
                    ..where((row) => row.participantId.equals(participantId))
                    ..limit(1))
                  .getSingleOrNull();
          if (remainingReference == null) {
            await (database.delete(
              database.participants,
            )..where((row) => row.id.equals(participantId))).go();
          }
        }
        return const RepositorySuccess<void>(null);
      });
    } catch (error) {
      return _operationFailure<void>(error);
    }
  }

  @override
  Future<RepositoryResult<int>> deleteAllMatches() async {
    try {
      return await database.transaction(() async {
        final removed = await database.delete(database.storedMatches).go();
        await database.delete(database.participants).go();
        return RepositorySuccess<int>(removed);
      });
    } catch (error) {
      return _operationFailure<int>(error);
    }
  }

  @override
  Future<RepositoryResult<MatchImportResult>> importMatches({
    required List<PersistedMatch> matches,
    required MatchImportMode mode,
  }) async {
    try {
      _validateImportPayload(matches);
      return await database.transaction(() async {
        final existingRows = await database
            .select(database.storedMatches)
            .get();
        final existingIds = existingRows.map((row) => row.id).toSet();
        final removed = mode == MatchImportMode.replace
            ? existingRows.length
            : 0;
        if (mode == MatchImportMode.replace) {
          await database.delete(database.storedMatches).go();
          await database.delete(database.participants).go();
          existingIds.clear();
        }

        var imported = 0;
        var skipped = 0;
        for (final match in matches) {
          if (existingIds.contains(match.configuration.id)) {
            skipped += 1;
            continue;
          }
          final creation = await createMatch(
            match.configuration,
            createdAt: match.createdAt,
          );
          if (creation case RepositoryFailure<PersistedMatch>(:final message)) {
            throw StateError(message);
          }
          var persisted = (creation as RepositorySuccess<PersistedMatch>).value;
          for (final savedEvent in match.events) {
            final appended = await appendEvent(
              matchId: match.configuration.id,
              event: savedEvent.event,
              expectedSequence: persisted.nextSequence,
              occurredAt: savedEvent.occurredAt,
            );
            if (appended case RepositoryFailure<PersistedMatch>(
              :final message,
            )) {
              throw StateError(message);
            }
            persisted = (appended as RepositorySuccess<PersistedMatch>).value;
          }
          imported += 1;
        }
        return RepositorySuccess<MatchImportResult>(
          MatchImportResult(
            imported: imported,
            skipped: skipped,
            removed: removed,
          ),
        );
      });
    } on FormatException catch (error) {
      return RepositoryFailure<MatchImportResult>(
        code: RepositoryFailureCode.invalidData,
        message: 'The backup failed replay validation. No data was changed.',
        isRecoverable: true,
        cause: error,
      );
    } catch (error) {
      return _operationFailure<MatchImportResult>(error);
    }
  }

  @override
  Future<RepositoryResult<PersistedMatch?>> loadResumableMatch() async {
    try {
      final query = database.select(database.storedMatches)
        ..where((row) => row.status.equals(MatchStatus.completed.name).not())
        ..orderBy(<OrderingTerm Function(StoredMatches)>[
          (row) => OrderingTerm.desc(row.updatedAt),
        ])
        ..limit(1);
      final row = await query.getSingleOrNull();
      return RepositorySuccess<PersistedMatch?>(
        row == null ? null : await _loadMatchOrThrow(row.id),
      );
    } catch (error) {
      return _operationFailure<PersistedMatch?>(error);
    }
  }

  @override
  Future<RepositoryResult<List<PersistedMatch>>> queryHistory(
    MatchHistoryFilter filter,
  ) async {
    try {
      final clauses = <String>[];
      final variables = <Variable<Object>>[];
      if (filter.fromInclusive != null) {
        clauses.add('created_at >= ?');
        variables.add(Variable<DateTime>(filter.fromInclusive!.toUtc()));
      }
      if (filter.toExclusive != null) {
        clauses.add('created_at < ?');
        variables.add(Variable<DateTime>(filter.toExclusive!.toUtc()));
      }
      if (filter.sport != null) {
        clauses.add('sport = ?');
        variables.add(Variable<String>(filter.sport!.name));
      }
      final participantName = filter.participantName?.trim().toLowerCase();
      if (participantName != null && participantName.isNotEmpty) {
        clauses.add('instr(participant_search_text, ?) > 0');
        variables.add(Variable<String>(participantName));
      }
      switch (filter.completion) {
        case MatchCompletionFilter.any:
          break;
        case MatchCompletionFilter.inProgress:
          clauses.add('status <> ?');
          variables.add(Variable<String>(MatchStatus.completed.name));
        case MatchCompletionFilter.completed:
          clauses.add('status = ?');
          variables.add(Variable<String>(MatchStatus.completed.name));
      }

      final where = clauses.isEmpty ? '' : ' WHERE ${clauses.join(' AND ')}';
      final ids = await database
          .customSelect(
            'SELECT id FROM matches$where ORDER BY updated_at DESC',
            variables: variables,
            readsFrom: <ResultSetImplementation<HasResultSet, Object?>>{
              database.storedMatches,
            },
          )
          .map((row) => row.read<String>('id'))
          .get();
      final matches = <PersistedMatch>[];
      for (final id in ids) {
        matches.add(await _loadMatchOrThrow(id));
      }
      return RepositorySuccess<List<PersistedMatch>>(
        List<PersistedMatch>.unmodifiable(matches),
      );
    } catch (error) {
      return _operationFailure<List<PersistedMatch>>(error);
    }
  }

  Future<void> _upsertParticipants(
    MatchConfiguration configuration,
    DateTime timestamp,
  ) async {
    for (final participant in <Participant>[
      ...configuration.sideOne.participants,
      ...configuration.sideTwo.participants,
    ]) {
      await database
          .into(database.participants)
          .insert(
            ParticipantsCompanion.insert(
              id: participant.id,
              name: participant.name,
              updatedAt: timestamp,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> _insertMatchParticipants(
    MatchConfiguration configuration,
  ) async {
    for (final side in <MatchSide>[
      configuration.sideOne,
      configuration.sideTwo,
    ]) {
      for (
        var position = 0;
        position < side.participants.length;
        position += 1
      ) {
        await database
            .into(database.matchParticipants)
            .insert(
              MatchParticipantsCompanion.insert(
                matchId: configuration.id,
                participantId: side.participants[position].id,
                participantName: side.participants[position].name,
                side: side.id.name,
                position: position,
              ),
            );
      }
    }
  }

  Future<PersistedMatch> _loadMatchOrThrow(String matchId) async {
    final row = await (database.select(
      database.storedMatches,
    )..where((candidate) => candidate.id.equals(matchId))).getSingle();
    if (row.rowSchemaVersion != 1) {
      throw FormatException(
        'Unsupported match row schema version ${row.rowSchemaVersion}.',
      );
    }

    final links =
        await (database.select(database.matchParticipants)
              ..where((link) => link.matchId.equals(matchId))
              ..orderBy(<OrderingTerm Function(MatchParticipants)>[
                (link) => OrderingTerm.asc(link.side),
                (link) => OrderingTerm.asc(link.position),
              ]))
            .get();
    final sideOneParticipants = <Participant>[];
    final sideTwoParticipants = <Participant>[];
    for (final link in links) {
      final value = Participant(
        id: link.participantId,
        name: link.participantName,
      );
      switch (_sideFromName(link.side)) {
        case SideId.one:
          sideOneParticipants.add(value);
        case SideId.two:
          sideTwoParticipants.add(value);
      }
    }

    final configuration = MatchConfiguration(
      id: row.id,
      sideOne: MatchSide(
        id: SideId.one,
        name: row.sideOneName,
        participants: sideOneParticipants,
      ),
      sideTwo: MatchSide(
        id: SideId.two,
        name: row.sideTwoName,
        participants: sideTwoParticipants,
      ),
      preset: resolveRulesPreset(row.presetId, row.presetVersion),
    );
    final eventRows =
        await (database.select(database.scoreEvents)
              ..where((event) => event.matchId.equals(matchId))
              ..orderBy(<OrderingTerm Function(ScoreEvents)>[
                (event) => OrderingTerm.asc(event.sequence),
              ]))
            .get();
    final events = <PersistedScoreEvent>[];
    for (var index = 0; index < eventRows.length; index += 1) {
      final eventRow = eventRows[index];
      if (eventRow.sequence != index) {
        throw FormatException(
          'Match $matchId has a non-contiguous event sequence at $index.',
        );
      }
      events.add(
        PersistedScoreEvent(
          sequence: eventRow.sequence,
          event: decodeScoreEvent(eventRow.eventType, eventRow.payloadJson),
          occurredAt: eventRow.occurredAt.toUtc(),
        ),
      );
    }
    if (row.lastEventSequence != events.length - 1) {
      throw FormatException(
        'Match $matchId event summary does not match its authoritative log.',
      );
    }

    final replay = const MatchReducer().replay(
      configuration,
      events.map((event) => event.event),
    );
    if (replay case ScoreRejected(:final error)) {
      throw FormatException(
        'Match $matchId contains an invalid event stream: ${error.message}',
      );
    }
    final state = (replay as ScoreAccepted).state;
    if (row.status != state.status.name || row.winner != state.winner?.name) {
      throw FormatException(
        'Match $matchId summary differs from deterministic event replay.',
      );
    }

    return PersistedMatch(
      configuration: configuration,
      events: events,
      state: state,
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      completedAt: row.completedAt?.toUtc(),
    );
  }

  void _validateImportPayload(List<PersistedMatch> matches) {
    final ids = <String>{};
    for (final match in matches) {
      final id = match.configuration.id;
      if (!ids.add(id)) {
        throw FormatException('Backup contains duplicate match id $id.');
      }
      final errors = match.configuration.validate();
      if (errors.isNotEmpty) {
        throw FormatException(errors.map((error) => error.message).join(' '));
      }
      if (match.updatedAt.isBefore(match.createdAt)) {
        throw FormatException('Match $id has invalid timestamps.');
      }
      var previousTime = match.createdAt.toUtc();
      for (var index = 0; index < match.events.length; index += 1) {
        final event = match.events[index];
        if (event.sequence != index ||
            event.occurredAt.toUtc().isBefore(previousTime)) {
          throw FormatException('Match $id has an invalid ordered event log.');
        }
        previousTime = event.occurredAt.toUtc();
      }
      final expectedUpdatedAt = match.events.isEmpty
          ? match.createdAt.toUtc()
          : match.events.last.occurredAt.toUtc();
      if (match.updatedAt.toUtc() != expectedUpdatedAt) {
        throw FormatException(
          'Match $id updated timestamp does not match replay.',
        );
      }
      final replay = const MatchReducer().replay(
        match.configuration,
        match.events.map((event) => event.event),
      );
      if (replay case ScoreRejected(:final error)) {
        throw FormatException('Match $id was rejected: ${error.message}');
      }
      final state = (replay as ScoreAccepted).state;
      if (state.status != match.state.status ||
          state.winner != match.state.winner) {
        throw FormatException('Match $id summary differs from replay.');
      }
      if (state.isComplete != (match.completedAt != null) ||
          (state.isComplete &&
              match.completedAt?.toUtc() != expectedUpdatedAt)) {
        throw FormatException('Match $id completion timestamp is invalid.');
      }
    }
  }

  RepositoryFailure<T> _operationFailure<T>(Object error) {
    return RepositoryFailure<T>(
      code: error is FormatException
          ? RepositoryFailureCode.invalidData
          : RepositoryFailureCode.unavailable,
      message: error is FormatException
          ? 'Saved match data could not be replayed safely. No data was changed.'
          : 'The scoring action could not be saved. Retry without closing the match.',
      isRecoverable: true,
      cause: error,
    );
  }

  SideId _sideFromName(String value) {
    return SideId.values.firstWhere(
      (side) => side.name == value,
      orElse: () => throw FormatException('Invalid persisted side: $value'),
    );
  }
}
