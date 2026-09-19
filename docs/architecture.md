# Native architecture

`CourtTallyApp` owns one main-actor `AppModel`. SwiftUI views render committed state and send actions to that model. `Scoring` has no UI or filesystem dependencies. It deterministically derives all score state from an ordered event log using the six original Court Tally presets.

Undo/redo operate on effective rallies, including any following end-change acknowledgment. New rallies clear redo history. Invalid transitions throw before the match is changed. Final score summaries, service rotation, match completion, and prompts are derived, never trusted from imported JSON.

`BackupCodec` reads the existing `court-tally-backup` version-1 interchange format. Decoding verifies supported presets, identifiers, references, timestamps, sequences, status, winner, completion time, and every scoring transition. Imports are staged and previewed; merge keeps existing conflicting IDs, while replace uses the staged history exactly.

`LocalStore` stores one versioned snapshot in Application Support using Foundation's atomic file replacement. `AppModel` publishes changes only after the save succeeds. Failed reads block scoring and preserve the source file. Failed writes leave the previous in-memory state intact. This favors simple, inspectable storage for recreational match histories; loading and saving very large histories should be profiled before expanding the product's scale.

`LegacyMigration` can read a database inside the current app sandbox; it cannot cross from the old `com.rwrife.courttally` identity into `com.infinityball.courttally`. Transfer between those apps uses JSON export/import. The migration opens the old Drift database read-only through Apple's SQLite library, checks schema/integrity, and translates participants and events into the same validated native model. Migration writes a native snapshot without removing the recovery copy. The data screen makes its retention and deletion explicit.

The production target contains only Swift, SwiftUI, Foundation, UIKit accessibility APIs, and system SQLite. Debug builds alone include isolated fictional screenshot fixtures. No package download, Flutter runtime, analytics, or remote service is required.
