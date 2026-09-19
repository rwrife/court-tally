# Release notes: Court Tally VERSION

## Summary

Describe the user-visible purpose of this release in plain language.

## Highlights

- Highlight one
- Highlight two

## Privacy and data ownership

- Court Tally remains local-first with no required account, analytics, ads, or backend.
- List every change to local storage, import/export, permissions, or privacy copy.
- State explicitly when there is no privacy-boundary change.

## Backup warning

Before uninstalling, clearing app data, replacing history, changing devices, or
installing an unverified build, export and verify a versioned JSON backup. CSV
is a summary only and cannot restore Court Tally data.

## Compatibility and migration

- Minimum Android: API 24
- Minimum iOS: 15.0
- Database schema: VERSION
- JSON backup schema: VERSION
- Describe migrations and rollback limitations.

## Verification evidence

Link the release commit and CI run. Record each stage separately:

- Linux format/analyze/unit/widget/host-integration tests:
- Android debug APK compile:
- Android unsigned release AAB plus SHA-256:
- Android signed package and named-device install/smoke:
- iOS unsigned simulator compile:
- iOS signed archive and named-device install/smoke:
- TalkBack / VoiceOver:
- TestFlight / Google Play / App Store submission and publication:

Use `PENDING — not run` for unavailable evidence. Never infer a later stage
from an earlier one.

## Known limitations

- List open product limitations.
- List pending physical-device and assistive-technology checks.
- List signing, TestFlight, or store-publication gaps.

## Included artifacts

For each attached file, provide its filename, type (debug/unsigned/signed),
platform/ABI where applicable, SHA-256 checksum, and provenance CI URL.
