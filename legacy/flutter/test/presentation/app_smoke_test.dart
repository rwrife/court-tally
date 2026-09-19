import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/presentation/app.dart';
import 'package:court_tally/src/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the local-first match setup route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRepositoryProvider.overrideWithValue(InMemoryMatchRepository()),
        ],
        child: const CourtTallyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Court Tally'), findsOneWidget);
    expect(find.text('Start a match'), findsOneWidget);
    expect(find.bySemanticsLabel('New match setup'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
