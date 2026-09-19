import SwiftUI

@MainActor
final class AppModel: ObservableObject {
  @Published private(set) var matches: [Match] = []
  @Published private(set) var activeID: String?
  @Published var error: String?
  @Published private(set) var loaded = false
  @Published var selectedTab = 0
  let storage: LocalStore

  var active: Match? { matches.first { $0.id == activeID } }
  var hasLegacyArchive: Bool { FileManager.default.fileExists(atPath: storage.legacyFile.path) }

  init() {
    var directory = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask)[0]
    #if DEBUG
      if ProcessInfo.processInfo.arguments.contains("--uitesting")
        || ProcessInfo.processInfo.arguments.contains("--screenshot")
      {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
      }
    #endif
    storage = LocalStore(directory: directory)
    reload()
    #if DEBUG
      if let i = ProcessInfo.processInfo.arguments.firstIndex(of: "--screenshot"),
        ProcessInfo.processInfo.arguments.count > i + 1
      {
        seedDemo(ProcessInfo.processInfo.arguments[i + 1])
      }
    #endif
  }

  func reload() {
    do {
      let snapshot = try storage.load()
      matches = snapshot.backup.matches
      activeID = snapshot.activeID
      loaded = true
      error = nil
    } catch {
      loaded = false
      self.error = "Could not open local data. Nothing was replaced. \(error.localizedDescription)"
    }
  }

  @discardableResult
  private func commit(_ next: [Match], active: String?) -> Bool {
    guard loaded else { return false }
    do {
      try storage.save(.init(matches: next, activeID: active))
      matches = next
      activeID = active
      return true
    } catch {
      self.error = "Changes could not be saved. \(error.localizedDescription)"
      return false
    }
  }

  func start(preset: Preset, one: Team, two: Team, server: Side) {
    do {
      var match = try Match(preset: preset, one: one, two: two)
      try match.append(.server, side: server)
      if commit(matches + [match], active: match.id) { selectedTab = 0 }
    } catch { self.error = error.localizedDescription }
  }

  func record(_ kind: EventKind, side: Side? = nil) {
    guard var match = active, let index = matches.firstIndex(where: { $0.id == match.id }) else {
      return
    }
    do {
      try match.append(kind, side: side)
      var next = matches
      next[index] = match
      if commit(next, active: match.id) {
        let s = match.score
        let message =
          "\(match.sideOne.name) \(s.label(.one, sport: match.preset.sport)), \(match.sideTwo.name) \(s.label(.two, sport: match.preset.sport)). "
          + (s.prompt ?? "")
        UIAccessibility.post(notification: .announcement, argument: message)
      }
    } catch { self.error = error.localizedDescription }
  }
  func finish() { if active?.winner != nil { _ = commit(matches, active: nil) } }
  func resume(_ match: Match) { if commit(matches, active: match.id) { selectedTab = 0 } }
  func delete(_ match: Match) {
    _ = commit(matches.filter { $0.id != match.id }, active: activeID == match.id ? nil : activeID)
  }
  func deleteAll() {
    if commit([], active: nil) { eraseLegacyArchive() }
  }
  func eraseLegacyArchive() {
    do {
      for suffix in ["", "-wal", "-shm"] {
        let path = storage.legacyFile.path + suffix
        if FileManager.default.fileExists(atPath: path) {
          try FileManager.default.removeItem(atPath: path)
        }
      }
      objectWillChange.send()
    } catch {
      self.error =
        "Native data was updated, but the Flutter recovery copy could not be removed: \(error.localizedDescription)"
    }
  }
  func apply(_ backup: Backup, replace: Bool) {
    let next = LocalStore.merged(current: matches, incoming: backup.matches, replace: replace)
    let id = activeID.flatMap { current in next.contains { $0.id == current } ? current : nil }
    _ = commit(
      next, active: id ?? next.filter { $0.winner == nil }.max { $0.updatedAt < $1.updatedAt }?.id)
  }

  #if DEBUG
    private func seedDemo(_ scene: String) {
      do {
        var samples: [Match] = []
        for (offset, sport) in Sport.allCases.enumerated() {
          let preset = Preset.all.first { $0.sport == sport }!
          var match = try Match(
            preset: preset, one: Team(name: offset.isMultiple(of: 2) ? "Alex" : "Jordan"),
            two: Team(name: offset.isMultiple(of: 2) ? "Sam" : "Casey"),
            now: Date(timeIntervalSince1970: 1_789_819_200 - Double(offset) * 86400))
          try match.append(.server, side: .one, now: match.createdAt)
          while match.winner == nil {
            if match.score.prompt != nil { try match.append(.changeEnds, now: match.updatedAt) }
            try match.append(.point, side: .one, now: match.updatedAt)
          }
          samples.append(match)
        }
        if let sport = Sport(rawValue: scene) {
          var live = try Match(
            preset: Preset.all.first { $0.sport == sport }!, one: Team(name: "Alex"),
            two: Team(name: "Sam"))
          try live.append(.server, side: .one)
          let rallySides: [Side] =
            sport == .tennis
            ? [.one, .two, .one, .two, .one]
            : [.one, .one, .two, .two, .one, .one, .one, .two, .two, .two, .one, .one, .one]
          for side in rallySides { try live.append(.point, side: side) }
          samples.append(live)
          _ = commit(samples, active: live.id)
        } else {
          _ = commit(samples, active: nil)
        }
        selectedTab = scene == "history" ? 1 : scene == "data" ? 2 : 0
      } catch { self.error = error.localizedDescription }
    }
  #endif
}
