import 'package:court_tally/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the labeled pre-MVP empty state', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Court Tally'), findsOneWidget);
    expect(find.text('Pre-MVP foundation'), findsOneWidget);
    expect(find.bySemanticsLabel('Court Tally pre-MVP status'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
