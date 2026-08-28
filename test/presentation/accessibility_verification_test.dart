import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:court_tally/src/presentation/app.dart';
import 'package:court_tally/src/presentation/court_tally_theme.dart';
import 'package:court_tally/src/presentation/dependencies.dart';
import 'package:court_tally/src/presentation/scoring_workflow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'score semantics and explicit focus order survive reduced motion',
    (tester) async {
      final repository = InMemoryMatchRepository();
      _success<void>(await repository.initialize());
      var match = _success<PersistedMatch>(
        await repository.createMatch(
          _configuration('accessibility-match'),
          createdAt: _origin,
          initialServer: SideId.one,
        ),
      );
      match = _success<PersistedMatch>(
        await repository.appendEvent(
          matchId: match.configuration.id,
          event: const PointAwarded(SideId.one),
          expectedSequence: match.nextSequence,
          occurredAt: _origin.add(const Duration(seconds: 1)),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [matchRepositoryProvider.overrideWithValue(repository)],
          child: const MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(2.0),
              disableAnimations: true,
            ),
            child: CourtTallyApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          'Award point to North. Current score 1. Serving.',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Award point to South. Current score 0. Receiving.',
        ),
        findsOneWidget,
      );
      expect(
        MediaQuery.disableAnimationsOf(
          tester.element(find.byType(ScoringWorkflowScreen)),
        ),
        isTrue,
      );
      expect(
        MediaQuery.textScalerOf(
          tester.element(find.byType(ScoringWorkflowScreen)),
        ).scale(10),
        20,
      );

      expect(
        _numericOrder(tester, find.byKey(const ValueKey<String>('score-one'))),
        1,
      );
      expect(
        _numericOrder(tester, find.byKey(const ValueKey<String>('score-two'))),
        2,
      );
      expect(
        _numericOrder(tester, find.widgetWithText(OutlinedButton, 'Undo')),
        4,
      );
      expect(
        _numericOrder(tester, find.widgetWithText(OutlinedButton, 'Redo')),
        5,
      );
      expect(
        _numericOrder(
          tester,
          find.widgetWithText(OutlinedButton, 'Abandon match'),
        ),
        6,
      );
      expect(tester.takeException(), isNull);
    },
  );

  test('light and dark key color pairs exceed 4.5:1 contrast', () {
    for (final theme in <ThemeData>[
      CourtTallyTheme.light(),
      CourtTallyTheme.dark(),
    ]) {
      final scheme = theme.colorScheme;
      expect(
        _contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.brightness} onSurface/surface',
      );
      expect(
        _contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.brightness} onPrimary/primary',
      );
      expect(
        _contrast(scheme.onSecondaryContainer, scheme.secondaryContainer),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.brightness} score-control colors',
      );
    }
  });
}

double _numericOrder(WidgetTester tester, Finder descendant) {
  final ancestor = find.ancestor(
    of: descendant,
    matching: find.byType(FocusTraversalOrder),
  );
  expect(ancestor, findsOneWidget);
  final order = tester.widget<FocusTraversalOrder>(ancestor).order;
  expect(order, isA<NumericFocusOrder>());
  return (order as NumericFocusOrder).order;
}

double _contrast(Color first, Color second) {
  final lighter = first.computeLuminance() > second.computeLuminance()
      ? first
      : second;
  final darker = identical(lighter, first) ? second : first;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}

final _origin = DateTime.utc(2026, 8, 25);

MatchConfiguration _configuration(String id) => MatchConfiguration(
  id: id,
  sideOne: MatchSide(
    id: SideId.one,
    name: 'North',
    participants: <Participant>[Participant(id: '$id-north', name: 'North')],
  ),
  sideTwo: MatchSide(
    id: SideId.two,
    name: 'South',
    participants: <Participant>[Participant(id: '$id-south', name: 'South')],
  ),
  preset: RulesPreset.badmintonBestOfThree,
);

T _success<T>(RepositoryResult<T> result) {
  if (result case RepositorySuccess<T>(:final value)) {
    return value;
  }
  final failure = result as RepositoryFailure<T>;
  fail('Unexpected repository failure: ${failure.message}; ${failure.cause}');
}
