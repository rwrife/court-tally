# Changelog

All notable changes to Court Tally are documented here. The project follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and uses the app
version from `pubspec.yaml`.

## [1.0.0] - Unreleased

### Added

- Deterministic scoring for supported pickleball, tennis, badminton, and table-tennis presets.
- Crash-safe local match resume, filterable history, event replay, undo, and redo.
- Explicit versioned JSON backup/import and escaped CSV summary export.
- Accessible responsive scoring controls and automated semantics, text-scaling, focus, contrast, and reduced-motion checks.
- MIT source license, third-party notices, original branded icons, privacy policy, privacy manifest, and release documentation.
- CI-generated Android debug APK, unsigned release AAB with SHA-256 checksum, and non-distributable iOS simulator build.

### Known limitations

- TalkBack, VoiceOver, physical-device installation, outdoor glare, and one-handed-use checks remain pending until recorded on named hardware.
- CI artifacts are development or unsigned verification artifacts; no signed Android package or iOS archive is published by CI.
- TestFlight, Google Play, and App Store submission or approval have not been performed.
- JSON is the only lossless backup format; CSV files cannot be imported as backups.

[1.0.0]: https://github.com/rwrife/court-tally/releases/tag/v1.0.0

## Native SwiftUI conversion — 2026-09-19

- Replaced the active Flutter build with a native SwiftUI iPhone/iPad app and testable Swift scoring core; preserved the original implementation in `legacy/flutter`.
- Ported all six scoring presets, undo/redo, serving state, change-ends prompts, history, event replay, backup/import, and CSV export.
- Added atomic native storage and read-only migration from the Flutter v1 SQLite database.
- Added native core and UI tests and replaced Flutter CI with native iOS CI.
- Adopted the project owner's supplied app icon and prepared native 6.5-inch screenshots and App Store copy.
- Native minimum deployment target is iOS/iPadOS 16.0.
