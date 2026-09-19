import SQLite3
import XCTest

@testable import CourtTallyCore

final class StorageTests: XCTestCase {
  func fixture() throws -> Data {
    try Data(contentsOf: Bundle.module.url(forResource: "legacy-v1", withExtension: "json")!)
  }
  func testFlutterV1BackupRoundTrip() throws {
    let backup = try BackupCodec.decode(fixture())
    XCTAssertEqual(backup.matches.count, 1)
    XCTAssertEqual(backup.matches[0].score.status, "awaitingInitialServer")
    let roundTrip = try BackupCodec.decode(BackupCodec.encode(backup.matches))
    XCTAssertEqual(roundTrip.matches, backup.matches)
  }
  func testMalformedImportsRejected() throws {
    let original = try JSONSerialization.jsonObject(with: fixture()) as! [String: Any]
    for key in ["schemaVersion", "format", "participants", "presets"] {
      var bad = original
      bad[key] = key == "schemaVersion" ? 99 : key == "format" ? "other-app" : []
      XCTAssertThrowsError(try BackupCodec.decode(JSONSerialization.data(withJSONObject: bad)), key)
    }
    var bad = original
    var matches = original["matches"] as! [[String: Any]]
    matches[0]["status"] = "completed"
    bad["matches"] = matches
    XCTAssertThrowsError(try BackupCodec.decode(JSONSerialization.data(withJSONObject: bad)))
    bad = original
    bad["matches"] = [original["matches"] as! [Any]][0] + (original["matches"] as! [Any])
    XCTAssertThrowsError(try BackupCodec.decode(JSONSerialization.data(withJSONObject: bad)))
  }
  func testAtomicSaveReloadAndCorruptionPreservation() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let store = LocalStore(directory: dir)
    let matches = try BackupCodec.decode(fixture()).matches
    try store.save(.init(matches: matches, activeID: matches[0].id))
    XCTAssertEqual(try store.load().backup.matches, matches)
    let corrupted = Data("broken data".utf8)
    try corrupted.write(to: store.file)
    XCTAssertThrowsError(try store.load())
    XCTAssertEqual(try Data(contentsOf: store.file), corrupted)
  }
  func testFailedSavePreservesPreviousFile() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let store = LocalStore(directory: dir)
    var matches = try BackupCodec.decode(fixture()).matches
    try store.save(.init(matches: matches, activeID: nil))
    let before = try Data(contentsOf: store.file)
    matches[0].status = "completed"
    XCTAssertThrowsError(try store.save(.init(matches: matches, activeID: nil)))
    XCTAssertEqual(try Data(contentsOf: store.file), before)
  }
  func testMergeKeepsLocalConflictsAndReplaceUsesIncoming() throws {
    let local = try BackupCodec.decode(fixture()).matches
    var incoming = local
    try incoming[0].append(.server, side: .two)
    XCTAssertEqual(LocalStore.merged(current: local, incoming: incoming, replace: false), local)
    XCTAssertEqual(LocalStore.merged(current: local, incoming: incoming, replace: true), incoming)
  }
  func testCSVQuotesNewlinesAndFormulaNames() throws {
    let match = try Match(
      preset: Preset.all[0], one: Team(name: "=SUM(1,2)"), two: Team(name: "Sam \"Ace\"\nLee"))
    let text = String(decoding: BackupCodec.csv([match]), as: UTF8.self)
    XCTAssertTrue(text.contains("\"'=SUM(1,2)\""))
    XCTAssertTrue(text.contains("\"Sam \"\"Ace\"\"\nLee\""))
  }
  func testAutomaticReadOnlySQLiteMigration() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let store = LocalStore(directory: dir)
    var db: OpaquePointer?
    XCTAssertEqual(sqlite3_open(store.legacyFile.path, &db), SQLITE_OK)
    let sql = """
      PRAGMA user_version=1;
      CREATE TABLE matches(id TEXT, schema_version INTEGER, preset_id TEXT, preset_version INTEGER, side_one_name TEXT, side_two_name TEXT, created_at INTEGER, updated_at INTEGER, completed_at INTEGER, status TEXT, winner TEXT, last_event_sequence INTEGER);
      CREATE TABLE match_participants(match_id TEXT, participant_id TEXT, participant_name TEXT, side TEXT, position INTEGER);
      CREATE TABLE score_events(match_id TEXT, sequence INTEGER, event_type TEXT, payload_json TEXT, occurred_at INTEGER);
      INSERT INTO matches VALUES('legacy',1,'badminton.bwf.best-of-3-to-21',1,'Alex','Sam',1780000000,1780000001,NULL,'inProgress',NULL,1);
      INSERT INTO match_participants VALUES('legacy','a','Alex','one',0),('legacy','s','Sam','two',0);
      INSERT INTO score_events VALUES('legacy',0,'initial_server_chosen','{"side":"one"}',1780000000),('legacy',1,'point_awarded','{"side":"two"}',1780000001);
      """
    XCTAssertEqual(sqlite3_exec(db, sql, nil, nil, nil), SQLITE_OK)
    sqlite3_close(db)
    let original = try Data(contentsOf: store.legacyFile)
    let snapshot = try store.load()
    XCTAssertEqual(snapshot.activeID, "legacy")
    XCTAssertEqual(snapshot.backup.matches[0].score.points, [0, 1])
    XCTAssertEqual(snapshot.backup.matches[0].score.server, .two)
    XCTAssertEqual(try Data(contentsOf: store.legacyFile), original)
    XCTAssertEqual(try store.load().backup.matches, snapshot.backup.matches)
  }
}
