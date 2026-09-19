import Foundation

enum Sport: String, Codable, CaseIterable, Identifiable {
  case pickleball, tennis, badminton, tableTennis
  var id: String { rawValue }
  var name: String {
    switch self {
    case .pickleball: return "Pickleball"
    case .tennis: return "Tennis"
    case .badminton: return "Badminton"
    case .tableTennis: return "Table tennis"
    }
  }
  var symbol: String { self == .tennis ? "tennis.racket" : "figure.racquetball" }
}

enum Side: String, Codable, CaseIterable {
  case one, two
  var index: Int { self == .one ? 0 : 1 }
  var opponent: Side { self == .one ? .two : .one }
}

struct Preset: Codable, Equatable, Identifiable {
  let id: String
  let version: Int
  let name: String
  let sport: Sport
  let unitsToWin: Int
  let pointsToWinGame: Int
  let winBy: Int
  let pointCap: Int?
  let gamesToWinSet: Int?
  let tiebreakAtGames: Int?
  let tiebreakPoints: Int?

  static let all: [Preset] = [
    Preset(
      id: "pickleball.usap.side-out.best-of-3-to-11", name: "Pickleball side-out: best of 3 to 11",
      sport: .pickleball, units: 2, points: 11),
    Preset(
      id: "pickleball.usap.side-out.single-to-15", name: "Pickleball side-out: single game to 15",
      sport: .pickleball, units: 1, points: 15),
    Preset(
      id: "pickleball.usap.side-out.single-to-21", name: "Pickleball side-out: single game to 21",
      sport: .pickleball, units: 1, points: 21),
    Preset(
      id: "tennis.itf.advantage.best-of-3", name: "Tennis advantage sets: best of 3",
      sport: .tennis, units: 2, points: 4),
    Preset(
      id: "badminton.bwf.best-of-3-to-21", name: "Badminton: best of 3 to 21", sport: .badminton,
      units: 2, points: 21),
    Preset(
      id: "table-tennis.ittf.best-of-5-to-11", name: "Table tennis: best of 5 to 11",
      sport: .tableTennis, units: 3, points: 11),
  ]

  private init(id: String, name: String, sport: Sport, units: Int, points: Int) {
    self.id = id
    version = 1
    self.name = name
    self.sport = sport
    unitsToWin = units
    pointsToWinGame = points
    winBy = 2
    pointCap = sport == .badminton ? 30 : nil
    gamesToWinSet = sport == .tennis ? 6 : nil
    tiebreakAtGames = sport == .tennis ? 6 : nil
    tiebreakPoints = sport == .tennis ? 7 : nil
  }
}

struct Player: Codable, Equatable {
  let id: String
  let nameAtMatch: String
}

struct Team: Codable, Equatable {
  let name: String
  let participants: [Player]
  init(name: String, partner: String? = nil) {
    self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    participants = ([name] + (partner.map { [$0] } ?? [])).map {
      Player(id: UUID().uuidString, nameAtMatch: $0.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  init(name: String, participants: [Player]) {
    self.name = name
    self.participants = participants
  }
}

struct MatchError: LocalizedError {
  let message: String
  var errorDescription: String? { message }
  init(_ message: String) { self.message = message }
}

enum EventKind: String, Codable {
  case server = "initial_server_chosen"
  case point = "point_awarded"
  case changeEnds = "sides_changed"
  case undo = "point_undone"
  case redo = "point_redone"
}

struct ScoreEvent: Codable, Equatable, Identifiable {
  let sequence: Int
  let type: EventKind
  let payload: [String: Side]
  let occurredAt: Date
  var id: Int { sequence }
  var side: Side? { payload["side"] }
  var label: String {
    switch type {
    case .server: return "Initial server"
    case .point: return "Rally won"
    case .changeEnds: return "Changed ends"
    case .undo: return "Undo rally"
    case .redo: return "Redo rally"
    }
  }
}

struct GameResult: Equatable {
  let points: [Int]
  let set: Int
  let tiebreak: Bool
}

struct Score: Equatable {
  var points = [0, 0]
  var games = [0, 0]
  var sets = [0, 0]
  var server: Side?
  var gameServer: Side?
  var tiebreakServer: Side?
  var serviceNumber = 0
  var gameNumber = 1
  var setNumber = 1
  var isTiebreak = false
  var intervalReached = false
  var prompt: String?
  var winner: Side?
  var completedGames: [GameResult] = []
  var completedSets: [[Int]] = []
  var canUndo = false
  var canRedo = false
  var status: String {
    winner != nil ? "completed" : server == nil ? "awaitingInitialServer" : "inProgress"
  }

  func label(_ side: Side, sport: Sport) -> String {
    let mine = points[side.index]
    let theirs = points[side.opponent.index]
    guard sport == .tennis && !isTiebreak else { return String(mine) }
    if mine >= 3 && theirs >= 3 { return mine > theirs ? "AD" : "40" }
    return ["0", "15", "30", "40"][min(mine, 3)]
  }
}

struct Match: Codable, Equatable, Identifiable {
  let id: String
  let presetId: String
  let presetVersion: Int
  let sideOne: Team
  let sideTwo: Team
  let createdAt: Date
  var updatedAt: Date
  var completedAt: Date?
  var status: String
  var winner: Side?
  var events: [ScoreEvent]

  // Validated at every decode boundary.
  var preset: Preset { Preset.all.first { $0.id == presetId }! }
  var title: String { "\(sideOne.name) vs \(sideTwo.name)" }
  func team(_ side: Side) -> Team { side == .one ? sideOne : sideTwo }
  var score: Score { (try? Scoring.replay(self)) ?? Score() }

  init(preset: Preset, one: Team, two: Team, now: Date = Date()) throws {
    id = UUID().uuidString
    presetId = preset.id
    presetVersion = preset.version
    sideOne = one
    sideTwo = two
    createdAt = now
    updatedAt = now
    completedAt = nil
    status = "awaitingInitialServer"
    winner = nil
    events = []
    try validateConfiguration()
  }

  func validateConfiguration() throws {
    guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      Preset.all.contains(where: { $0.id == presetId && $0.version == presetVersion })
    else {
      throw MatchError("Unknown rules preset or empty match identifier.")
    }
    let teams = [sideOne, sideTwo]
    let players = teams.flatMap(\.participants)
    guard
      teams.allSatisfy({
        !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          && (1...2).contains($0.participants.count)
      }),
      sideOne.participants.count == sideTwo.participants.count,
      players.allSatisfy({
        !$0.id.isEmpty && !$0.nameAtMatch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      }),
      Set(players.map(\.id)).count == players.count
    else {
      throw MatchError(
        "Enter names for both sides and every player. Both sides must use the same singles or doubles format."
      )
    }
  }

  mutating func append(_ kind: EventKind, side: Side? = nil, now: Date = Date()) throws {
    let event = ScoreEvent(
      sequence: events.count, type: kind, payload: side.map { ["side": $0] } ?? [:],
      occurredAt: max(now, updatedAt))
    var proposed = self
    proposed.events.append(event)
    let state = try Scoring.replay(proposed)
    proposed.updatedAt = event.occurredAt
    proposed.status = state.status
    proposed.winner = state.winner
    proposed.completedAt = state.winner == nil ? nil : event.occurredAt
    self = proposed
  }
}

/// Authoritative event replay. Undo removes a rally and its end-change acknowledgment;
/// redo restores both. All sport state is rebuilt from the effective rally sequence.
enum Scoring {
  private struct Rally {
    let side: Side
    var acknowledged = false
  }

  static func replay(_ match: Match) throws -> Score {
    try match.validateConfiguration()
    var initial: Side?
    var rallies: [Rally] = []
    var redo: [Rally] = []
    var state = Score()
    for (index, event) in match.events.enumerated() {
      guard event.sequence == index else {
        throw MatchError("Event sequence must be contiguous from zero.")
      }
      let needsSide = event.type == .server || event.type == .point
      guard needsSide ? (event.payload.count == 1 && event.side != nil) : event.payload.isEmpty
      else {
        throw MatchError("Invalid score event payload.")
      }
      switch event.type {
      case .server:
        guard initial == nil else {
          throw MatchError("The initial server has already been chosen.")
        }
        initial = event.side
        state = started(match, server: initial!)
      case .point:
        guard initial != nil, state.winner == nil, state.prompt == nil else {
          throw MatchError(
            "Choose a server, finish the end change, or undo the completed match before scoring.")
        }
        rallies.append(Rally(side: event.side!))
        redo = []
        award(&state, side: event.side!, match: match)
      case .changeEnds:
        guard state.prompt != nil, !rallies.isEmpty else {
          throw MatchError("There is no pending change of ends.")
        }
        rallies[rallies.count - 1].acknowledged = true
        state.prompt = nil
      case .undo:
        guard let rally = rallies.popLast(), let first = initial else {
          throw MatchError("There is no rally to undo.")
        }
        redo.append(rally)
        state = rebuild(match, initial: first, rallies: rallies)
      case .redo:
        guard let rally = redo.popLast(), let first = initial else {
          throw MatchError("There is no rally to redo.")
        }
        rallies.append(rally)
        state = rebuild(match, initial: first, rallies: rallies)
      }
    }
    state.canUndo = !rallies.isEmpty
    state.canRedo = !redo.isEmpty
    return state
  }

  private static func started(_ match: Match, server: Side) -> Score {
    var state = Score()
    state.server = server
    state.gameServer = server
    state.serviceNumber =
      match.preset.sport == .pickleball ? (match.sideOne.participants.count == 2 ? 2 : 1) : 0
    return state
  }

  private static func rebuild(_ match: Match, initial: Side, rallies: [Rally]) -> Score {
    var state = started(match, server: initial)
    for rally in rallies {
      award(&state, side: rally.side, match: match)
      if rally.acknowledged { state.prompt = nil }
    }
    return state
  }

  private static func award(_ s: inout Score, side: Side, match: Match) {
    let preset = match.preset
    let sport = preset.sport
    let i = side.index
    let j = side.opponent.index
    if sport == .pickleball && side != s.server {
      if match.sideOne.participants.count == 2 && s.serviceNumber == 1 {
        s.serviceNumber = 2
      } else {
        s.server = s.server?.opponent
        s.serviceNumber = 1
      }
      return
    }
    s.points[i] += 1
    if sport == .tennis {
      let target = s.isTiebreak ? 7 : 4
      if s.points[i] >= target && s.points[i] - s.points[j] >= 2 {
        completeTennisGame(&s, side: side)
      } else if s.isTiebreak {
        let total = s.points.reduce(0, +)
        s.server =
          ((total - 1) / 2).isMultiple(of: 2) ? s.tiebreakServer?.opponent : s.tiebreakServer
        if total.isMultiple(of: 6) { s.prompt = "Change ends after every six tiebreak points." }
      }
      return
    }
    let won =
      (s.points[i] >= preset.pointsToWinGame && s.points[i] - s.points[j] >= 2)
      || s.points[i] == preset.pointCap
    if won {
      s.completedGames.append(GameResult(points: s.points, set: 1, tiebreak: false))
      s.games[i] += 1
      s.points = [0, 0]
      s.intervalReached = false
      if sport == .badminton { s.server = side }
      if s.games[i] >= preset.unitsToWin {
        s.winner = side
        s.prompt = nil
        return
      }
      s.gameNumber += 1
      s.gameServer = sport == .badminton ? side : s.gameServer?.opponent
      s.server = s.gameServer
      if sport == .pickleball { s.serviceNumber = match.sideOne.participants.count == 2 ? 2 : 1 }
      s.prompt = "Change ends before the next game."
      return
    }
    if sport == .badminton { s.server = side }
    if sport == .tableTennis {
      let total = s.points.reduce(0, +)
      let block = s.points.allSatisfy { $0 >= 10 } ? total : total / 2
      s.server = block.isMultiple(of: 2) ? s.gameServer : s.gameServer?.opponent
    }
    let midpoint =
      sport == .tableTennis ? 5 : sport == .badminton ? 11 : preset.pointsToWinGame / 2 + 1
    if s.gameNumber == preset.unitsToWin * 2 - 1 && !s.intervalReached
      && s.points.contains(midpoint)
    {
      s.intervalReached = true
      s.prompt = "Change ends at the deciding-game midpoint."
    }
  }

  private static func completeTennisGame(_ s: inout Score, side: Side) {
    let wasTiebreak = s.isTiebreak
    s.completedGames.append(GameResult(points: s.points, set: s.setNumber, tiebreak: wasTiebreak))
    s.games[side.index] += 1
    s.points = [0, 0]
    let nextServer = wasTiebreak ? s.tiebreakServer?.opponent : s.server?.opponent
    let odd = !s.games.reduce(0, +).isMultiple(of: 2)
    let setWon = wasTiebreak || (s.games[side.index] >= 6 && abs(s.games[0] - s.games[1]) >= 2)
    s.server = nextServer
    s.gameServer = nextServer
    s.isTiebreak = false
    s.tiebreakServer = nil
    if setWon {
      s.completedSets.append(s.games)
      s.sets[side.index] += 1
      if s.sets[side.index] == 2 {
        s.winner = side
        s.prompt = nil
        return
      }
      s.games = [0, 0]
      s.setNumber += 1
      s.prompt = odd ? "Change ends after this set." : nil
    } else {
      s.isTiebreak = s.games == [6, 6]
      s.tiebreakServer = s.isTiebreak ? nextServer : nil
      s.prompt = odd ? "Change ends after this odd-numbered game." : nil
    }
    s.gameNumber += 1
  }
}
