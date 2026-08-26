# Court Tally implementation plan

## Scope

The MVP is an offline Android/iOS scorekeeper for real-world casual matches in four racket sports: pickleball, tennis, badminton, and table tennis. It must apply explicit rules presets, let users correct input safely, resume an interrupted match, retain local history, and export owned data without requiring an account.

The architecture deliberately separates scoring rules from Flutter widgets and persistence. A point input is appended as an event; current score is derived by a deterministic reducer. This makes undo/redo, crash recovery, audit history, and sport-specific testing tractable.

## Architecture

```text
Flutter presentation
  ├─ setup / preset editor
  ├─ live score surface
  ├─ match summary / history
  └─ privacy / export settings
          │
Application services
  ├─ MatchController
  ├─ HistoryService
  └─ ExportImportService
          │
Pure Dart domain
  ├─ MatchState + ScoreEvent
  ├─ Ruleset interface
  ├─ PickleballRules / TennisRules
  ├─ BadmintonRules / TableTennisRules
  └─ deterministic reducer + validation
          │
Repository interfaces
  ├─ Drift/SQLite local implementation
  ├─ in-memory test implementation
  └─ versioned JSON/CSV codecs
```

### Core model

- `Sport`, `Side`, `Participant`, `RulesPreset`, and sport-specific validated options
- `Match`, `Game`, `Set`, and derived `MatchState`
- Append-only `ScoreEvent` values such as point awarded, point reversed, initial server chosen, sides changed, and match finalized
- A reducer that accepts the prior state plus an event and either returns a valid next state or rejects the transition
- Schema and export format versions from the first persisted revision

## Technology choices

- **Flutter/Dart:** one mobile codebase, strong widget accessibility support, mature Android/iOS packaging, and fast pure-Dart tests.
- **Riverpod:** explicit dependency injection and testable application state without coupling domain classes to widgets.
- **Drift + SQLite:** transactional local persistence, migrations, and queryable history while retaining an interface suitable for in-memory tests.
- **Freezed/json_serializable (evaluate during bootstrap):** reduce immutable-model and codec boilerplate; avoid them if generated-code complexity outweighs value.
- **GitHub Actions:** Linux analysis/tests plus platform build jobs where licensing and runner support permit. iOS packaging still requires macOS and signing credentials; unsigned simulator/build verification must be distinguished from distributable signing.

## Local data, export, and backup

SQLite stores participants, presets, match metadata, and ordered score events. The in-progress match is committed after every accepted input in one transaction. Derived state may be cached but must be reproducible from events.

- JSON backup is versioned and includes presets, participants, matches, and event history.
- Import validates schema and every event stream before writing; users see a preview and choose merge or replace.
- CSV is a portable summary export, not a lossless restore format.
- Export uses the platform share/save sheet after an explicit action.
- No hidden telemetry or network synchronization is permitted in the MVP.

## Permissions

The baseline app requests no location, contacts, health, Bluetooth, microphone, camera, or notification access. File/share access occurs through platform pickers rather than broad storage permission. Any later reminder feature must remain optional and request notification permission in context.

## Accessibility

- TalkBack/VoiceOver semantics and announcements for current score, server, game/set completion, and undo result
- Minimum 48 logical-pixel targets and a scoring layout usable in portrait and landscape
- Dynamic text support without clipping critical score or action controls
- High-contrast themes, color-independent indicators, and reduced-motion behavior
- Keyboard/switch-control traversal on supported devices
- Widget tests for semantics labels, focus order, text scaling, and key contrast-sensitive states

## Milestones and dependency order

### M1 — Reproducible foundation

Create the Flutter package layout, pin supported SDK versions, add formatting/linting/analyzer rules, unit/widget test setup, and CI. Establish pure domain, application, persistence, and presentation boundaries.

### M2 — Scoring domain

Implement the event model, reducer contract, and sport rules one at a time. Add table-driven examples for ordinary games and edge cases: deuce/win-by-two, caps where supported, tennis tiebreaks, service changes, deciding games, invalid transitions, undo, and completion.

### M3 — Local repository and recovery (completed)

Drift schema/migrations, transactional event persistence, in-progress recovery,
presets, and history queries are implemented behind an application port.
Reducer replay is the authoritative source of persisted match state; see
[`docs/local-data-schema.md`](docs/local-data-schema.md) for the schema and
failure contract.

### M4 — Primary scoring workflow (completed)

The app now provides validated sport/preset and singles/doubles setup, local
resume, two large score controls, deterministic server and change-ends state,
undo/redo, confirmed completion and abandonment boundaries, responsive
portrait/landscape layout, live-region semantics, and reduced-motion-safe
behavior. Automated widget tests cover the setup-to-finish and relaunch paths;
see [`docs/accessibility.md`](docs/accessibility.md) for the automated/manual
evidence boundary.

### M5 — History and data ownership (completed)

Filterable match summaries, detail/event replay, confirmed one/all-history
deletion, versioned lossless JSON backup/import with staged validation and
transactional merge/replace, escaped CSV summaries, platform picker/share
boundaries, and in-app privacy copy are implemented. See
[`docs/data-ownership.md`](docs/data-ownership.md).

### M6 — Platform verification and release

Run analyzer/tests and Android/iOS builds, exercise migration/export fixtures, perform an accessibility checklist, document signing, and produce reproducible release notes/artifacts without claiming store publication until it actually occurs.

## Testing strategy

- **Domain unit tests:** table-driven official-rule examples and boundary cases for every ruleset; property-style invariants such as nonnegative score, deterministic replay, and no events after completion.
- **Persistence tests:** migrations, transaction interruption, corrupt/invalid import rejection, merge/replace behavior, and replay equivalence.
- **Codec tests:** golden JSON fixtures, schema-version handling, escaped CSV values, and round trips.
- **Widget tests:** setup validation, large scoring controls, undo/redo, completion prompts, semantics, focus order, dynamic type, orientation, and reduced motion.
- **Integration tests:** start → score → terminate/relaunch → resume → finish → export, on Android and iOS simulators where available.
- **Manual checks:** TalkBack and VoiceOver, sunlight/high-contrast readability, one-handed use, and accidental double-tap behavior. Manual checks must be reported as manual, not automated evidence.

## Packaging and distribution

- Android: signed App Bundle/APK instructions, with unsigned CI build artifacts for verification until release credentials exist.
- iOS: Xcode archive/signing documentation; CI may validate simulator or unsigned builds separately from App Store-ready archives.
- Versioning: semantic app version plus explicit database/export schema versions.
- Distribution targets: GitHub Releases for appropriate development artifacts, then Google Play/TestFlight/App Store only after privacy metadata, screenshots, signing, and platform review are complete.
- A license, privacy statement, changelog, and reproducible build notes are release blockers.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Sport rules contain subtle variants | Ship named, immutable presets; cite rule sources in code/docs; test each supported option and reject unsupported combinations. |
| A tap is missed or duplicated courtside | Large controls, immediate semantic/haptic feedback where enabled, event-level undo/redo, and input debounce that does not hide valid rapid actions. |
| Persisted derived state diverges | Treat ordered events as authoritative and verify deterministic replay in tests. |
| Import corrupts history | Parse and validate into staging, preview changes, then apply transactionally with backup/rollback behavior. |
| Screen becomes unusable with large text or glare | Accessibility tests, responsive layout, high-contrast mode, and device/manual checks. |
| Cross-platform packaging is mistaken for store readiness | Report analyzer, test, build, signing, and store-submission evidence as separate stages. |

## Explicit non-goals

- Tournament brackets, leagues, ratings, matchmaking, social feeds, or cloud sync
- Official officiating, betting, or dispute resolution
- Medical, fitness, training-load, injury, or emergency claims
- Wearables, speech, camera, or sensor-driven automatic scoring in the MVP
- Desktop/web feature parity or a server backend
- Supporting every rules variation before the four documented presets are correct and tested
