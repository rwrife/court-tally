import 'package:flutter/material.dart';

import 'court_tally_theme.dart';
import 'pre_mvp_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
}

final class CourtTallyApp extends StatelessWidget {
  const CourtTallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Court Tally',
      debugShowCheckedModeBanner: false,
      theme: CourtTallyTheme.light(),
      darkTheme: CourtTallyTheme.dark(),
      routes: {AppRoutes.home: (context) => const PreMvpScreen()},
    );
  }
}
