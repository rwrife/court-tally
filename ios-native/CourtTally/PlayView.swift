import SwiftUI

struct PlayView: View {
  @EnvironmentObject private var model: AppModel
  var body: some View {
    Group {
      if let match = model.active { LiveMatchView(match: match) } else { SetupView() }
    }
    .navigationTitle("Court Tally")
    .navigationBarTitleDisplayMode(model.active == nil ? .large : .inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Image(systemName: "sportscourt.fill").foregroundStyle(Color.accentColor)
          .accessibilityHidden(true)
      }
    }
  }
}

struct SetupView: View {
  @EnvironmentObject private var model: AppModel
  @State private var sport = Sport.pickleball
  @State private var presetID = Preset.all[0].id
  @State private var doubles = false
  @State private var one = ""
  @State private var two = ""
  @State private var partnerOne = ""
  @State private var partnerTwo = ""
  @State private var server = Side.one
  private enum Field: Hashable { case one, two, partnerOne, partnerTwo }
  @FocusState private var editing: Field?
  var valid: Bool {
    ([one, two] + (doubles ? [partnerOne, partnerTwo] : [])).allSatisfy {
      !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }
  var body: some View {
    Form {
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Eyebrow(text: "Less counting. More playing.")
          Text("Make every\npoint count.").font(.largeTitle.bold())
          Text("Four sports. One simple scorecard.").foregroundStyle(.secondary)
        }.padding(.vertical, 12)
      }.listRowBackground(Color.clear)
      Section("Choose your game") {
        Picker("Sport", selection: $sport) { ForEach(Sport.allCases) { Text($0.name).tag($0) } }
          .accessibilityIdentifier("sportPicker")
        Picker("Rules", selection: $presetID) {
          ForEach(Preset.all.filter { $0.sport == sport }) { Text($0.name).tag($0.id) }
        }
        Toggle("Doubles", isOn: $doubles)
      }
      Section("Who's playing?") {
        TextField("Side 1 name", text: $one).focused($editing, equals: .one)
          .accessibilityIdentifier("sideOneName").submitLabel(.next).onSubmit {
            editing = doubles ? .partnerOne : .two
          }
        if doubles {
          TextField("Side 1 partner", text: $partnerOne).focused($editing, equals: .partnerOne)
            .submitLabel(.next).onSubmit { editing = .two }
        }
        TextField("Side 2 name", text: $two).focused($editing, equals: .two)
          .accessibilityIdentifier("sideTwoName").submitLabel(doubles ? .next : .done).onSubmit {
            editing = doubles ? .partnerTwo : nil
          }
        if doubles {
          TextField("Side 2 partner", text: $partnerTwo).focused($editing, equals: .partnerTwo)
            .submitLabel(.done).onSubmit { editing = nil }
        }
        Picker("First serve", selection: $server) {
          Text(one.isEmpty ? "Side 1" : one).tag(Side.one)
          Text(two.isEmpty ? "Side 2" : two).tag(Side.two)
        }
      }
      Section {
        Button {
          editing = nil
          model.start(
            preset: Preset.all.first { $0.id == presetID }!,
            one: Team(name: one, partner: doubles ? partnerOne : nil),
            two: Team(name: two, partner: doubles ? partnerTwo : nil), server: server)
        } label: {
          Label("Start match", systemImage: "play.fill").font(.headline).frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }.buttonStyle(.borderedProminent).disabled(!valid).accessibilityIdentifier("startMatch")
      } footer: {
        Label("No account. No ads. Works offline.", systemImage: "lock.shield").frame(
          maxWidth: .infinity
        ).padding(.top, 12)
      }.listRowBackground(Color.clear)
    }
    .onChange(of: sport) { newValue in presetID = Preset.all.first { $0.sport == newValue }!.id }
    .toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("Done") { editing = nil }
      }
    }
  }
}

struct LiveMatchView: View {
  @EnvironmentObject private var model: AppModel
  let match: Match
  @State private var abandon = false
  @State private var finish = false
  @Environment(\.dynamicTypeSize) private var typeSize
  private var state: Score { match.score }
  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          HStack {
            Label(match.preset.sport.name, systemImage: match.preset.sport.symbol).font(
              .subheadline.weight(.semibold))
            Spacer()
            Text(state.winner == nil ? "LIVE MATCH" : "COMPLETE").font(.caption.bold()).tracking(1)
              .foregroundStyle(Color.accentColor)
          }
          Text(match.title).font(.title2.bold()).accessibilityAddTraits(.isHeader)
          Text(match.preset.name).font(.subheadline).foregroundStyle(.secondary)
          if state.server == nil {
            Card {
              Text("Choose the initial server").font(.headline)
              ForEach(Side.allCases, id: \.self) { side in
                Button("\(match.team(side).name) serves first") {
                  model.record(.server, side: side)
                }.buttonStyle(.borderedProminent)
              }
            }
          } else {
            HStack(spacing: 16) {
              metric("GAME", value: String(state.gameNumber))
              metric("GAMES", value: "\(state.games[0]) – \(state.games[1])")
              if match.preset.sport == .tennis {
                metric("SETS", value: "\(state.sets[0]) – \(state.sets[1])")
              } else if match.preset.sport == .pickleball {
                metric("SERVER", value: String(state.serviceNumber))
              }
            }
            if geometry.size.width > 600 && !typeSize.isAccessibilitySize {
              HStack(spacing: 14) {
                scoreButton(.one)
                scoreButton(.two)
              }
            } else {
              VStack(spacing: 14) {
                scoreButton(.one)
                scoreButton(.two)
              }
            }
            if let winner = state.winner {
              Card {
                Label("\(match.team(winner).name) wins!", systemImage: "trophy.fill").font(
                  .title2.bold())
                Text(resultSummary(match)).foregroundStyle(.secondary)
                Button("Finish match") { finish = true }.buttonStyle(.borderedProminent)
              }
            } else if let prompt = state.prompt {
              Card {
                Label("Change ends", systemImage: "arrow.left.arrow.right").font(.headline)
                Text(prompt)
                Button("Confirm sides changed") { model.record(.changeEnds) }.buttonStyle(
                  .borderedProminent)
              }
            } else {
              Text(state.isTiebreak ? "Tiebreak • win by two" : "Tap the side that wins the rally.")
                .font(.footnote).foregroundStyle(.secondary).frame(maxWidth: .infinity)
            }
            HStack {
              Button {
                model.record(.undo)
              } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
              }
              .disabled(!state.canUndo).accessibilityIdentifier("undoRally")
              Spacer()
              Button {
                model.record(.redo)
              } label: {
                Label("Redo", systemImage: "arrow.uturn.forward")
              }
              .disabled(!state.canRedo)
            }.buttonStyle(.bordered).controlSize(.large)
          }
          Button("Abandon match", role: .destructive) { abandon = true }.font(.footnote).frame(
            maxWidth: .infinity
          ).padding(.vertical, 8)
        }.padding(20).frame(maxWidth: 900).frame(maxWidth: .infinity)
      }.background(Color(.systemGroupedBackground))
    }
    .confirmationDialog("Abandon this match?", isPresented: $abandon, titleVisibility: .visible) {
      Button("Abandon and delete", role: .destructive) { model.delete(match) }
    } message: {
      Text("This removes the match and all of its score events.")
    }
    .confirmationDialog(
      "Save the completed match to history?", isPresented: $finish, titleVisibility: .visible
    ) {
      Button("Finish match") { model.finish() }
    }
  }
  private func metric(_ title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Eyebrow(text: title)
      Text(value).font(.title3.monospacedDigit().bold())
    }.frame(maxWidth: .infinity, alignment: .leading).padding(14).background(
      .quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))
  }
  private func scoreButton(_ side: Side) -> some View {
    let serving = state.server == side
    let foreground: Color = side == .one ? .white : .primary
    return Button {
      model.record(.point, side: side)
    } label: {
      HStack(alignment: .center, spacing: 12) {
        VStack(alignment: .leading, spacing: 10) {
          Text(match.team(side).name).font(.title2.bold()).multilineTextAlignment(.leading)
          if match.team(side).participants.count == 2 {
            Text(match.team(side).participants.map(\.nameAtMatch).joined(separator: " + ")).font(
              .subheadline)
          }
          Label(serving ? "SERVING" : "RECEIVING", systemImage: serving ? "circle.fill" : "circle")
            .font(.caption.weight(.bold)).tracking(1)
        }
        Spacer(minLength: 4)
        Text(state.label(side, sport: match.preset.sport)).font(
          .system(size: 72, weight: .bold, design: .rounded)
        ).monospacedDigit().minimumScaleFactor(0.5)
      }.foregroundStyle(foreground).padding(24).frame(maxWidth: .infinity, minHeight: 156)
        .background(
          side == .one
            ? Color(red: 0.02, green: 0.34, blue: 0.30) : Color(.secondarySystemGroupedBackground),
          in: RoundedRectangle(cornerRadius: 26)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 26).strokeBorder(
            side == .one ? Color.clear : Color.accentColor.opacity(0.25), lineWidth: 1))
    }
    .buttonStyle(.plain).disabled(state.winner != nil || state.prompt != nil)
    .accessibilityLabel("Award rally to \(match.team(side).name)")
    .accessibilityValue(
      "\(state.label(side, sport: match.preset.sport)). \(serving ? "Serving" : "Receiving")"
    )
    .accessibilityIdentifier(side == .one ? "scoreOne" : "scoreTwo")
  }
}

func resultSummary(_ match: Match) -> String {
  let state = match.score
  if match.preset.sport == .tennis {
    return state.completedSets.map { "\($0[0])–\($0[1])" }.joined(separator: ", ")
  }
  return state.completedGames.map { "\($0.points[0])–\($0.points[1])" }.joined(separator: ", ")
}
