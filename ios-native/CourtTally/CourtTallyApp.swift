import SwiftUI

@main
struct CourtTallyApp: App {
  @StateObject private var model = AppModel()
  var body: some Scene {
    WindowGroup {
      RootView().environmentObject(model).tint(Color.accentColor)
    }
  }
}

struct RootView: View {
  @EnvironmentObject private var model: AppModel
  var body: some View {
    Group {
      if model.loaded {
        TabView(selection: $model.selectedTab) {
          NavigationStack { PlayView() }.tabItem { Label("Play", systemImage: "sportscourt") }.tag(
            0)
          NavigationStack { HistoryView() }.tabItem {
            Label("History", systemImage: "clock.arrow.circlepath")
          }.tag(1)
          NavigationStack { DataView() }.tabItem {
            Label("Your data", systemImage: "externaldrive")
          }.tag(2)
        }
      } else {
        VStack(spacing: 20) {
          Image(systemName: "externaldrive.badge.exclamationmark").font(.largeTitle)
          Text("Your scores are protected").font(.title2.bold())
          Text("Local data could not be opened. The original files have been left unchanged.")
            .multilineTextAlignment(.center)
          Button("Try again", action: model.reload).buttonStyle(.borderedProminent)
        }.padding(30)
      }
    }
    .alert(
      "Court Tally",
      isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })
    ) {
      Button("OK", role: .cancel) { model.error = nil }
    } message: {
      Text(model.error ?? "")
    }
  }
}

struct Eyebrow: View {
  let text: String
  var body: some View {
    Text(text.uppercased()).font(.caption.weight(.bold)).tracking(2).foregroundStyle(.secondary)
  }
}

struct Card<Content: View>: View {
  @ViewBuilder var content: Content
  var body: some View {
    VStack(alignment: .leading, spacing: 14) { content }
      .frame(maxWidth: .infinity, alignment: .leading).padding(20)
      .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24))
  }
}
