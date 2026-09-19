import Foundation
import SQLite3

/// Read-only import of the Flutter/Drift v1 database, including unfinished games.
/// The original database is retained as a recovery copy until explicitly erased.
enum LegacyMigration {
  static func read(_ url: URL) throws -> [Match] {
    var db: OpaquePointer?
    guard sqlite3_open_v2(url.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
      if let db { sqlite3_close(db) }
      throw MatchError("The existing Flutter database could not be opened. It was left unchanged.")
    }
    defer { sqlite3_close(db) }
    func rows(_ sql: String) throws -> [[String: Any]] {
      var statement: OpaquePointer?
      guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
        throw MatchError("The existing database schema could not be read.")
      }
      defer { sqlite3_finalize(statement) }
      var result: [[String: Any]] = []
      var step = sqlite3_step(statement)
      while step == SQLITE_ROW {
        var row: [String: Any] = [:]
        for i in 0..<sqlite3_column_count(statement) {
          let name = String(cString: sqlite3_column_name(statement, i))
          switch sqlite3_column_type(statement, i) {
          case SQLITE_INTEGER: row[name] = sqlite3_column_int64(statement, i)
          case SQLITE_TEXT: row[name] = String(cString: sqlite3_column_text(statement, i))
          case SQLITE_NULL: row[name] = NSNull()
          default: throw MatchError("Unexpected legacy database value.")
          }
        }
        result.append(row)
        step = sqlite3_step(statement)
      }
      guard step == SQLITE_DONE else {
        throw MatchError("Could not finish reading the existing database.")
      }
      return result
    }
    guard try rows("PRAGMA user_version").first?["user_version"] as? Int64 == 1,
      try rows("PRAGMA quick_check").first?["quick_check"] as? String == "ok"
    else {
      throw MatchError("The existing database failed its version or integrity check.")
    }
    let players = try rows("SELECT * FROM match_participants ORDER BY position")
    let events = try rows("SELECT * FROM score_events ORDER BY sequence")
    func required(_ row: [String: Any], _ key: String) throws -> Any {
      guard let value = row[key] else { throw MatchError("Missing legacy field: \(key)") }
      return value
    }
    func timestamp(_ value: Any) throws -> Any {
      if value is NSNull { return NSNull() }
      guard let seconds = value as? Int64 else { throw MatchError("Invalid legacy timestamp.") }
      return BackupCodec.dateString(Date(timeIntervalSince1970: Double(seconds)))
    }
    var documents: [[String: Any]] = []
    for row in try rows("SELECT * FROM matches") {
      guard let id = row["id"] as? String, row["schema_version"] as? Int64 == 1 else {
        throw MatchError("Unsupported legacy match version.")
      }
      func team(_ side: String, nameKey: String) throws -> [String: Any] {
        let members = try players.filter {
          $0["match_id"] as? String == id && $0["side"] as? String == side
        }.map {
          [
            "id": try required($0, "participant_id"),
            "nameAtMatch": try required($0, "participant_name"),
          ]
        }
        return ["name": try required(row, nameKey), "participants": members]
      }
      let matchEvents: [[String: Any]] = try events.filter { $0["match_id"] as? String == id }.map {
        event in
        guard let payload = event["payload_json"] as? String else {
          throw MatchError("Invalid legacy event payload.")
        }
        return [
          "sequence": try required(event, "sequence"), "type": try required(event, "event_type"),
          "payload": try JSONSerialization.jsonObject(with: Data(payload.utf8)),
          "occurredAt": try timestamp(required(event, "occurred_at")),
        ]
      }
      guard row["last_event_sequence"] as? Int64 == Int64(matchEvents.count - 1) else {
        throw MatchError("Legacy event sequence is incomplete.")
      }
      documents.append([
        "id": id, "presetId": try required(row, "preset_id"),
        "presetVersion": try required(row, "preset_version"),
        "sideOne": try team("one", nameKey: "side_one_name"),
        "sideTwo": try team("two", nameKey: "side_two_name"),
        "createdAt": try timestamp(required(row, "created_at")),
        "updatedAt": try timestamp(required(row, "updated_at")),
        "completedAt": try timestamp(required(row, "completed_at")),
        "status": try required(row, "status"),
        "winner": try required(row, "winner"), "events": matchEvents,
      ])
    }
    let data = try JSONSerialization.data(withJSONObject: documents)
    let matches = try BackupCodec.decoder().decode([Match].self, from: data)
    try Backup(matches: matches).validate()
    return matches
  }
}
