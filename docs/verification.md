# Native verification

Recorded September 19, 2026 on macOS with Xcode 26.6 (17F113), iOS Simulator 26.5, and a dedicated iPhone 11 Pro Max simulator.

## Automated evidence

- **19 Swift core tests passed**, including all six presets, pickleball singles/doubles service changes, tennis advantage/tiebreak behavior, badminton's cap, table-tennis deuce service, end-change prompts, undo/redo, completion, JSON/CSV handling, atomic persistence, corruption preservation, and SQLite migration.
- The parity test compares **4,800 transitions** against fixtures produced by the original Dart reducer: six presets × singles/doubles × 400 events. It compares points, games, sets, service, prompts, undo/redo availability, completed games/sets, and winners.
- **Two XCUITest tests passed** on the 6.5-inch simulator: new-match setup using native keyboard navigation, scoring, undo, and history; plus history and data-tab controls.
- **Debug iOS simulator build passed** without Flutter or third-party runtime packages.
- **Release iOS device build passed** with code signing disabled; Debug screenshot fixtures are excluded from this configuration.
- The screenshot script checks every output's PNG dimensions against 1242 × 2688.

Commands are in the root README. Core test fixtures are stored in `Tests/CourtTallyCoreTests`; the preserved Dart implementation can regenerate parity fixtures with `dart scripts/generate-scoring-fixtures.dart`. Dart is not needed to build or test the native app.

Xcode's test runner emitted a post-test diagnostic-collection warning because the host's global developer directory points to Command Line Tools. The test execution itself passed; commands explicitly select Xcode via `DEVELOPER_DIR`.

## Remaining release checks

These results do not establish physical-device behavior, a signed upgrade from an installed Flutter release, full VoiceOver/TalkBack-style manual review, minimum-iOS-version runtime testing, App Store acceptance, or publication. Native minimum support is iOS 16.0; the runtime exercised here is iOS 26.5. Test iPad, landscape, very large Dynamic Type, Files destinations, and very large imported histories before release.

The native conversion is iOS/iPadOS only; archived Android code is not verified by native CI. Follow [the release guide](release.md) for signing and submission.
