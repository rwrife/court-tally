# Local data schema and recovery

Court Tally stores match data only in the app's private SQLite database through
Drift. The shipped application does not require an account, network service,
analytics SDK, or broad storage permission. Export and import remain separate,
explicit user actions.

## Version 1 schema

Drift's `PRAGMA user_version` is the database schema version. The initial
version is **1**. Each `matches` row also carries `schema_version = 1` so a
future migration can distinguish row encodings from the database container
version.

| Table | Purpose | Key and important fields |
|---|---|---|
| `rules_presets` | Immutable names and options for supported scoring contracts | `(id, version)`; sport, targets, win-by, cap/tiebreak options |
| `participants` | Locally known participant names | `id`; name, updated timestamp |
| `matches` | Configuration and replay-derived query summary | `id`; preset id/version, side names, sport, status, winner, timestamps, last event sequence |
| `match_participants` | Ordered, historical membership snapshot for each side | `(match_id, side, position)`; participant id and name-at-match-creation |
| `score_events` | Authoritative append-only scoring history | `(match_id, sequence)`; event type, version-1 JSON payload, occurrence timestamp |

Foreign keys are enabled on every connection. Match deletion cascades to its
membership and event rows, then removes participant records that no remaining
match references; shared participant records are retained. Preset records remain
separate. The reducer's named `RulesPreset` is resolved by both id and version,
so an unknown persisted rules contract fails closed instead of being
approximated.

## Transaction and replay contract

`DriftMatchRepository.createMatch` can persist the validated configuration and
`InitialServerChosen` event in one transaction. A setup crash or write failure
therefore cannot expose a newly created match without its chosen server. Older or
test-created rows still awaiting a server resume into a dedicated recovery step
instead of being treated as live.

`DriftMatchRepository.appendEvent` performs these steps in one SQLite
transaction:

1. Load the match and its contiguous event stream.
2. Verify the caller's expected next sequence to reject duplicate/stale taps.
3. Replay all saved events and ask the deterministic reducer to apply the new
   event.
4. Insert the accepted event and update status, winner, timestamp, and last
   sequence together.
5. Read the match back and replay again before returning it.

A rejected scoring transition writes nothing. A process/database failure after
the insert but before the summary update rolls the whole transaction back.
Derived score is never decoded from a cached score blob: `MatchState` is rebuilt
from `score_events` on every repository read. Summary columns exist only to make
history and resume queries efficient, and are checked against replay.

## Event payload encoding

Version 1 recognizes only these event types:

- `initial_server_chosen` with `{"side":"one|two"}`
- `point_awarded` with `{"side":"one|two"}`
- `sides_changed` with `{}`
- `point_undone` with `{}`
- `point_redone` with `{}`

Unknown types, malformed JSON, invalid sides, gaps in sequence numbers, unknown
preset versions, and replay rejection produce a recoverable repository error.
They are never silently skipped.

## History and resume queries

The application-facing `MatchRepository` supports:

- most-recent unfinished match recovery;
- inclusive start and exclusive end dates;
- sport;
- case-insensitive participant-name substring;
- any, in-progress, or completed state.

The filter contract lives in the application layer and contains no Flutter/UI
concepts. The in-memory adapter implements the same optimistic-sequence,
replay, resume, and filter behavior for tests.

## Privacy deletion and transactional import

`deleteMatch` cascades the selected event stream and membership snapshots, then
removes participant rows no remaining match references. `deleteAllMatches`
removes all match and participant history in one transaction. Presentation asks
for explicit confirmation before either privacy action.

`importMatches` accepts only fully staged `PersistedMatch` values. Both adapters
revalidate configuration, contiguous sequences, timestamps, completion data,
and deterministic replay before mutation. Merge skips existing match ids;
replace deletes current history first. Drift wraps the selected behavior and all
inserted events in one outer transaction, so any later failure restores the
pre-import database. See [the JSON schema and user-facing import contract](data-ownership.md).

## Migration and failure policy

Migration is additive and explicit. Future versions must add ordered
`if (from < N)` steps and migration fixtures; deleting/replacing the database is
not a recovery strategy. Opening a database runs SQLite's integrity check. If
opening, integrity checking, or migration fails, `initialize()` returns a
recoverable `RepositoryFailure` and leaves the file untouched. The application
can keep the scoring action in memory, explain that saving failed, and offer a
retry after storage or app-update problems are resolved.

Tests cover first migration (including preservation of an unrelated legacy
row), corrupt-file preservation, atomic setup and rollback, relaunch/resume,
replay equivalence, stale-sequence rejection, rejected events, privacy-safe
match deletion, shared-participant retention, and all history filters.
