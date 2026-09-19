# Native iOS release

1. Run `swift test` and the CourtTally UI test scheme on an iPhone simulator.
2. Verify scoring, restart/resume, JSON export/import, CSV export, VoiceOver, large text, portrait/landscape, and iPad layout on physical devices.
3. Verify an upgrade from the Flutter app using the same signing team and `com.rwrife.courttally` bundle identifier. Keep a JSON backup first. Fixture migration tests do not substitute for a signed upgrade test.
4. In Xcode select the CourtTally target, configure the release team, and increase `CURRENT_PROJECT_VERSION` for each upload. Keep `project.yml` and the generated project consistent.
5. Archive for a generic iOS device, validate in Organizer, then upload to TestFlight or App Store Connect.
6. Use `docs/app-store.md`, the 6.5-inch screenshot set, and the supplied icon assets. Add iPad screenshots and a publicly hosted privacy policy URL for submission.
7. Confirm App Store privacy answers against the shipping binary. The app itself has no tracking or collection service.

No signing credentials are stored in this repository. A simulator build is not a signed archive, physical-device validation, TestFlight upload, or App Store release.
