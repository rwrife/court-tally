import XCTest

@testable import CourtTallyCore

final class ScoringTests: XCTestCase {
  let now = Date(timeIntervalSince1970: 1_780_000_000)
  func match(_ sport: Sport, doubles: Bool = false, presetIndex: Int? = nil) throws -> Match {
    var value = try Match(
      preset: presetIndex.map { Preset.all[$0] } ?? Preset.all.first { $0.sport == sport }!,
      one: Team(name: "Alex", partner: doubles ? "Jordan" : nil),
      two: Team(name: "Sam", partner: doubles ? "Casey" : nil), now: now)
    try value.append(.server, side: .one, now: now)
    return value
  }
  func rally(_ match: inout Match, _ side: Side, count: Int = 1) throws {
    for _ in 0..<count {
      if match.score.prompt != nil { try match.append(.changeEnds, now: now) }
      try match.append(.point, side: side, now: now)
    }
  }
  func game(_ match: inout Match, _ side: Side) throws {
    let previous = match.score.completedGames.count
    while match.score.completedGames.count == previous { try rally(&match, side) }
  }
  func testPickleballSinglesSideOutDoesNotAwardReceiverPoint() throws {
    var m = try match(.pickleball)
    try rally(&m, .two)
    XCTAssertEqual(m.score.points, [0, 0])
    XCTAssertEqual(m.score.server, .two)
    try rally(&m, .two)
    XCTAssertEqual(m.score.points, [0, 1])
  }
  func testPickleballDoublesOpeningAndTwoServers() throws {
    var m = try match(.pickleball, doubles: true)
    XCTAssertEqual(m.score.serviceNumber, 2)
    try rally(&m, .two)
    XCTAssertEqual(m.score.server, .two)
    XCTAssertEqual(m.score.serviceNumber, 1)
    try rally(&m, .one)
    XCTAssertEqual(m.score.server, .two)
    XCTAssertEqual(m.score.serviceNumber, 2)
    try rally(&m, .one)
    XCTAssertEqual(m.score.server, .one)
    XCTAssertEqual(m.score.serviceNumber, 1)
  }
  func testPromptBlocksPointsAndUndoRedoRestoresAcknowledgment() throws {
    var m = try match(.pickleball, presetIndex: 1)
    try rally(&m, .one, count: 8)
    XCTAssertNotNil(m.score.prompt)
    let before = m
    XCTAssertThrowsError(try m.append(.point, side: .one, now: now))
    XCTAssertEqual(m, before)
    try m.append(.changeEnds, now: now)
    let acknowledged = m.score
    try m.append(.undo, now: now)
    XCTAssertEqual(m.score.points, [7, 0])
    XCTAssertNil(m.score.prompt)
    try m.append(.redo, now: now)
    XCTAssertEqual(m.score, acknowledged)
  }
  func testUndoUnacknowledgedPromptAndNewBranchClearsRedo() throws {
    var m = try match(.pickleball, presetIndex: 1)
    try rally(&m, .one, count: 8)
    try m.append(.undo, now: now)
    try m.append(.redo, now: now)
    XCTAssertNotNil(m.score.prompt)
    try m.append(.undo, now: now)
    try rally(&m, .two)
    XCTAssertFalse(m.score.canRedo)
    XCTAssertThrowsError(try m.append(.redo, now: now))
  }
  func testBadmintonCapAndWinningServer() throws {
    var m = try match(.badminton)
    for _ in 0..<29 {
      try rally(&m, .one)
      try rally(&m, .two)
    }
    XCTAssertEqual(m.score.points, [29, 29])
    try rally(&m, .two)
    XCTAssertEqual(m.score.completedGames.last?.points, [29, 30])
    XCTAssertEqual(m.score.server, .two)
    XCTAssertEqual(m.score.games, [0, 1])
  }
  func testBadmintonDecidingGameInterval() throws {
    var m = try match(.badminton)
    try game(&m, .one)
    try game(&m, .two)
    try rally(&m, .one, count: 11)
    XCTAssertEqual(m.score.gameNumber, 3)
    XCTAssertNotNil(m.score.prompt)
  }
  func testTableTennisServeChangesAtDeuce() throws {
    var m = try match(.tableTennis)
    try rally(&m, .one)
    XCTAssertEqual(m.score.server, .one)
    try rally(&m, .two)
    XCTAssertEqual(m.score.server, .two)
    for _ in 0..<9 {
      try rally(&m, .one)
      try rally(&m, .two)
    }
    XCTAssertEqual(m.score.points, [10, 10])
    XCTAssertEqual(m.score.server, .one)
    try rally(&m, .one)
    XCTAssertEqual(m.score.server, .two)
    try rally(&m, .two)
    XCTAssertEqual(m.score.server, .one)
    try rally(&m, .one, count: 2)
    XCTAssertEqual(m.score.completedGames.last?.points, [13, 11])
  }
  func testTennisDeuceAdvantageAndGame() throws {
    var m = try match(.tennis)
    for _ in 0..<3 {
      try rally(&m, .one)
      try rally(&m, .two)
    }
    XCTAssertEqual(m.score.label(.one, sport: .tennis), "40")
    try rally(&m, .one)
    XCTAssertEqual(m.score.label(.one, sport: .tennis), "AD")
    try rally(&m, .two)
    XCTAssertEqual(m.score.label(.two, sport: .tennis), "40")
    try rally(&m, .one, count: 2)
    XCTAssertEqual(m.score.games, [1, 0])
    XCTAssertEqual(m.score.server, .two)
    XCTAssertNotNil(m.score.prompt)
  }
  func testTennisTiebreakServiceEndsAndSet() throws {
    var m = try match(.tennis)
    for _ in 0..<6 {
      try game(&m, .one)
      try game(&m, .two)
    }
    XCTAssertTrue(m.score.isTiebreak)
    XCTAssertEqual(m.score.games, [6, 6])
    let first = m.score.server
    try rally(&m, .one)
    XCTAssertEqual(m.score.server, first?.opponent)
    try rally(&m, .two)
    XCTAssertEqual(m.score.server, first?.opponent)
    try rally(&m, .one)
    XCTAssertEqual(m.score.server, first)
    try rally(&m, .two)
    try rally(&m, .one)
    try rally(&m, .two)
    XCTAssertNotNil(m.score.prompt)
    try rally(&m, .one, count: 4)
    XCTAssertEqual(m.score.sets, [1, 0])
    XCTAssertEqual(m.score.completedSets, [[7, 6]])
    XCTAssertEqual(m.score.server, first?.opponent)
  }
  func testAllPresetsCompleteUndoAndRedo() throws {
    for (index, preset) in Preset.all.enumerated() {
      var m = try match(preset.sport, presetIndex: index)
      var count = 0
      while m.winner == nil && count < 1000 {
        try rally(&m, .one)
        count += 1
      }
      XCTAssertEqual(m.winner, .one, preset.name)
      XCTAssertNotNil(m.completedAt)
      let completed = m.score
      XCTAssertThrowsError(try m.append(.point, side: .one, now: now))
      try m.append(.undo, now: now)
      XCTAssertNil(m.winner)
      XCTAssertNil(m.completedAt)
      try m.append(.redo, now: now)
      XCTAssertEqual(m.score, completed)
      XCTAssertEqual(try BackupCodec.decode(BackupCodec.encode([m])).matches.first, m)
    }
  }
  func testInvalidEventsAndConfigurationRejected() throws {
    XCTAssertThrowsError(
      try Match(preset: Preset.all[0], one: Team(name: " "), two: Team(name: "Sam")))
    XCTAssertThrowsError(
      try Match(
        preset: Preset.all[0], one: Team(name: "Alex", partner: "Jordan"), two: Team(name: "Sam")))
    var m = try Match(preset: Preset.all[0], one: Team(name: "Alex"), two: Team(name: "Sam"))
    XCTAssertThrowsError(try m.append(.point, side: .one))
    XCTAssertThrowsError(try m.append(.undo))
    try m.append(.server, side: .one)
    XCTAssertThrowsError(try m.append(.server, side: .two))
    XCTAssertThrowsError(try m.append(.changeEnds))
  }
}
