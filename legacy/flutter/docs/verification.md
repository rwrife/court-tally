# Platform verification and accessibility test matrix

Court Tally separates reproducible automated checks from evidence that requires a
real Android or iOS environment. A green CI run proves only the commands and
artifacts named below. It does not prove a launched emulator or simulator, a
physical-device session, screen-reader speech, signing, TestFlight, or store
publication.

## Automated matrix

| Surface | Automated coverage | Runner and evidence boundary |
|---|---|---|
| Scoring rules | Every named preset reaches completion; pickleball side-out, tennis deuce/advantage, badminton 30-point cap, table-tennis deuce, change-ends, undo/redo, and deterministic replay are asserted. | `flutter test`; host-side Dart/Flutter test process. |
| Lifecycle integration | Create → score → persist → close SQLite → reopen → resume → undo/redo → complete → history query → JSON/CSV export → staged import → replay equivalence. | `test/integration/full_match_lifecycle_test.dart`; real Drift/native SQLite on the test host, not an installed mobile app. |
| Preset persistence | All six named presets across all four sports complete through the repository and survive JSON backup decoding. | `test/integration/all_sports_persistence_test.dart`; host-side integration test. |
| Schema compatibility | A committed SQL fixture for every SQLite schema version opens with the current repository and preserves its match. A committed JSON fixture for every backup schema version decodes and imports. | `test/data/schema_version_fixture_test.dart`; currently SQLite v1 and backup v1. Add a fixture before incrementing either version. |
| Accessibility | Semantics labels and state, live regions, explicit focus order, 48-pixel actions, 160-pixel score targets, 200–250% text, portrait/landscape layout, reduced-motion media settings, and key light/dark color-pair contrast. | Widget tests on the Flutter test renderer; no TalkBack/VoiceOver speech or touch ergonomics claim. |
| Responsiveness sample | 21,000 reducer transitions and 100 transactional Drift appends are timed and operation counts/state are asserted. | `test/performance/responsiveness_test.dart`; diagnostic host sample, not a device benchmark or release threshold. |
| Android debug compile | `flutter build apk --debug` and uploaded non-release APK. | GitHub-hosted Linux runner; development artifact only, not a signed release. |
| Android release compile | `flutter build appbundle --release`, signature-entry absence check, SHA-256, and uploaded AAB/checksum. | GitHub-hosted Linux runner; unsigned release-mode artifact only, not installable or published. |
| iOS compile | `flutter build ios --simulator --debug --no-codesign` and uploaded `Runner.app` bundle. | GitHub-hosted macOS/Xcode 26 runner; unsigned simulator-target compile only, not a launched simulator or distributable archive. |

The permanent CI workflow uses Flutter 3.47.0 and runs:

```sh
flutter pub get --enforce-lockfile
git diff --exit-code
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter build apk --debug
flutter build appbundle --release
# macOS job only
flutter build ios --simulator --debug --no-codesign
```

Run the lifecycle tests alone with:

```sh
flutter test test/integration
```

## Responsiveness method

Run:

```sh
flutter test test/performance/responsiveness_test.dart --reporter expanded
```

The test prints two `RESPONSIVENESS` lines containing operation counts, elapsed
microseconds, average microseconds per operation, runtime, and storage type. The
reducer sample creates 1,000 badminton matches and applies an initial-server
event plus 20 alternating rally events to each. The persistence sample creates
five matches in Drift's in-memory native SQLite database and transactionally
appends 20 alternating rally events to each.

Timing is intentionally diagnostic: shared CI load, host architecture, debug
test compilation, and in-memory SQLite all affect it. Do not copy these values
into product latency claims, infer physical-device performance, or fail CI on an
unstudied wall-clock threshold. Preserve the operation counts and state
assertions so regressions cannot make a faster but incomplete sample pass.

## Manual Android and iOS checklist

**Status for every row below: PENDING — not run.** Update a row only after the
check is performed on the named device/build. Record date, commit SHA, device,
OS version, app artifact, assistive-technology version/settings, result, and a
link to findings. “Pending” is not a pass.

| Check | Android / TalkBack | iOS / VoiceOver |
|---|---|---|
| Launch offline, create a match, score, background/terminate, relaunch, and resume the exact state | PENDING — not run | PENDING — not run |
| Complete a representative match, open history/detail, export JSON and CSV, then import JSON | PENDING — not run | PENDING — not run |
| Hear side name, score, serving/receiving state, accepted point, undo/redo, change-ends prompt, completion, and error announcements | PENDING — not run | PENDING — not run |
| Traverse setup, both score controls, change-ends confirmation, undo, redo, abandon, history, and dialogs in a predictable order | PENDING — not run | PENDING — not run |
| Operate at the largest supported system text size in portrait and landscape without losing a critical action | PENDING — not run | PENDING — not run |
| Verify reduced-motion setting introduces no required animation or delayed state | PENDING — not run | PENDING — not run |
| Verify server, disabled, error, winner, and change-ends state remain understandable without color | PENDING — not run | PENDING — not run |
| Check outdoor glare/high-contrast readability without claiming a laboratory contrast measurement | PENDING — not run | PENDING — not run |
| Reach the primary score, undo, and change-ends controls one-handed in both orientations | PENDING — not run | PENDING — not run |
| Deliberately double-tap rapidly; confirm one pending write cannot produce duplicate points and legitimate later taps still work | PENDING — not run | PENDING — not run |
| Exercise external keyboard/switch traversal where supported | PENDING — not run | PENDING — not run |

## Artifact and release boundaries

- The Android CI artifacts are a debug APK and an unsigned release-mode AAB
  with a SHA-256 checksum. Neither is a signed Play package, Play Console
  upload, installation result, or publication result.
- The iOS CI artifact is an unsigned simulator-target app bundle. It is not a
  launched simulator test, physical-device build, signed archive, TestFlight
  upload, or App Store submission.
- Physical-device, TalkBack, VoiceOver, signing, and publication evidence remains
  pending until separately recorded. See [`release.md`](release.md) and the
  explicit [`release checklist`](release-checklist.md).
