import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:court_tally/src/presentation/app.dart';
import 'package:court_tally/src/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads an accessible new-match setup when no match is active', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start a match'), findsOneWidget);
    expect(find.bySemanticsLabel('New match setup'), findsOneWidget);
    expect(
      find.text('No account or network connection required.'),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
  testWidgets('validates names before creating a configured match', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Start match'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Start match'));
    await tester.pump();

    expect(find.text('Enter a name for side 1.'), findsOneWidget);
    expect(find.text('Enter a name for side 2.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 1 name'),
      'North',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 2 name'),
      'South',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Start match'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Start match'));
    await tester.pumpAndSettle();

    expect(find.text('Live match'), findsOneWidget);
    expect(find.text('North vs South'), findsOneWidget);
    expect(find.text('Serving: North'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Award point to North')),
      findsOneWidget,
    );
  });
  testWidgets('offers four sports, doubles names, and initial-server choice', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<Sport>, 'Pickleball'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tennis'), findsOneWidget);
    expect(find.text('Badminton'), findsOneWidget);
    expect(find.text('Table tennis'), findsOneWidget);
    await tester.tap(find.text('Tennis'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Doubles'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(4));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 1 name'),
      'North',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 1 partner'),
      'Nora',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 2 name'),
      'South',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 2 partner'),
      'Sam',
    );
    await tester.scrollUntilVisible(
      find.text('Side 2 serves first'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Side 2 serves first'));
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Start match'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Start match'));
    await tester.pumpAndSettle();

    expect(find.text('Tennis advantage sets: best of 3'), findsOneWidget);
    expect(find.text('Serving: South'), findsOneWidget);
  });

  testWidgets('records points and exposes undo and redo with live semantics', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 1 name'),
      'North',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Side 2 name'),
      'South',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Start match'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Start match'));
    await tester.pumpAndSettle();

    final scoreControl = find.bySemanticsLabel(RegExp('Award point to North'));
    final scoreSemantics = tester.getSemantics(scoreControl);
    expect(
      scoreSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(scoreControl);
    await tester.pumpAndSettle();

    expect(find.text('Points: 1–0'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Score updated. North 1, South 0. Serving North.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Points: 0–0'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Undid last point. North 0, South 0.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Redo'));
    await tester.pumpAndSettle();
    expect(find.text('Points: 1–0'), findsOneWidget);

    final history = await repository.queryHistory(const MatchHistoryFilter());
    final matches = (history as RepositorySuccess<List<PersistedMatch>>).value;
    expect(matches.single.events, hasLength(4));
  });

  testWidgets('recovers a persisted match that is still awaiting its server', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await repository.initialize();
    final configuration = _configuration(
      id: 'awaiting-server-match',
      preset: RulesPreset.tennisBestOfThree,
    );
    await repository.createMatch(
      configuration,
      createdAt: DateTime.utc(2026, 8, 25),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume match setup'), findsOneWidget);
    expect(find.text('Choose the initial server to continue.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'North serves first'));
    await tester.pumpAndSettle();

    expect(find.text('Live match'), findsOneWidget);
    expect(find.text('Serving: North'), findsOneWidget);
    final loaded = await repository.loadMatch(configuration.id);
    final resumed = (loaded as RepositorySuccess<PersistedMatch>).value;
    expect(resumed.events.single.event, isA<InitialServerChosen>());
  });

  testWidgets('restores the persisted in-progress match after relaunch', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await repository.initialize();
    final configuration = _configuration(
      id: 'resume-match',
      preset: RulesPreset.badmintonBestOfThree,
    );
    var match = (await repository.createMatch(
      configuration,
      createdAt: DateTime.utc(2026, 8, 25),
    ) as RepositorySuccess<PersistedMatch>).value;
    match = await _append(
      repository,
      match,
      const InitialServerChosen(SideId.two),
    );
    await _append(repository, match, const PointAwarded(SideId.one));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live match'), findsOneWidget);
    expect(find.text('North vs South'), findsOneWidget);
    expect(find.text('Points: 1–0'), findsOneWidget);
    expect(find.text('Serving: North'), findsOneWidget);
  });

  testWidgets('blocks scoring until a side-change prompt is confirmed', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await repository.initialize();
    final configuration = _configuration(
      id: 'side-change-match',
      preset: RulesPreset.pickleballSingleGame15,
    );
    var match = (await repository.createMatch(
      configuration,
      createdAt: DateTime.utc(2026, 8, 25),
    ) as RepositorySuccess<PersistedMatch>).value;
    match = await _append(
      repository,
      match,
      const InitialServerChosen(SideId.one),
    );
    for (var point = 0; point < 7; point += 1) {
      match = await _append(repository, match, const PointAwarded(SideId.one));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('score-one')));
    await tester.pumpAndSettle();

    expect(find.text('Change ends'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Score updated. North 8, South 0. Serving North. '
        'Change ends. Change ends at the deciding-game midpoint.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey<String>('score-one')))
          .onPressed,
      isNull,
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Confirm sides changed'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Change ends'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey<String>('score-one')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('ignores a rapid duplicate score action while saving', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await repository.initialize();
    final configuration = _configuration(
      id: 'duplicate-tap-match',
      preset: RulesPreset.badmintonBestOfThree,
    );
    final match = (await repository.createMatch(
      configuration,
      createdAt: DateTime.utc(2026, 8, 25),
    ) as RepositorySuccess<PersistedMatch>).value;
    await _append(repository, match, const InitialServerChosen(SideId.one));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('score-one')),
    );
    button.onPressed!();
    button.onPressed!();
    await tester.pumpAndSettle();

    final loaded = await repository.loadMatch(configuration.id);
    final saved = (loaded as RepositorySuccess<PersistedMatch>).value;
    expect(saved.state.pointsOne, 1);
    expect(saved.events, hasLength(2));
  });

  testWidgets(
    'keeps large targets operable in landscape and portrait at 250% text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 500);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = InMemoryMatchRepository();
      await repository.initialize();
      final configuration = _configuration(
        id: 'responsive-match',
        preset: RulesPreset.tableTennisBestOfFive,
      );
      final match = (await repository.createMatch(
        configuration,
        createdAt: DateTime.utc(2026, 8, 25),
      ) as RepositorySuccess<PersistedMatch>).value;
      await _append(repository, match, const InitialServerChosen(SideId.one));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [matchRepositoryProvider.overrideWithValue(repository)],
          child: const MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(2.5),
              disableAnimations: true,
            ),
            child: CourtTallyApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final one = find.byKey(const ValueKey<String>('score-one'));
      final two = find.byKey(const ValueKey<String>('score-two'));
      expect(tester.getSize(one).height, greaterThanOrEqualTo(160));
      expect(tester.getTopLeft(one).dy, tester.getTopLeft(two).dy);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(400, 900);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(two).dy, greaterThan(tester.getTopLeft(one).dy));
      expect(find.bySemanticsLabel(RegExp('Serving')), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('requires confirmation before abandoning and deleting a match', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await repository.initialize();
    final configuration = _configuration(
      id: 'abandon-match',
      preset: RulesPreset.tableTennisBestOfFive,
    );
    final match = (await repository.createMatch(
      configuration,
      createdAt: DateTime.utc(2026, 8, 25),
    ) as RepositorySuccess<PersistedMatch>).value;
    await _append(repository, match, const InitialServerChosen(SideId.one));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Abandon match'));
    await tester.pumpAndSettle();
    expect(find.text('Abandon this match?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Keep scoring'));
    await tester.pumpAndSettle();
    expect(find.text('Live match'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Abandon match'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Abandon and delete'));
    await tester.pumpAndSettle();

    expect(find.text('Start a match'), findsOneWidget);
    final loaded = await repository.loadMatch(configuration.id);
    expect(loaded, isA<RepositoryFailure<PersistedMatch>>());
  });

  testWidgets('confirms completion and keeps the finished match in history', (
    tester,
  ) async {
    final repository = InMemoryMatchRepository();
    await repository.initialize();
    final configuration = _configuration(
      id: 'finish-match',
      preset: RulesPreset.pickleballSingleGame15,
    );
    var match = (await repository.createMatch(
      configuration,
      createdAt: DateTime.utc(2026, 8, 25),
    ) as RepositorySuccess<PersistedMatch>).value;
    match = await _append(
      repository,
      match,
      const InitialServerChosen(SideId.one),
    );
    for (var point = 0; point < 14; point += 1) {
      match = await _append(repository, match, const PointAwarded(SideId.one));
      if (match.state.sideChangePrompt != null) {
        match = await _append(repository, match, const SidesChanged());
      }
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Points: 14–0'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('score-one')));
    await tester.pumpAndSettle();

    expect(find.text('Match complete'), findsOneWidget);
    expect(find.text('North won the match.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Finish match'));
    await tester.pumpAndSettle();

    expect(find.text('Start a match'), findsOneWidget);
    final history = await repository.queryHistory(
      const MatchHistoryFilter(completion: MatchCompletionFilter.completed),
    );
    final completed =
        (history as RepositorySuccess<List<PersistedMatch>>).value;
    expect(completed.single.state.winner, SideId.one);
    expect(completed.single.completedAt, isNotNull);
  });
}

MatchConfiguration _configuration({
  required String id,
  required RulesPreset preset,
}) {
  return MatchConfiguration(
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
    preset: preset,
  );
}

Future<PersistedMatch> _append(
  MatchRepository repository,
  PersistedMatch match,
  ScoreEvent event,
) async {
  final result = await repository.appendEvent(
    matchId: match.configuration.id,
    event: event,
    expectedSequence: match.nextSequence,
    occurredAt: DateTime.utc(2026, 8, 25, 0, match.nextSequence),
  );
  return (result as RepositorySuccess<PersistedMatch>).value;
}
