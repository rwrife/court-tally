import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/presentation/app.dart';

void main() {
  runApp(const MainApp());
}

/// Root dependency-injection scope, kept separate for widget tests.
final class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: CourtTallyApp());
  }
}
