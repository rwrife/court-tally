import 'dart:convert';

import '../application/match_repository.dart';
import '../domain/scoring/scoring.dart';
import 'match_persistence_codec.dart';

const courtTallyBackupFormat = 'court-tally-backup';
const courtTallyBackupSchemaVersion = 1;

final class DecodedBackup {
  DecodedBackup({
    required this.exportedAt,
    required List<PersistedMatch> matches,
  }) : matches = List<PersistedMatch>.unmodifiable(matches);

  final DateTime exportedAt;
  final List<PersistedMatch> matches;
}

/// Lossless, versioned Court Tally JSON backup codec.
///
/// Decoding is deliberately strict: the complete document, all references,
/// timestamps, and every event stream are validated before a value is returned.
final class DataBackupCodec {
  const DataBackupCodec();

  String encode(List<PersistedMatch> matches, {required DateTime exportedAt}) {
    final orderedMatches = [...matches]
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
    final currentParticipants = <String, String>{};
    for (final match in orderedMatches) {
      for (final participant in <Participant>[
        ...match.configuration.sideOne.participants,
        ...match.configuration.sideTwo.participants,
      ]) {
        currentParticipants[participant.id] = participant.name;
      }
    }

    final document = <String, Object?>{
      'format': courtTallyBackupFormat,
      'schemaVersion': courtTallyBackupSchemaVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'presets': RulesPreset.all.map(_encodePreset).toList(growable: false),
      'participants':
          currentParticipants.entries
              .map(
                (entry) => <String, Object?>{
                  'id': entry.key,
                  'name': entry.value,
                },
              )
              .toList(growable: false)
            ..sort(
              (left, right) =>
                  (left['id']! as String).compareTo(right['id']! as String),
            ),
      'matches': orderedMatches.map(_encodeMatch).toList(growable: false),
    };
    return const JsonEncoder.withIndent('  ').convert(document);
  }

  DecodedBackup decode(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('Backup is not valid JSON: ${error.message}');
    }
    final root = _object(decoded, 'backup');
    if (_string(root, 'format') != courtTallyBackupFormat) {
      throw const FormatException('This is not a Court Tally backup.');
    }
    final version = _integer(root, 'schemaVersion');
    if (version != courtTallyBackupSchemaVersion) {
      throw FormatException(
        'Unsupported backup schema version $version. '
        'This app supports version $courtTallyBackupSchemaVersion.',
      );
    }
    final exportedAt = _date(root, 'exportedAt');

    final presetKeys = <String>{};
    for (final value in _list(root, 'presets')) {
      final encoded = _object(value, 'preset');
      final preset = resolveRulesPreset(
        _string(encoded, 'id'),
        _integer(encoded, 'version'),
      );
      _validatePreset(encoded, preset);
      if (!presetKeys.add('${preset.id}@${preset.version}')) {
        throw FormatException('Preset ${preset.id} is duplicated.');
      }
    }

    final participants = <String, String>{};
    for (final value in _list(root, 'participants')) {
      final participant = _object(value, 'participant');
      final id = _nonEmptyString(participant, 'id');
      final name = _nonEmptyString(participant, 'name');
      if (participants.containsKey(id)) {
        throw FormatException('Participant $id is duplicated.');
      }
      participants[id] = name;
    }

    final matches = <PersistedMatch>[];
    final matchIds = <String>{};
    for (final value in _list(root, 'matches')) {
      final match = _decodeMatch(
        _object(value, 'match'),
        participants,
        presetKeys,
      );
      if (!matchIds.add(match.configuration.id)) {
        throw FormatException(
          'Match ${match.configuration.id} is duplicated in the backup.',
        );
      }
      matches.add(match);
    }
    return DecodedBackup(exportedAt: exportedAt, matches: matches);
  }

  Map<String, Object?> _encodePreset(RulesPreset preset) => <String, Object?>{
    'id': preset.id,
    'version': preset.version,
    'name': preset.name,
    'sport': preset.sport.name,
    'unitsToWin': preset.unitsToWin,
    'pointsToWinGame': preset.pointsToWinGame,
    'winBy': preset.winBy,
    'pointCap': preset.pointCap,
    'gamesToWinSet': preset.gamesToWinSet,
    'tiebreakAtGames': preset.tiebreakAtGames,
    'tiebreakPoints': preset.tiebreakPoints,
  };

  Map<String, Object?> _encodeMatch(PersistedMatch match) {
    Map<String, Object?> side(MatchSide value) => <String, Object?>{
      'name': value.name,
      'participants': value.participants
          .map(
            (participant) => <String, Object?>{
              'id': participant.id,
              'nameAtMatch': participant.name,
            },
          )
          .toList(growable: false),
    };

    return <String, Object?>{
      'id': match.configuration.id,
      'presetId': match.configuration.preset.id,
      'presetVersion': match.configuration.preset.version,
      'sideOne': side(match.configuration.sideOne),
      'sideTwo': side(match.configuration.sideTwo),
      'createdAt': match.createdAt.toUtc().toIso8601String(),
      'updatedAt': match.updatedAt.toUtc().toIso8601String(),
      'completedAt': match.completedAt?.toUtc().toIso8601String(),
      'status': match.state.status.name,
      'winner': match.state.winner?.name,
      'events': match.events
          .map((saved) {
            final encoded = encodeScoreEvent(saved.event);
            return <String, Object?>{
              'sequence': saved.sequence,
              'type': encoded.type,
              'payload': jsonDecode(encoded.payloadJson),
              'occurredAt': saved.occurredAt.toUtc().toIso8601String(),
            };
          })
          .toList(growable: false),
    };
  }

  PersistedMatch _decodeMatch(
    Map<String, dynamic> encoded,
    Map<String, String> participants,
    Set<String> presetKeys,
  ) {
    final id = _nonEmptyString(encoded, 'id');
    final presetId = _nonEmptyString(encoded, 'presetId');
    final presetVersion = _integer(encoded, 'presetVersion');
    if (!presetKeys.contains('$presetId@$presetVersion')) {
      throw FormatException(
        'Match $id references a preset missing from the backup.',
      );
    }
    final preset = resolveRulesPreset(presetId, presetVersion);
    final configuration = MatchConfiguration(
      id: id,
      sideOne: _decodeSide(
        _object(encoded['sideOne'], 'sideOne'),
        SideId.one,
        participants,
      ),
      sideTwo: _decodeSide(
        _object(encoded['sideTwo'], 'sideTwo'),
        SideId.two,
        participants,
      ),
      preset: preset,
    );
    final configurationErrors = configuration.validate();
    if (configurationErrors.isNotEmpty) {
      throw FormatException(
        'Match $id has an invalid configuration: '
        '${configurationErrors.map((error) => error.message).join(' ')}',
      );
    }

    final createdAt = _date(encoded, 'createdAt');
    final updatedAt = _date(encoded, 'updatedAt');
    if (updatedAt.isBefore(createdAt)) {
      throw FormatException('Match $id has an updated time before creation.');
    }
    final completedAt = _nullableDate(encoded, 'completedAt');
    final events = <PersistedScoreEvent>[];
    var previousTime = createdAt;
    for (final value in _list(encoded, 'events')) {
      final event = _object(value, 'event');
      final sequence = _integer(event, 'sequence');
      if (sequence != events.length) {
        throw FormatException(
          'Match $id event sequence must be contiguous from zero.',
        );
      }
      final occurredAt = _date(event, 'occurredAt');
      if (occurredAt.isBefore(previousTime)) {
        throw FormatException('Match $id event times are out of order.');
      }
      previousTime = occurredAt;
      final payload = _object(event['payload'], 'event payload');
      events.add(
        PersistedScoreEvent(
          sequence: sequence,
          event: decodeScoreEvent(
            _nonEmptyString(event, 'type'),
            jsonEncode(payload),
          ),
          occurredAt: occurredAt,
        ),
      );
    }
    final expectedUpdatedAt = events.isEmpty
        ? createdAt
        : events.last.occurredAt;
    if (updatedAt != expectedUpdatedAt) {
      throw FormatException(
        'Match $id updated time does not match its ordered event log.',
      );
    }

    final replay = const MatchReducer().replay(
      configuration,
      events.map((event) => event.event),
    );
    if (replay case ScoreRejected(:final error)) {
      throw FormatException(
        'Match $id contains an invalid event stream: ${error.message}',
      );
    }
    final state = (replay as ScoreAccepted).state;
    if (_nonEmptyString(encoded, 'status') != state.status.name) {
      throw FormatException('Match $id status does not match event replay.');
    }
    final winner = _nullableString(encoded, 'winner');
    if (winner != state.winner?.name) {
      throw FormatException('Match $id winner does not match event replay.');
    }
    if (state.isComplete) {
      if (completedAt == null || completedAt != updatedAt) {
        throw FormatException(
          'Completed match $id must use its final event time as completedAt.',
        );
      }
    } else if (completedAt != null) {
      throw FormatException('Unfinished match $id cannot have completedAt.');
    }

    return PersistedMatch(
      configuration: configuration,
      events: events,
      state: state,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }

  MatchSide _decodeSide(
    Map<String, dynamic> encoded,
    SideId side,
    Map<String, String> participants,
  ) {
    final values = <Participant>[];
    for (final value in _list(encoded, 'participants')) {
      final participant = _object(value, 'match participant');
      final id = _nonEmptyString(participant, 'id');
      if (!participants.containsKey(id)) {
        throw FormatException('Match references unknown participant $id.');
      }
      values.add(
        Participant(id: id, name: _nonEmptyString(participant, 'nameAtMatch')),
      );
    }
    return MatchSide(
      id: side,
      name: _nonEmptyString(encoded, 'name'),
      participants: values,
    );
  }

  void _validatePreset(Map<String, dynamic> encoded, RulesPreset preset) {
    final expected = _encodePreset(preset);
    for (final entry in expected.entries) {
      if (encoded[entry.key] != entry.value) {
        throw FormatException(
          'Preset ${preset.id} does not match the supported version.',
        );
      }
    }
  }
}

Map<String, dynamic> _object(Object? value, String label) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$label must be a JSON object.');
  }
  return value;
}

List<dynamic> _list(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value is! List<dynamic>) {
    throw FormatException('$key must be a JSON array.');
  }
  return value;
}

String _string(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value is! String) {
    throw FormatException('$key must be a string.');
  }
  return value;
}

String _nonEmptyString(Map<String, dynamic> object, String key) {
  final value = _string(object, key);
  if (value.trim().isEmpty) {
    throw FormatException('$key must not be empty.');
  }
  return value;
}

String? _nullableString(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('$key must be a string or null.');
  }
  return value;
}

int _integer(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value is! int) {
    throw FormatException('$key must be an integer.');
  }
  return value;
}

DateTime _date(Map<String, dynamic> object, String key) {
  final value = _string(object, key);
  return _parseUtc(value, key);
}

DateTime? _nullableDate(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('$key must be a UTC ISO-8601 timestamp or null.');
  }
  return _parseUtc(value, key);
}

DateTime _parseUtc(String value, String key) {
  if (!value.endsWith('Z')) {
    throw FormatException('$key must be an explicit UTC ISO-8601 timestamp.');
  }
  try {
    final parsed = DateTime.parse(value);
    if (!parsed.isUtc) {
      throw const FormatException();
    }
    return parsed;
  } on FormatException {
    throw FormatException('$key must be an explicit UTC ISO-8601 timestamp.');
  }
}
