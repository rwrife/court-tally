import 'dart:convert';

import '../domain/scoring/scoring.dart';

final class EncodedScoreEvent {
  const EncodedScoreEvent({required this.type, required this.payloadJson});

  final String type;
  final String payloadJson;
}

EncodedScoreEvent encodeScoreEvent(ScoreEvent event) {
  final (type, payload) = switch (event) {
    InitialServerChosen(:final side) => (
      'initial_server_chosen',
      <String, Object?>{'side': side.name},
    ),
    PointAwarded(:final side) => (
      'point_awarded',
      <String, Object?>{'side': side.name},
    ),
    SidesChanged() => ('sides_changed', <String, Object?>{}),
    PointUndone() => ('point_undone', <String, Object?>{}),
    PointRedone() => ('point_redone', <String, Object?>{}),
  };
  return EncodedScoreEvent(type: type, payloadJson: jsonEncode(payload));
}

ScoreEvent decodeScoreEvent(String type, String payloadJson) {
  final decoded = jsonDecode(payloadJson);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Score-event payload must be a JSON object.');
  }

  SideId side() {
    if (decoded.length != 1 || !decoded.containsKey('side')) {
      throw FormatException('$type payload must contain only side.');
    }
    final value = decoded['side'];
    return SideId.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => throw FormatException('Invalid score-event side: $value'),
    );
  }

  ScoreEvent emptyEvent(ScoreEvent event) {
    if (decoded.isNotEmpty) {
      throw FormatException('$type payload must be empty.');
    }
    return event;
  }

  return switch (type) {
    'initial_server_chosen' => InitialServerChosen(side()),
    'point_awarded' => PointAwarded(side()),
    'sides_changed' => emptyEvent(const SidesChanged()),
    'point_undone' => emptyEvent(const PointUndone()),
    'point_redone' => emptyEvent(const PointRedone()),
    _ => throw FormatException('Unknown score-event type: $type'),
  };
}

RulesPreset resolveRulesPreset(String id, int version) {
  return RulesPreset.all.firstWhere(
    (preset) => preset.id == id && preset.version == version,
    orElse: () => throw FormatException(
      'Unsupported persisted rules preset $id v$version.',
    ),
  );
}

String normalizedParticipantSearch(MatchConfiguration configuration) {
  return <Participant>[
    ...configuration.sideOne.participants,
    ...configuration.sideTwo.participants,
  ].map((participant) => participant.name.trim().toLowerCase()).join('\u001f');
}
