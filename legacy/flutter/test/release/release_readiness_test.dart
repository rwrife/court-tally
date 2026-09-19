import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void _expectFile(String path) {
  expect(File(path).existsSync(), isTrue, reason: '$path must be committed');
}

(int, int) _pngSize(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(24), reason: '$path is truncated');
  expect(bytes.sublist(0, 8), <int>[137, 80, 78, 71, 13, 10, 26, 10]);
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (data.getUint32(16), data.getUint32(20));
}

void main() {
  group('release legal and privacy contract', () {
    test('ships source, dependency, and original-asset licenses', () {
      for (final path in <String>[
        'LICENSE',
        'THIRD_PARTY_NOTICES.md',
        'assets/branding/LICENSE.md',
        'assets/branding/court-tally-icon.svg',
      ]) {
        _expectFile(path);
      }

      expect(_read('LICENSE'), contains('MIT License'));
      final notices = _read('THIRD_PARTY_NOTICES.md');
      for (final dependency in <String>[
        'Flutter',
        'drift',
        'flutter_riverpod',
        'path_provider',
        'file_selector',
        'share_plus',
        'SQLite',
      ]) {
        expect(notices, contains(dependency));
      }
      expect(_read('assets/branding/LICENSE.md'), contains('original'));
    });

    test('publishes an explicit local-only privacy policy', () {
      _expectFile('PRIVACY.md');
      final privacy = _read('PRIVACY.md');
      for (final statement in <String>[
        'no account',
        'no analytics',
        'no advertising',
        'local',
        'JSON',
        'CSV',
        'uninstall',
        'backup',
      ]) {
        expect(privacy.toLowerCase(), contains(statement.toLowerCase()));
      }
    });

    test('declares no tracking, collection, or unused permissions', () {
      _expectFile('ios/Runner/PrivacyInfo.xcprivacy');
      final privacyManifest = _read('ios/Runner/PrivacyInfo.xcprivacy');
      expect(privacyManifest, contains('NSPrivacyTracking'));
      expect(privacyManifest, contains('<false/>'));
      expect(privacyManifest, contains('NSPrivacyCollectedDataTypes'));

      final androidManifest = _read('android/app/src/main/AndroidManifest.xml');
      final infoPlist = _read('ios/Runner/Info.plist');
      for (final forbidden in <String>[
        'android.permission.INTERNET',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.READ_CONTACTS',
        'android.permission.RECORD_AUDIO',
        'android.permission.CAMERA',
        'android.permission.POST_NOTIFICATIONS',
        'NSCameraUsageDescription',
        'NSMicrophoneUsageDescription',
        'NSLocationWhenInUseUsageDescription',
        'NSContactsUsageDescription',
      ]) {
        expect('$androidManifest\n$infoPlist', isNot(contains(forbidden)));
      }
    });
  });

  group('release packaging contract', () {
    test('uses stable identifiers and pubspec-driven versions', () {
      final pubspec = _read('pubspec.yaml');
      expect(pubspec, contains('version: 1.0.0+1'));

      final gradle = _read('android/app/build.gradle.kts');
      expect(gradle, contains('applicationId = "com.rwrife.court_tally"'));
      expect(gradle, contains('versionCode = flutter.versionCode'));
      expect(gradle, contains('versionName = flutter.versionName'));
      expect(gradle, contains('key.properties'));
      expect(gradle, contains('signingConfigs'));

      final xcodeProject = _read('ios/Runner.xcodeproj/project.pbxproj');
      expect(xcodeProject, contains('com.rwrife.courttally'));
      expect(xcodeProject, contains('PrivacyInfo.xcprivacy'));
      final infoPlist = _read('ios/Runner/Info.plist');
      expect(infoPlist, contains(r'$(FLUTTER_BUILD_NAME)'));
      expect(infoPlist, contains(r'$(FLUTTER_BUILD_NUMBER)'));
      expect(_read('.gitignore'), contains('key.properties'));
    });

    test('ships complete original Android and iOS icon sets', () {
      final androidIcons = <String, int>{
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
      };
      for (final entry in androidIcons.entries) {
        final path = 'android/app/src/main/res/${entry.key}/ic_launcher.png';
        _expectFile(path);
        expect(_pngSize(path), (entry.value, entry.value));
      }

      final iconDirectory = Directory(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset',
      );
      final catalog = jsonDecode(
        File('${iconDirectory.path}/Contents.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final images = catalog['images']! as List<dynamic>;
      for (final rawImage in images) {
        final image = rawImage as Map<String, dynamic>;
        final filename = image['filename']! as String;
        final size = double.parse((image['size']! as String).split('x').first);
        final scale = double.parse(
          (image['scale']! as String).replaceFirst('x', ''),
        );
        final pixels = (size * scale).round();
        final path = '${iconDirectory.path}/$filename';
        _expectFile(path);
        expect(_pngSize(path), (pixels, pixels));
      }
    });

    test('documents and automates reproducible evidence stages', () {
      for (final path in <String>[
        'CHANGELOG.md',
        'docs/release.md',
        'docs/release-checklist.md',
        'docs/release-notes-template.md',
      ]) {
        _expectFile(path);
      }

      final release = _read('docs/release.md');
      for (final required in <String>[
        'Flutter 3.47.0',
        'Android API 36',
        'Java 17',
        'Xcode 26',
        'iOS 15.0',
        'flutter clean',
        'flutter pub get --enforce-lockfile',
        'flutter build appbundle --release',
        'flutter build ipa --release',
        'credentials',
      ]) {
        expect(release, contains(required));
      }

      final checklist = _read('docs/release-checklist.md');
      expect(checklist, contains('#6'));
      expect(checklist, contains('physical device'));
      expect(checklist, contains('TalkBack'));
      expect(checklist, contains('VoiceOver'));
      expect(checklist, contains('backup'));

      final workflow = _read('.github/workflows/ci.yml');
      expect(workflow, contains('android-release-unsigned'));
      expect(workflow, contains('flutter build appbundle --release'));
      expect(workflow, contains('SHA256SUMS'));
      expect(workflow, contains('court-tally-android-release-unsigned'));
      expect(workflow, contains('iOS simulator build (non-distributable)'));
    });
  });
}
