# Scoring workflow accessibility contract

Court Tally's primary setup and live-scoring workflow is designed for courtside use with TalkBack, VoiceOver, switch access, keyboards, dynamic text, and reduced-motion settings. This document records the implemented behavior and keeps automated evidence separate from device testing.

## Interaction and layout

- The setup screen exposes four sport choices. Pickleball's three supported match formats remain explicit named presets; unsupported variants are not approximated.
- Singles/doubles, side names, optional partner names, and the initial server are labeled and validated before the configuration and server are persisted atomically.
- Each score control has a minimum height of 160 logical pixels. Undo, redo, side-change confirmation, finish, and abandon actions use padded Material targets of at least 48 logical pixels.
- Landscape places the two scoring controls side by side. Portrait stacks them. The surrounding surface scrolls instead of clipping actions at large text sizes.
- Server state is written as `SERVING` or `RECEIVING` and repeated in the score summary; it never relies on color.

## Screen-reader semantics and focus

- Score controls announce the side name, current point score, and serving/receiving state.
- A live region reports an accepted point, server, undo, redo, side-change acknowledgement, and persistence failure.
- Rule-generated change-of-ends prompts are textual and disable both point controls until acknowledged.
- Ordered traversal is: side one score, side two score, pending side-change acknowledgement, undo, redo, then abandon. Dialog actions follow the platform's Material traversal.
- Completion and abandonment use explicit modal confirmation boundaries. Abandonment states that it permanently deletes the in-progress event stream.

## Duplicate input and reduced motion

The workflow sets a busy state before every repository write. Additional callbacks while that write is pending are ignored, and the repository's expected-sequence contract provides a second duplicate-write guard. There are no custom score, route, or completion animations. When `MediaQuery.disableAnimations` is true, the same immediate state transition is used.

## Automated evidence

`test/presentation/scoring_workflow_test.dart` covers:

- setup validation, four sport choices, pickleball formats, doubles fields, and initial server;
- point entry, side-change blocking, undo/redo, live-region labels, and rapid duplicate input;
- persisted relaunch/resume, recovery of a legacy match still awaiting its server, confirmed completion into history, and confirmed abandonment;
- portrait and landscape layout at 250% text scaling with animations disabled;
- large score targets and explicit serving/receiving semantics.

`test/data/match_repository_test.dart` verifies explicit deletion in both in-memory and Drift adapters, including cascade removal of the event stream.

## Manual evidence not claimed

Automated widget tests do **not** prove a physical-device run, sunlight readability, one-handed reach, switch-control behavior, TalkBack speech, VoiceOver speech, platform focus announcements, haptics, or assistive-technology regressions. Those Android/iOS manual checks remain part of the platform-verification milestone and must be reported separately when actually performed.
