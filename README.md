# Court Tally

**Court Tally is a local-first mobile scorekeeper for casual racket-sport players—run rule-aware matches, undo mistakes, and export history without an account or cloud service.**

## Overview

Court Tally turns a phone into a clear, dependable courtside scorecard for pickleball, tennis, badminton, and table tennis. Players choose a sport and rules preset, name the sides, then score a real-world match with two large controls. The app applies the selected sport's scoring rules, shows server/side state, preserves an undoable event log, and saves completed matches locally.

## Motivation

Paper scores are easy to lose, generic counters do not understand sport rules, and many sports apps require accounts or bundle social, coaching, and health features. Court Tally focuses on one job: make casual match scoring fast, legible, reversible, and private.

## Target users

- Casual pickleball, tennis, badminton, and table-tennis players
- Recreation-center organizers recording friendly matches
- Players who need large, high-contrast courtside controls
- Anyone who wants portable match history without an account

## Concrete use cases

- Run a best-of-three pickleball match with win-by-two and a configurable deciding-game target.
- Keep tennis game/set/tiebreak state without doing score arithmetic manually.
- Hand the phone to a spectator and use two large score buttons with one-tap undo.
- Review recent matches by sport, player, or date and export them as CSV or JSON.
- Resume an interrupted in-progress match after the app or phone restarts.

## Intended workflow

1. Open Court Tally; no sign-in or onboarding account is required.
2. Select a sport/rules preset and optionally customize its supported match settings.
3. Enter player or team names and choose the initial server/side.
4. Tap the large side controls after each point. The event log derives the score, server, game, set, and match state.
5. Undo or redo input mistakes; confirm before abandoning or finalizing a match.
6. Review the local match summary and export selected or all history when wanted.

## MVP features

- Rule-aware scoring for pickleball, tennis, badminton, and table tennis
- Validated rules presets plus supported match configuration
- Large two-side scoring surface, undo/redo, server indicator, and side-change prompts
- Crash-safe in-progress match persistence
- Local match history with basic filtering and detail views
- JSON and CSV export through the operating-system share/save sheet
- Screen-reader labels, scalable text, high contrast, color-independent state, and reduced-motion support
- Android and iOS builds from one Flutter codebase

## Non-goals

- Officiating, line calling, rankings, betting, or tournament-bracket management
- Fitness, calorie, injury, treatment, or other medical guidance
- Cloud accounts, public profiles, social feeds, or mandatory synchronization
- Wearable, voice-control, sensor, or live-stream integration in the MVP
- Replacing official rules or a qualified official in sanctioned competition

## Platforms and technology

- **Targets:** Android and iOS phones; tablet layouts are supported responsively but not a separate MVP experience.
- **Framework:** Flutter with Dart for one accessible mobile UI and deterministic domain tests.
- **State/domain:** Pure Dart immutable match state plus an append-only score-event reducer.
- **Storage:** SQLite through Drift, behind repository interfaces so domain tests do not need a device.
- **Export:** Versioned JSON and tabular CSV written only after an explicit user action.

See [PLAN.md](PLAN.md) for architecture and delivery order.

## Privacy, permissions, and data ownership

Court Tally is offline-first. Match names, score events, presets, and history remain in the app's local database. The MVP has no analytics, ads, account, remote API, or network dependency.

- **Baseline permissions:** none beyond ordinary app-local storage.
- **Export:** the app invokes the platform share/save sheet only when the user requests export; the user chooses the destination.
- **Import/backup:** versioned JSON backup/import is planned with validation, preview, and explicit conflict behavior.
- **Notifications:** not required by the MVP. If reminders are added later, notification permission must be optional and requested in context.
- **Sensors/location/contacts/microphone:** not used.
- Uninstalling the app may remove its local data unless the user exported a backup first.

## Accessibility expectations

All scoring actions must expose semantic labels and state to TalkBack and VoiceOver. Interactive targets should be at least 48 logical pixels, text must respect system scaling, focus order must be predictable, and no score/server state may rely on color alone. Landscape and portrait scoring views must remain operable with one hand or from a courtside stand.

## Non-medical limitation

Court Tally records recreational scores only. It does not provide medical, fitness, injury, treatment, emergency, or safety advice.

## Current status and milestones

**Status: documentation scaffold and issue backlog only.** No production app, build, package, or test result is claimed yet.

1. Bootstrap Flutter project, quality gates, and CI.
2. Implement and test the rule-aware scoring domain.
3. Add local persistence and resumable matches.
4. Deliver the accessible live scoring workflow.
5. Add history, export/import, and privacy controls.
6. Verify platforms and prepare reproducible release artifacts.

## Development quickstart

Prerequisites (once the app skeleton lands):

- Flutter stable SDK and Dart included with Flutter
- Android Studio/SDK for Android builds
- Xcode on macOS for iOS builds

Expected commands:

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Until the project-skeleton issue is complete, this repository contains product and implementation documentation only.

## License

A project license will be selected and added before the first public release; source code must not be represented as release-ready until that is done.
