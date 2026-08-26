import 'package:court_tally/src/application/data_transfer_gateway.dart';
import 'package:court_tally/src/application/match_repository.dart';
import 'package:court_tally/src/data/data_backup_codec.dart';
import 'package:court_tally/src/data/in_memory_match_repository.dart';
import 'package:court_tally/src/domain/scoring/scoring.dart';
import 'package:court_tally/src/presentation/app.dart';
import 'package:court_tally/src/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'filters history, opens event replay, and confirms one deletion',
    (tester) async {
      final repository = InMemoryMatchRepository();
      await repository.initialize();
      var alice = _success<PersistedMatch>(
        await repository.createMatch(
          _configuration('alice-match', 'Alice', 'Casey'),
          createdAt: DateTime.utc(2026, 8, 20),
          initialServer: SideId.one,
        ),
      );
      alice = _success<PersistedMatch>(
        await repository.appendEvent(
          matchId: alice.configuration.id,
          event: const PointAwarded(SideId.one),
          expectedSequence: alice.nextSequence,
          occurredAt: DateTime.utc(2026, 8, 20, 0, 1),
        ),
      );
      await repository.createMatch(
        _configuration('bob-match', 'Bob', 'Drew'),
        createdAt: DateTime.utc(2026, 8, 21),
        initialServer: SideId.two,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchRepositoryProvider.overrideWithValue(repository),
            dataTransferGatewayProvider.overrideWithValue(
              _FakeTransferGateway(),
            ),
          ],
          child: const CourtTallyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('History and data'));
      await tester.pumpAndSettle();

      expect(find.text('History and data'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Alice vs Casey'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Alice vs Casey'), findsOneWidget);
      expect(find.text('Bob vs Drew'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'Participant name contains'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Participant name contains'),
        'alice',
      );
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Apply filters'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Apply filters'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Alice vs Casey'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Alice vs Casey'), findsOneWidget);
      expect(find.text('Bob vs Drew'), findsNothing);
      await tester.tap(find.text('Alice vs Casey'));
      await tester.pumpAndSettle();

      expect(find.text('Match detail'), findsOneWidget);
      expect(find.text('Ordered event replay'), findsOneWidget);
      expect(find.text('Alice chosen to serve first'), findsOneWidget);
      expect(find.text('Point to Alice'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete this match'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this match?'), findsOneWidget);
      expect(
        find.textContaining('cannot be undone', findRichText: true),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Delete match'));
      await tester.pumpAndSettle();

      expect(find.text('No matches meet these filters.'), findsOneWidget);
      expect(
        await repository.loadMatch('alice-match'),
        isA<RepositoryFailure<PersistedMatch>>(),
      );
    },
  );

  testWidgets(
    'exports, previews merge import, and confirms all-history deletion',
    (tester) async {
      final source = InMemoryMatchRepository();
      await source.initialize();
      final imported = _success<PersistedMatch>(
        await source.createMatch(
          _configuration('imported-match', 'Import North', 'Import South'),
          createdAt: DateTime.utc(2026, 8, 22),
          initialServer: SideId.one,
        ),
      );
      final backup = const DataBackupCodec().encode(<PersistedMatch>[
        imported,
      ], exportedAt: DateTime.utc(2026, 8, 26));
      final repository = InMemoryMatchRepository();
      final gateway = _FakeTransferGateway(importSource: backup);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchRepositoryProvider.overrideWithValue(repository),
            dataTransferGatewayProvider.overrideWithValue(gateway),
          ],
          child: const CourtTallyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('History and data'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Export lossless JSON backup'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('JSON backup is versioned and lossless'),
        findsOneWidget,
      );
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Export lossless JSON backup'),
      );
      await tester.pumpAndSettle();
      expect(gateway.shared.single.fileName, endsWith('.json'));
      expect(gateway.shared.single.contents, contains('"schemaVersion": 1'));

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Export CSV summaries'),
      );
      await tester.pumpAndSettle();
      expect(gateway.shared.last.fileName, endsWith('.csv'));
      expect(gateway.shared.last.contents, startsWith('match_id,sport'));

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Import JSON backup'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Review validated backup'), findsOneWidget);
      expect(find.textContaining('Backup: 1 matches'), findsOneWidget);
      expect(find.textContaining('one transaction'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Merge backup'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Import North vs Import South'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Import North vs Import South'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Delete all local history'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Delete all local history'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete all local history?'), findsOneWidget);
      expect(find.textContaining('JSON backup first'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete all history'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('No matches meet these filters.'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('No matches meet these filters.'), findsOneWidget);
    },
  );
}

final class _FakeTransferGateway implements DataTransferGateway {
  _FakeTransferGateway({this.importSource});

  final String? importSource;
  final List<_SharedDocument> shared = <_SharedDocument>[];

  @override
  Future<String?> pickJsonBackup() async => importSource;

  @override
  Future<void> shareDocument({
    required String fileName,
    required String mimeType,
    required String contents,
  }) async {
    shared.add(
      _SharedDocument(
        fileName: fileName,
        mimeType: mimeType,
        contents: contents,
      ),
    );
  }
}

final class _SharedDocument {
  const _SharedDocument({
    required this.fileName,
    required this.mimeType,
    required this.contents,
  });

  final String fileName;
  final String mimeType;
  final String contents;
}

MatchConfiguration _configuration(String id, String one, String two) {
  return MatchConfiguration(
    id: id,
    sideOne: MatchSide(
      id: SideId.one,
      name: one,
      participants: <Participant>[Participant(id: '$id-one', name: one)],
    ),
    sideTwo: MatchSide(
      id: SideId.two,
      name: two,
      participants: <Participant>[Participant(id: '$id-two', name: two)],
    ),
    preset: RulesPreset.pickleballSingleGame15,
  );
}

T _success<T>(RepositoryResult<T> result) {
  if (result case RepositorySuccess<T>(:final value)) {
    return value;
  }
  final failure = result as RepositoryFailure<T>;
  fail('Unexpected repository failure: ${failure.message}; ${failure.cause}');
}
