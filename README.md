# Court Tally

A native SwiftUI scorekeeper for pickleball, tennis, badminton, and table tennis. Start a match, tap the side that wins each rally, and let the app keep track of the score and serve. No account, ads, analytics, or internet connection required.

## Features

- Six verified rules presets across four sports; singles and doubles player names.
- Pickleball side-out scoring, including doubles service numbers.
- Tennis advantage scoring, sets, and 6–6 tiebreaks.
- Badminton win-by-two scoring with a 30-point cap.
- Table-tennis service rotation and deuce scoring.
- Large scoring controls, serving labels, change-ends prompts, and undo/redo.
- Automatic local saves, resumable matches, and history with player, sport, status, and date filters.
- Match details and event-by-event replay.
- Lossless JSON backup/import with a validated preview and explicit merge or replace; CSV summary export.
- Native navigation, system file pickers, dark mode, Dynamic Type, and VoiceOver labels and score announcements.

## Native iOS app

Open **[`ios-native/CourtTally.xcodeproj`](ios-native/CourtTally.xcodeproj)** in Xcode, select the **CourtTally** scheme, and run on an iPhone or iPad simulator. To run on a physical device, select your signing team in the app target.

- **Language/UI:** Swift and SwiftUI; no Flutter engine, Dart runtime, CocoaPods, or third-party runtime packages.
- **Deployment:** iOS/iPadOS **16.0+**. The native version raises the previous Flutter minimum from iOS 15 to iOS 16 for native navigation APIs.
- **Toolchain:** Xcode 26.x; Swift 5 language mode. Core package uses Swift tools 5.9+.
- **Bundle ID:** `com.rwrife.courttally`, unchanged from the Flutter app.
- **Storage:** validated, versioned JSON written atomically to private Application Support storage. Apple's SQLite library is used only to read the previous Flutter database during migration.
- **Icon:** the supplied Court Tally artwork, with generated iPhone, iPad, and 1024-pixel App Store assets.

The checked-in project is ready to open. If source files or project settings change, regenerate it using [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
xcodegen generate --spec ios-native/project.yml
```

If `xcode-select -p` points to Command Line Tools, select Xcode for the current shell:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```

## Build and test

From the repository root:

```sh
# Core scoring, storage, backup, and migration tests on macOS.
swift test

# Simulator app; no signing required.
xcodebuild -project ios-native/CourtTally.xcodeproj \
  -scheme CourtTally -configuration Debug -sdk iphonesimulator \
  -derivedDataPath build/native CODE_SIGNING_ALLOWED=NO build

# End-to-end tests (replace SIMULATOR_UDID with an available iPhone simulator).
xcodebuild -project ios-native/CourtTally.xcodeproj \
  -scheme CourtTally -destination 'platform=iOS Simulator,id=SIMULATOR_UDID' \
  -derivedDataPath build/native CODE_SIGNING_ALLOWED=NO test
```

Use `xcrun simctl list devices available` to find a simulator. See [verification](docs/verification.md) for recorded results and remaining release checks.

## Screenshots and App Store copy

The [6.5-inch screenshot set](docs/screenshots/iphone-6.5) contains portrait PNGs at **1242 × 2688**, captured directly from the native app on an iPhone 11 Pro Max simulator. The screenshots use fictional demo matches. See [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications).

| Live scoring | Match history | Your data |
|---|---|---|
| ![Pickleball scorecard](docs/screenshots/iphone-6.5/02-pickleball.png) | ![Local match history](docs/screenshots/iphone-6.5/06-history.png) | ![Backup and privacy controls](docs/screenshots/iphone-6.5/07-data.png) |

Regenerate the set on a 1242 × 2688 simulator:

```sh
bash scripts/capture-screenshots.sh SIMULATOR_UDID
```

Screenshot fixtures are compiled only into Debug builds and use an isolated temporary store. They cannot replace real match history. [App Store description, subtitle, promotional text, and keywords](docs/app-store.md) are ready to copy into App Store Connect.

## Existing Flutter users and backups

On first native launch, the app checks for `court_tally.sqlite` in its Application Support directory. It reads schema version 1 without modifying the database, validates every event stream, and writes the native store only after the entire migration succeeds. Unsupported or corrupt data blocks initialization rather than silently opening an empty store.

The original SQLite database remains as a recovery copy. **Your data → Remove Flutter recovery copy** explicitly removes it. Deleting individual native matches does not alter that original copy; **Delete all local history** removes both stores. Exported files and device backups remain under the user's control.

Existing version-1 Court Tally JSON backups can also be imported from Files. Merge adds unknown match IDs and keeps local conflicts; replace uses the imported history exactly. CSV is a summary, not a restorable backup. Keep a JSON backup before upgrading or changing devices.

## Repository layout

- `ios-native/` — SwiftUI app, asset catalog, Xcode project, and UI tests.
- `Sources/CourtTallyCore/` — scoring, backup validation, atomic storage, and SQLite migration.
- `Tests/CourtTallyCoreTests/` — native domain and persistence tests, including a Flutter backup fixture.
- `docs/` — native architecture, verification, store copy, and screenshots.
- `legacy/flutter/` — preserved Flutter/Android implementation, tests, and historical documentation. It is not part of the native build or CI.

This conversion delivers native **iOS/iPadOS**. The previous Android app remains in the legacy source; SwiftUI does not produce an Android application.

## Privacy and license

Match data stays on the device unless you export it. The native app requests no sensor, location, contact, camera, microphone, or notification permissions. See [PRIVACY.md](PRIVACY.md).

Code is available under the [MIT License](LICENSE). See [third-party notices](THIRD_PARTY_NOTICES.md) and [artwork provenance](assets/branding/LICENSE.md). Court Tally is for recreational scorekeeping, not officiating or tournament administration.
