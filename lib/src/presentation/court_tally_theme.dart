import 'package:flutter/material.dart';

abstract final class CourtTallyTheme {
  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF005F56),
      brightness: brightness,
      contrastLevel: 0.5,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      useMaterial3: true,
    );
  }
}
