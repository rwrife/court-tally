# Local history, backup, import, and privacy contract

Court Tally keeps match data in the app-private SQLite database. It has no
account, cloud synchronization, advertising, or analytics. History, import,
export, and deletion are explicit user actions under **History and data**.

## History and deletion

History can be filtered by sport, case-insensitive participant-name substring,
inclusive start/through dates, and completion state. A match detail view replays
the authoritative ordered event log and shows the derived score after every
event.

Deleting one match permanently removes that match, its membership snapshots,
and its events. Participant rows with no remaining match reference are removed.
Deleting all history removes every match, event, and participant row in one
transaction. Both actions require a confirmation that explains the consequence.
Presets are application rules contracts and are not personal history.

## JSON backup schema version 1

A JSON backup is the lossless restore format. Its root object is:

```json
{
  "format": "court-tally-backup",
  "schemaVersion": 1,
  "exportedAt": "2026-08-26T12:00:00.000Z",
  "presets": [],
  "participants": [],
  "matches": []
}
```

- `presets` contains every supported immutable rules contract, including id,
  version, sport, name, point target, win-by, cap, and tennis set/tiebreak
  options. Imported values must exactly match a preset supported by this app.
- `participants` contains the current participant id/name records.
- Each `matches` entry contains its id, preset id/version, side names,
  participant ids and historical names, UTC creation/update/completion times,
  replay-derived status/winner, and `events`.
- Each event has a contiguous zero-based `sequence`, recognized `type`, JSON
  `payload`, and UTC `occurredAt`. Event types and payloads follow
  [the local schema contract](local-data-schema.md#event-payload-encoding).

The schema version is independent from the SQLite schema version. A future
incompatible backup format must increment `schemaVersion` and provide an
explicit decoder/migration; unknown versions fail closed.

## Staged import and conflict behavior

Import uses the operating-system document picker. Court Tally parses the whole
file into staging and validates all of these before offering a write:

1. JSON shape, format marker, and schema version.
2. Unique preset, participant, and match identifiers plus all references.
3. Exact supported preset definitions and valid match configurations.
4. UTC timestamp ordering, contiguous event sequences, and completion metadata.
5. Deterministic replay of every event stream, including saved status/winner.

A validation failure changes nothing. A successful preview reports backup match
count, new ids, conflicting ids, and current local count. The user then chooses:

- **Merge:** keep all existing match ids, skip conflicting backup ids, and add
  only new ids.
- **Replace:** delete all current local history and import every staged match.

The selected operation is one repository transaction. Any insert or replay
failure rolls back the complete operation, including a preceding replace.

## CSV summary boundary

CSV export contains one correctly RFC-4180-escaped summary row per match:
identifier, sport, preset, status, UTC dates, side names, winner, derived score,
and event count. Commas, quotes, CR, and LF are quoted and embedded quotes are
doubled. User text that begins like a spreadsheet formula (`=`, `+`, `-`, or
`@`, including after leading whitespace) is prefixed with an apostrophe so CSV
viewers display it literally rather than execute it.

**CSV is not a backup or restore format.** It does not contain complete preset,
participant, or ordered event data and cannot be imported by Court Tally.

## Platform and permission boundary

JSON/CSV export invokes the operating-system share/save sheet after the user
presses an export action. JSON import invokes the operating-system document
picker after the user presses import. Imports larger than 10 MiB are rejected
before reading to bound staging memory. The app writes no export silently and
requests no broad-storage, network, contacts, location, Bluetooth, sensor,
health, microphone, camera, or notification permission. The user chooses the
external destination or source. Uninstalling the app may remove local data that
was not backed up first.
