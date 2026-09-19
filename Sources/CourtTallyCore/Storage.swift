import Foundation

struct Backup: Codable {
  struct Person: Codable {
    let id: String
    let name: String
  }
  let format: String
  let schemaVersion: Int
  let exportedAt: Date
  let presets: [Preset]
  let participants: [Person]
  let matches: [Match]

  init(matches: [Match], now: Date = Date()) {
    format = "court-tally-backup"
    schemaVersion = 1
    exportedAt = now
    presets = Preset.all
    self.matches = matches.sorted { $0.createdAt < $1.createdAt }
    var names: [String: String] = [:]
    for match in self.matches {
      for player in match.sideOne.participants + match.sideTwo.participants {
        names[player.id] = player.nameAtMatch
      }
    }
    participants = names.keys.sorted().map { Person(id: $0, name: names[$0]!) }
  }

  func validate() throws {
    guard format == "court-tally-backup", schemaVersion == 1 else {
      throw MatchError("Unsupported backup format or version.")
    }
    guard Set(presets.map(\.id)).count == presets.count,
      presets.allSatisfy({ Preset.all.contains($0) }),
      Set(participants.map(\.id)).count == participants.count,
      participants.allSatisfy({
        !$0.id.isEmpty && !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      }),
      Set(matches.map(\.id)).count == matches.count
    else { throw MatchError("Backup contains duplicate identifiers or unsupported rules.") }
    let playerIDs = Set(participants.map(\.id))
    let presetIDs = Set(presets.map(\.id))
    for match in matches {
      try match.validateConfiguration()
      guard presetIDs.contains(match.presetId),
        (match.sideOne.participants + match.sideTwo.participants).allSatisfy({
          playerIDs.contains($0.id)
        })
      else {
        throw MatchError("Backup references a missing player or rules preset.")
      }
      var previous = match.createdAt
      for event in match.events {
        guard event.occurredAt >= previous else {
          throw MatchError("Event times must be in order.")
        }
        previous = event.occurredAt
      }
      let state = try Scoring.replay(match)
      guard match.updatedAt == previous, match.status == state.status, match.winner == state.winner,
        match.completedAt == (state.winner == nil ? nil : previous)
      else {
        throw MatchError("Saved match summary does not match its event log.")
      }
    }
  }
}

enum BackupCodec {
  static func dateString(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
  }
  static func encoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .custom { date, encoder in
      var value = encoder.singleValueContainer()
      try value.encode(dateString(date))
    }
    return encoder
  }
  static func decoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let value = try decoder.singleValueContainer().decode(String.self)
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      var parsed = formatter.date(from: value)
      if parsed == nil {
        formatter.formatOptions = [.withInternetDateTime]
        parsed = formatter.date(from: value)
      }
      guard value.hasSuffix("Z"), let date = parsed else {
        throw MatchError("Expected a UTC ISO-8601 timestamp.")
      }
      return date
    }
    return decoder
  }
  static func decode(_ data: Data) throws -> Backup {
    guard data.count <= 50_000_000 else {
      throw MatchError("Backup exceeds the 50 MB import limit.")
    }
    let result = try decoder().decode(Backup.self, from: data)
    try result.validate()
    return result
  }
  static func encode(_ matches: [Match]) throws -> Data {
    try encoder().encode(Backup(matches: matches))
  }

  static func csv(_ matches: [Match]) -> Data {
    func escape(_ value: String) -> String {
      let safe =
        ["=", "+", "-", "@", "\t", "\r"].contains(where: { value.hasPrefix($0) })
        ? "'" + value : value
      return "\"" + safe.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
    var rows = [
      ["Match ID", "Sport", "Side 1", "Side 2", "Created UTC", "Status", "Winner", "Games", "Sets"]
    ]
    rows += matches.map { match in
      let s = match.score
      return [
        match.id, match.preset.sport.name, match.sideOne.name, match.sideTwo.name,
        dateString(match.createdAt), s.status, s.winner.map { match.team($0).name } ?? "",
        "\(s.games[0])–\(s.games[1])", "\(s.sets[0])–\(s.sets[1])",
      ]
    }
    return Data(
      (rows.map { $0.map(escape).joined(separator: ",") }.joined(separator: "\r\n") + "\r\n").utf8)
  }
}

/// Atomic document storage. A failed read never falls back to an empty writable
/// store; a failed write never changes the caller's committed snapshot.
struct LocalStore {
  struct Snapshot: Codable {
    let version: Int
    var backup: Backup
    var activeID: String?
    init(matches: [Match], activeID: String?) {
      version = 1
      backup = Backup(matches: matches)
      self.activeID = activeID
    }
  }
  let directory: URL
  var file: URL { directory.appendingPathComponent("court-tally-native.json") }
  var legacyFile: URL { directory.appendingPathComponent("court_tally.sqlite") }

  func load() throws -> Snapshot {
    if FileManager.default.fileExists(atPath: file.path) {
      let result = try BackupCodec.decoder().decode(Snapshot.self, from: Data(contentsOf: file))
      guard result.version == 1 else {
        throw MatchError("Unsupported local storage version. Existing data was preserved.")
      }
      try result.backup.validate()
      guard
        result.activeID == nil
          || result.backup.matches.contains(where: { $0.id == result.activeID })
      else {
        throw MatchError("The active match is missing. Existing data was preserved.")
      }
      return result
    }
    if FileManager.default.fileExists(atPath: legacyFile.path) {
      let matches = try LegacyMigration.read(legacyFile)
      let result = Snapshot(
        matches: matches,
        activeID: matches.filter { $0.winner == nil }.max { $0.updatedAt < $1.updatedAt }?.id)
      try save(result)
      return result
    }
    return Snapshot(matches: [], activeID: nil)
  }
  func save(_ snapshot: Snapshot) throws {
    try snapshot.backup.validate()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try BackupCodec.encoder().encode(snapshot).write(to: file, options: .atomic)
  }

  static func merged(current: [Match], incoming: [Match], replace: Bool) -> [Match] {
    if replace { return incoming }
    let existing = Set(current.map(\.id))
    return current + incoming.filter { !existing.contains($0.id) }
  }
}
