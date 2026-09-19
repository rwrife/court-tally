import XCTest

@testable import CourtTallyCore

final class ParityTests: XCTestCase {
  struct Scenario: Decodable {
    let presetIndex: Int
    let doubles: Bool
    let frames: [Frame]
  }
  struct Frame: Decodable {
    let type: EventKind
    let side: Side?
    let points: [Int]
    let games: [Int]
    let sets: [Int]
    let server: Side?
    let serviceNumber: Int
    let gameNumber: Int
    let setNumber: Int
    let tiebreak: Bool
    let prompt: Bool
    let winner: Side?
    let canUndo: Bool
    let canRedo: Bool
    let completedGames: [[Int]]
    let completedSets: [[Int]]
  }
  func test4800TransitionsMatchOriginalDartReducer() throws {
    let data = try Data(
      contentsOf: Bundle.module.url(forResource: "dart-parity", withExtension: "json")!)
    let scenarios = try JSONDecoder().decode([Scenario].self, from: data)
    for scenario in scenarios {
      var match = try Match(
        preset: Preset.all[scenario.presetIndex],
        one: Team(name: "Alex", partner: scenario.doubles ? "Jordan" : nil),
        two: Team(name: "Sam", partner: scenario.doubles ? "Casey" : nil))
      for (index, f) in scenario.frames.enumerated() {
        try match.append(f.type, side: f.side)
        let s = match.score
        let context = "Preset \(scenario.presetIndex), doubles \(scenario.doubles), event \(index)"
        XCTAssertEqual(s.points, f.points, context)
        XCTAssertEqual(s.games, f.games, context)
        XCTAssertEqual(s.sets, f.sets, context)
        XCTAssertEqual(s.server, f.server, context)
        XCTAssertEqual(s.serviceNumber, f.serviceNumber, context)
        XCTAssertEqual(s.gameNumber, f.gameNumber, context)
        XCTAssertEqual(s.setNumber, f.setNumber, context)
        XCTAssertEqual(s.isTiebreak, f.tiebreak, context)
        XCTAssertEqual(s.prompt != nil, f.prompt, context)
        XCTAssertEqual(s.winner, f.winner, context)
        XCTAssertEqual(s.canUndo, f.canUndo, context)
        XCTAssertEqual(s.canRedo, f.canRedo, context)
        XCTAssertEqual(s.completedGames.map(\.points), f.completedGames, context)
        XCTAssertEqual(s.completedSets, f.completedSets, context)
      }
    }
  }
}
