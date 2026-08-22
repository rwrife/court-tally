import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain sources remain independent of Flutter and outer layers', () {
    final domainDirectory = Directory('lib/src/domain');
    final violations = <String>[];
    const forbiddenImports = <String>[
      "import 'dart:ui'",
      "import 'package:flutter/",
      "import 'package:flutter_riverpod/",
      "import '../application/",
      "import '../data/",
      "import '../presentation/",
    ];

    for (final entity in domainDirectory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final source = entity.readAsStringSync();
      for (final forbiddenImport in forbiddenImports) {
        if (source.contains(forbiddenImport)) {
          violations.add('${entity.path}: $forbiddenImport');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Domain code must be pure Dart. Violations: $violations',
    );
  });
}
