import 'package:flutter/material.dart';

import 'court_tally_theme.dart';
import 'history_screen.dart';
import 'routes.dart';
import 'scoring_workflow_screen.dart';

final class CourtTallyApp extends StatelessWidget {
  const CourtTallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Court Tally',
      debugShowCheckedModeBanner: false,
      theme: CourtTallyTheme.light(),
      darkTheme: CourtTallyTheme.dark(),
      routes: <String, WidgetBuilder>{
        AppRoutes.home: (context) => const ScoringWorkflowScreen(),
        AppRoutes.history: (context) => const HistoryScreen(),
      },
    );
  }
}
