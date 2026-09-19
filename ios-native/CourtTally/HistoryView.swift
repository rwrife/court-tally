import SwiftUI
import UniformTypeIdentifiers

struct HistoryView: View {
  @EnvironmentObject private var model: AppModel
  @State private var search = ""
  @State private var sport: Sport?
  @State private var status = "All matches"
  @State private var useDates = false
  @State private var from = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
  @State private var through = Date()
  @State private var deleting: Match?
  @State private var exportDocument: ExportDocument?
  @State private var exporting = false
  var filtered: [Match] {
    model.matches.filter { match in
      let names =
        ([match.sideOne.name, match.sideTwo.name]
        + (match.sideOne.participants + match.sideTwo.participants).map(\.nameAtMatch)).joined(
          separator: " ")
      let end = Calendar.current.date(
        byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: through))!
      return (sport == nil || match.preset.sport == sport)
        && (search.isEmpty || names.localizedCaseInsensitiveContains(search))
        && (status == "All matches"
          || (status == "Completed" ? match.winner != nil : match.winner == nil))
        && (!useDates
          || (match.createdAt >= Calendar.current.startOfDay(for: from) && match.createdAt < end))
    }.sorted { $0.updatedAt > $1.updatedAt }
  }
  var body: some View {
    List {
      Section {
        HStack {
          VStack(alignment: .leading, spacing: 6) {
            Eyebrow(text: "Your time on court")
            Text("Every match,\nremembered.").font(.title.bold())
          }
          Spacer()
          Image(systemName: "clock.arrow.circlepath").font(.largeTitle).foregroundStyle(
            Color.accentColor)
        }.padding(.vertical, 8)
      }.listRowBackground(Color.clear)
      Section {
        Picker("Sport", selection: $sport) {
          Text("All sports").tag(Optional<Sport>.none)
          ForEach(Sport.allCases) { Text($0.name).tag(Optional($0)) }
        }
        Picker("Status", selection: $status) {
          ForEach(["All matches", "Completed", "In progress"], id: \.self) { Text($0) }
        }
        DisclosureGroup("Date range") {
          Toggle("Filter by date", isOn: $useDates)
          if useDates {
            DatePicker("From", selection: $from, displayedComponents: .date)
            DatePicker("Through", selection: $through, in: from..., displayedComponents: .date)
          }
        }
      }
      Section("\(filtered.count) matches") {
        if filtered.isEmpty {
          Text(
            model.matches.isEmpty
              ? "Your matches will appear here. Start a game from the Play tab."
              : "No matches match these filters."
          ).foregroundStyle(.secondary).padding(.vertical)
        }
        ForEach(filtered) { match in
          NavigationLink {
            MatchDetailView(matchID: match.id)
          } label: {
            VStack(alignment: .leading, spacing: 7) {
              HStack {
                Text(match.preset.sport.name).font(.caption.weight(.semibold)).foregroundStyle(
                  .teal)
                Spacer()
                Text(match.createdAt, style: .date).font(.caption).foregroundStyle(.secondary)
              }
              Text(match.title).font(.headline)
              HStack {
                Text(match.winner.map { "\(match.team($0).name) won" } ?? "In progress")
                Spacer()
                Text(resultSummary(match)).monospacedDigit()
              }.font(.subheadline).foregroundStyle(.secondary)
            }.padding(.vertical, 8)
          }.swipeActions { Button("Delete", role: .destructive) { deleting = match } }
        }
      }
    }
    .navigationTitle("Match history").searchable(text: $search, prompt: "Find a player or team")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          exportDocument = ExportDocument(
            data: BackupCodec.csv(filtered), type: .commaSeparatedText)
          exporting = true
        } label: {
          Label("Export filtered CSV", systemImage: "square.and.arrow.up")
        }.disabled(filtered.isEmpty)
      }
    }
    .fileExporter(
      isPresented: $exporting, document: exportDocument, contentType: .commaSeparatedText,
      defaultFilename: "court-tally-matches"
    ) { result in
      if case .failure(let error) = result { model.error = error.localizedDescription }
    }
    .confirmationDialog(
      "Delete this match?",
      isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
      titleVisibility: .visible
    ) {
      Button("Delete match", role: .destructive) {
        if let match = deleting { model.delete(match) }
        deleting = nil
      }
    } message: {
      Text("The match and its score events will be permanently removed from native history.")
    }
  }
}

struct MatchDetailView: View {
  @EnvironmentObject private var model: AppModel
  let matchID: String
  @State private var replayCount = 0
  @State private var document: ExportDocument?
  @State private var exporting = false
  private var match: Match? { model.matches.first { $0.id == matchID } }
  var body: some View {
    List {
      if let match {
        Section {
          Text(match.title).font(.title2.bold())
          Text(match.preset.name).foregroundStyle(.secondary)
          Text(match.winner.map { "\(match.team($0).name) won" } ?? "In progress").font(.headline)
            .foregroundStyle(Color.accentColor)
          if !resultSummary(match).isEmpty { Text(resultSummary(match)).monospacedDigit() }
          if match.winner == nil { Button("Resume match") { model.resume(match) } }
        }
        Section("Game scores") {
          ForEach(Array(match.score.completedGames.enumerated()), id: \.offset) { index, game in
            HStack {
              Text("Game \(index + 1)\(game.tiebreak ? " · Tiebreak" : "")")
              Spacer()
              Text("\(game.points[0]) – \(game.points[1])").monospacedDigit()
            }
          }
        }
        Section("Replay the match") {
          Stepper(
            "Event \(replayCount) of \(match.events.count)", value: $replayCount,
            in: 0...match.events.count)
          let replay = replayScore(match)
          Text(
            "\(match.sideOne.name) \(replay.label(.one, sport: match.preset.sport)) – \(replay.label(.two, sport: match.preset.sport)) \(match.sideTwo.name)"
          ).font(.headline)
          Text(
            "Games \(replay.games[0])–\(replay.games[1]) · Sets \(replay.sets[0])–\(replay.sets[1])"
          ).font(.subheadline)
          if let server = replay.server {
            Text("Serving: \(match.team(server).name)").font(.subheadline)
          }
          if let prompt = replay.prompt { Text(prompt).foregroundStyle(.secondary) }
        }
        Section("Score events") {
          ForEach(match.events) { event in
            HStack {
              Text("\(event.sequence + 1)").monospacedDigit().foregroundStyle(.secondary).frame(
                minWidth: 28)
              Text(event.label)
              Spacer()
              if let side = event.side { Text(match.team(side).name).foregroundStyle(.secondary) }
            }.font(.subheadline)
          }
        }
      }
    }.navigationTitle("Match details").navigationBarTitleDisplayMode(.inline)
      .onAppear { replayCount = match?.events.count ?? 0 }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            if let match {
              do {
                document = ExportDocument(data: try BackupCodec.encode([match]), type: .json)
                exporting = true
              } catch { model.error = error.localizedDescription }
            }
          } label: {
            Label("Export match", systemImage: "square.and.arrow.up")
          }
        }
      }
      .fileExporter(
        isPresented: $exporting, document: document, contentType: .json,
        defaultFilename: "court-tally-match"
      ) { result in
        if case .failure(let error) = result { model.error = error.localizedDescription }
      }
  }
  private func replayScore(_ match: Match) -> Score {
    var replay = match
    replay.events = Array(match.events.prefix(replayCount))
    return replay.score
  }
}
