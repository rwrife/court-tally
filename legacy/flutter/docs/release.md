# Reproducible mobile builds and signing boundaries

Court Tally separates source verification, unsigned compilation, signing,
installation, beta distribution, and store publication. A result at one stage
is not evidence for any later stage.

## Supported release toolchain

| Component | Supported release configuration |
|---|---|
| Flutter | Flutter 3.47.0 stable, pinned by `.fvmrc` and CI |
| Dart | Dart 3.13.0, bundled with the pinned Flutter SDK |
| Android | Android API 36 compile/target SDK, API 24 minimum, Android Gradle Plugin 9.1.0, Java 17 |
| iOS | Xcode 26.x with the iOS 26 SDK, iOS 15.0 minimum deployment target |

The application version has the form `MAJOR.MINOR.PATCH+BUILD` in
`pubspec.yaml`. Android maps it to `versionName`/`versionCode`; iOS maps it to
`CFBundleShortVersionString`/`CFBundleVersion`. Increase the build number for
every package submitted to a platform service.

CI's macOS runner prints `xcodebuild -version` so every iOS compile records its
actual Xcode and SDK environment. A release operator must use Xcode 26.x; a
future toolchain change must update `.fvmrc`, CI, generated platform projects,
README.md, and this table together.

## Clean source verification

Start from a clean checkout of the release commit. Dependency resolution needs
network access; the built app does not.

```sh
flutter --version
flutter doctor -v
flutter clean
flutter pub get --enforce-lockfile
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

The supported Flutter version is 3.47.0. If a different local patch release is
used for exploratory checks, record that difference and rely on pinned CI for
release evidence.

## Android

The stable application ID and namespace are `com.rwrife.court_tally`. App icons
are committed for every legacy density plus an adaptive Android icon. API 24 is
the minimum and API 36 is the compile/target level.

### CI unsigned release App Bundle

CI has no signing credentials. With no `android/key.properties` file, the
release build deliberately has no signing configuration:

```sh
flutter clean
flutter pub get --enforce-lockfile
flutter build appbundle --release
cd build/app/outputs/bundle/release
sha256sum app-release.aab > SHA256SUMS
```

CI uploads `app-release.aab` and `SHA256SUMS` as
`court-tally-android-release-unsigned`. This AAB is compile evidence only. It is
not installable as an APK and is not a Play Console upload or publication.

### Local signing

Keep the upload keystore and passwords outside version control. Create a new
upload key only under the release owner's credential-retention policy:

```sh
keytool -genkeypair -v \
  -keystore "$HOME/.config/court-tally/upload-keystore.jks" \
  -alias upload -keyalg RSA -keysize 2048 -validity 10000
cp android/key.properties.example android/key.properties
```

Edit the ignored `android/key.properties` with the absolute keystore path and
credentials, then build:

```sh
flutter clean
flutter pub get --enforce-lockfile
flutter build appbundle --release --build-name=1.0.0 --build-number=1
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
sha256sum build/app/outputs/bundle/release/app-release.aab
```

`android/key.properties`, `*.jks`, `*.keystore`, passwords, service-account
JSON, and Play credentials must never be committed or uploaded as CI artifacts.
Use Play App Signing for production and retain the upload key securely.

For an installable signed APK test, use the same local signing setup:

```sh
flutter build apk --release --build-name=1.0.0 --build-number=1
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Record device model, Android version, artifact SHA-256, commit, installation
result, offline launch/resume/export/import smoke result, and TalkBack result.
No such physical-device result may be inferred from the CI AAB or debug APK.

## iOS

The stable bundle identifier is `com.rwrife.courttally`. The deployment target
is iOS 15.0. The app privacy manifest declares no tracking or collected data,
and `Info.plist` contains no unused permission usage descriptions.

### Unsigned simulator compile

On macOS with Xcode 26.x:

```sh
xcodebuild -version
flutter clean
flutter pub get --enforce-lockfile
flutter build ios --simulator --debug --no-codesign
```

CI runs this command and uploads no distributable iOS package. It proves only
that the simulator target compiles; it does not launch a simulator, install on
a phone, sign an archive, upload to TestFlight, or publish in the App Store.

### Signed archive / IPA

Certificates, provisioning profiles, Apple account credentials, and App Store
Connect API keys belong in the release operator's Keychain or protected CI
secret store, never in this repository. On a trusted macOS signing host:

```sh
flutter clean
flutter pub get --enforce-lockfile
flutter build ipa --release --build-name=1.0.0 --build-number=1
```

Alternatively open `ios/Runner.xcworkspace`, select the Runner target and the
release team/profile for `com.rwrife.courttally`, then use **Product → Archive**.
Validate the archive in Xcode Organizer before any upload. Record the selected
team/profile without exposing identifiers or credentials, archive checksum,
commit, Xcode version, and validation result.

A successful archive is not a physical-device test, TestFlight processing,
external beta review, App Store submission, review approval, or publication.
Record each separately in the release checklist.

## Artifact evidence stages

| Stage | Current automation | What it does not prove |
|---|---|---|
| Linux quality | Format, analyzer, unit/widget/host integration tests | Mobile installation or device behavior |
| Android debug APK | Development APK compile and CI artifact | Release mode, production signing, publication |
| Android unsigned release AAB | Release-mode AAB compile plus SHA-256 | Signature, install, Play upload or approval |
| iOS simulator build | Unsigned simulator-target compile | Simulator launch, device archive, signing |
| Signed Android/iOS package | Manual with protected credentials | Physical smoke, beta/store availability |
| Emulator/simulator launch | Manual, when recorded | Physical hardware or assistive-technology behavior |
| Physical-device and screen-reader checks | Pending until recorded | Store acceptance or publication |
| TestFlight / Play / App Store | Pending until independently recorded | Availability until the relevant store confirms it |

Use [`release-checklist.md`](release-checklist.md) for the final gate and
[`release-notes-template.md`](release-notes-template.md) for evidence links.
