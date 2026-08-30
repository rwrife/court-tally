# Mobile release checklist

A checked box must link to evidence for the exact release commit and artifact.
`PENDING — not run` is not a pass. Do not release merely because CI is green.

## Release identity

- [ ] Select the release commit and confirm its tree is clean.
- [ ] Replace `Unreleased` in `CHANGELOG.md` with the release date.
- [ ] Confirm `pubspec.yaml` marketing version and monotonically increasing build number.
- [ ] Confirm Android `com.rwrife.court_tally` and iOS `com.rwrife.courttally` match store records.
- [ ] Draft notes from `docs/release-notes-template.md`, including known limitations.

## Dependency gate: issue #6 evidence

- [ ] Confirm [#6](https://github.com/rwrife/court-tally/issues/6) is completed for the release commit or superseded by a newer verification run.
- [ ] Link green format, analyzer, unit, widget, host-integration, schema-fixture, accessibility, and responsiveness checks.
- [ ] Link the Android debug APK compile and unsigned iOS simulator compile.
- [ ] Review `docs/verification.md`; carry every pending physical or manual row into this release's evidence rather than treating it as passed.

## Legal, privacy, and data ownership

- [ ] Review `LICENSE`, `THIRD_PARTY_NOTICES.md`, generated Flutter notices, and every changed dependency license.
- [ ] Confirm all artwork provenance is recorded in `assets/branding/LICENSE.md`.
- [ ] Review `PRIVACY.md`, the iOS privacy manifest, Android manifests, and iOS usage descriptions against actual behavior.
- [ ] Confirm there is no mandatory account, analytics, advertising, backend, hidden network operation, or newly requested permission.
- [ ] Verify JSON export/import and CSV export remain explicit user actions.
- [ ] Put this warning in release notes: **Create and verify a JSON backup before uninstalling, clearing app data, replacing history, changing devices, or installing an unverified build. CSV is not a restorable backup.**

## Reproducible source checks

- [ ] Record `flutter --version` (supported: Flutter 3.47.0 / Dart 3.13.0).
- [ ] Run `flutter clean` and `flutter pub get --enforce-lockfile`.
- [ ] Run `git diff --exit-code -- pubspec.lock`.
- [ ] Run `dart format --output=none --set-exit-if-changed .`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test --coverage`.

## Android artifacts

- [ ] Link the CI Android debug APK and label it **development only**.
- [ ] Link the CI `court-tally-android-release-unsigned` AAB and its SHA-256; label it **unsigned / not installable / not published**.
- [ ] On a protected signing host, build the signed release AAB without exposing credentials.
- [ ] Verify the AAB signature and record its SHA-256.
- [ ] Build and install a signed release APK on a named physical device.
- [ ] Smoke offline start, score, terminate/resume, finish, history, JSON backup/import, CSV export, and deletion on that device.
- [ ] Run the pending TalkBack, text-size, orientation, glare, one-handed, and rapid-double-tap rows in `docs/verification.md`.
- [ ] If submitted, record Play Console validation, review, rollout, and public availability as separate results.

## iOS artifacts

- [ ] Record Xcode 26.x and iOS SDK versions from `xcodebuild -version`.
- [ ] Link the CI unsigned simulator compile and label it **non-distributable / not launched**.
- [ ] Launch the exact release candidate in a named simulator and record smoke results separately from compilation.
- [ ] On a protected signing host, create and validate a signed archive/IPA for `com.rwrife.courttally`.
- [ ] Install the signed release candidate on a named physical device.
- [ ] Smoke offline start, score, terminate/resume, finish, history, JSON backup/import, CSV export, and deletion on that device.
- [ ] Run the pending VoiceOver, text-size, orientation, glare, one-handed, and rapid-double-tap rows in `docs/verification.md`.
- [ ] If submitted, record TestFlight processing, internal/external testing, App Review, and public availability as separate results.

## Final decision and recovery

- [ ] Re-download every candidate artifact, verify its SHA-256, version, identifier, signature state, and provenance.
- [ ] Confirm release notes link the privacy policy, backup warning, known limitations, and actual—not inferred—verification evidence.
- [ ] Confirm a tested rollback or store-halt path and retention of signing credentials.
- [ ] Record the release approver and decision. If any required row remains pending, record **NO-GO** and the exact owner/blocker.
