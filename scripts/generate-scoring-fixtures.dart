// Optional: regenerate cross-language parity fixtures from the preserved Dart reducer.
// Run with a Dart SDK: dart scripts/generate-scoring-fixtures.dart
import 'dart:convert';
import 'dart:io';
import '../legacy/flutter/lib/src/domain/scoring/scoring.dart';

void main() {
  final scenarios = <Object>[];
  for (var index = 0; index < RulesPreset.all.length; index++) {
    for (final doubles in [false, true]) {
      MatchSide team(SideId side) => MatchSide(id: side, name: side.name, participants: [
        Participant(id: '${side.name}-a', name: 'Player A'),
        if (doubles) Participant(id: '${side.name}-b', name: 'Player B'),
      ]);
      final config = MatchConfiguration(id: 'parity-$index-$doubles', sideOne: team(SideId.one), sideTwo: team(SideId.two), preset: RulesPreset.all[index]);
      const reducer = MatchReducer();
      var state = (reducer.create(config) as MatchCreated).state;
      var random = 81 + index;
      final frames = <Object>[];
      for (var step = 0; step < 400; step++) {
        random = (random * 1664525 + 1013904223) & 0xffffffff;
        final choice = random % 100;
        ScoreEvent event;
        String type;
        SideId? side;
        if (step == 0) { side = SideId.two; event = InitialServerChosen(side); type = 'initial_server_chosen'; }
        else if ((choice < 12 || state.isComplete) && state.pointHistory.isNotEmpty) { event = const PointUndone(); type = 'point_undone'; }
        else if (choice < 28 && state.redoStack.isNotEmpty) { event = const PointRedone(); type = 'point_redone'; }
        else if (state.sideChangePrompt != null) { event = const SidesChanged(); type = 'sides_changed'; }
        else { side = choice < 65 ? SideId.one : SideId.two; event = PointAwarded(side); type = 'point_awarded'; }
        state = (reducer.apply(state, event) as ScoreAccepted).state;
        frames.add({
          'type': type, 'side': side?.name,
          'points': [state.pointsOne, state.pointsTwo], 'games': [state.gamesOne, state.gamesTwo], 'sets': [state.setsOne, state.setsTwo],
          'server': state.server?.name, 'serviceNumber': state.pickleballServiceNumber,
          'gameNumber': state.gameNumber, 'setNumber': state.setNumber, 'tiebreak': state.isTiebreak,
          'prompt': state.sideChangePrompt != null, 'winner': state.winner?.name,
          'canUndo': state.pointHistory.isNotEmpty, 'canRedo': state.redoStack.isNotEmpty,
          'completedGames': state.completedGames.map((g) => [g.pointsOne, g.pointsTwo]).toList(),
          'completedSets': state.completedSets.map((s) => [s.gamesOne, s.gamesTwo]).toList(),
        });
      }
      scenarios.add({'presetIndex': index, 'doubles': doubles, 'frames': frames});
    }
  }
  File('Tests/CourtTallyCoreTests/dart-parity.json').writeAsStringSync(jsonEncode(scenarios));
}
