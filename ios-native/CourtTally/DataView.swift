import SwiftUI
import UniformTypeIdentifiers

struct ExportDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.json, .commaSeparatedText] }
  let data: Data
  let type: UTType
  init(data: Data, type: UTType) {
    self.data = data
    self.type = type
  }
  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents else {
      throw MatchError("Could not read the file.")
    }
    self.data = data
    type = configuration.contentType
  }
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    FileWrapper(regularFileWithContents: data)
  }
}

struct DataView: View {
  @EnvironmentObject private var model: AppModel
  @State private var document: ExportDocument?
  @State private var exportType = UTType.json
  @State private var exporting = false
  @State private var importing = false
  @State private var pending: Backup?
  @State private var preview = false
  @State private var replace = false
  @State private var erase = false
  @State private var eraseLegacy = false
  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 12) {
          Image(systemName: "lock.shield.fill").font(.system(size: 40)).foregroundStyle(
            Color.accentColor)
          Text("Your game.\nYour data.").font(.largeTitle.bold())
          Text("Saved on your device. No accounts, ads, tracking, or cloud service.")
            .foregroundStyle(.secondary)
        }.padding(.vertical, 10)
      }.listRowBackground(Color.clear)
      Section("Take your scores with you") {
        Button {
          export(json: true)
        } label: {
          Label("Export JSON backup", systemImage: "arrow.up.doc")
        }
        Button {
          export(json: false)
        } label: {
          Label("Export CSV summary", systemImage: "tablecells")
        }
        Button {
          importing = true
        } label: {
          Label("Import JSON backup", systemImage: "arrow.down.doc")
        }
      }
      Section {
        Text(
          "JSON preserves every match and score event and can restore your history. CSV is a summary for spreadsheets."
        )
        Text(
          "Back up before uninstalling or changing devices. Court Tally has no server copy of your matches."
        )
      }.font(.footnote).foregroundStyle(.secondary)
      if model.hasLegacyArchive {
        Section("Flutter recovery copy") {
          Text(
            "Your previous database was imported and kept on this device as a recovery copy. Deleting individual native matches does not remove this original copy."
          ).font(.footnote)
          Button("Remove Flutter recovery copy", role: .destructive) { eraseLegacy = true }
        }
      }
      Section("Privacy controls") {
        LabeledContent("Saved matches", value: String(model.matches.count))
        Button("Delete all local history", role: .destructive) { erase = true }
        NavigationLink("Privacy policy") { PrivacyView() }
      }
      Section {
        Text("Court Tally 1.0").font(.footnote).foregroundStyle(.secondary)
        Text("For recreational scorekeeping. Not an officiating service.").font(.footnote)
          .foregroundStyle(.secondary)
      }.listRowBackground(Color.clear)
    }
    .navigationTitle("Your data")
    .fileExporter(
      isPresented: $exporting, document: document, contentType: exportType,
      defaultFilename: exportType == .json ? "court-tally-backup" : "court-tally-summary"
    ) { result in
      if case .failure(let error) = result { model.error = error.localizedDescription }
    }
    .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
      do {
        let url = try result.get()
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size <= 50_000_000 else { throw MatchError("Backup exceeds the 50 MB import limit.") }
        pending = try BackupCodec.decode(Data(contentsOf: url))
        preview = true
      } catch { model.error = "Import was not applied. \(error.localizedDescription)" }
    }
    .sheet(isPresented: $preview) {
      NavigationStack {
        if let pending {
          let conflicts = pending.matches.filter { imported in
            model.matches.contains { $0.id == imported.id }
          }.count
          List {
            Section("Validated backup") {
              LabeledContent("Matches in backup", value: String(pending.matches.count))
              LabeledContent("New matches", value: String(pending.matches.count - conflicts))
              LabeledContent("Matching IDs", value: String(conflicts))
              LabeledContent("Currently on device", value: String(model.matches.count))
            }
            Section {
              Button("Merge — keep existing matches") {
                model.apply(pending, replace: false)
                preview = false
              }
              Text("Adds new matches. Existing matches with matching IDs stay unchanged.").font(
                .footnote
              ).foregroundStyle(.secondary)
              Button("Replace all native history…", role: .destructive) { replace = true }
              Text("Removes native matches that are not in this backup and replaces matching IDs.")
                .font(.footnote).foregroundStyle(.secondary)
            }
          }.navigationTitle("Import preview")
            .toolbar {
              ToolbarItem(placement: .cancellationAction) { Button("Cancel") { preview = false } }
            }
            .confirmationDialog(
              "Replace all native history?", isPresented: $replace, titleVisibility: .visible
            ) {
              Button("Replace history", role: .destructive) {
                model.apply(pending, replace: true)
                preview = false
              }
            } message: {
              Text("This cannot be undone. Export a backup first if you need your current history.")
            }
        }
      }
    }
    .confirmationDialog("Delete all local history?", isPresented: $erase, titleVisibility: .visible)
    {
      Button("Delete all history", role: .destructive) { model.deleteAll() }
    } message: {
      Text(
        "All matches, score events, and any Flutter recovery copy will be permanently removed. Export a JSON backup first."
      )
    }
    .confirmationDialog(
      "Remove the Flutter recovery copy?", isPresented: $eraseLegacy, titleVisibility: .visible
    ) {
      Button("Remove recovery copy", role: .destructive) { model.eraseLegacyArchive() }
    } message: {
      Text("Native history will remain. The original Flutter database will be permanently deleted.")
    }
  }
  private func export(json: Bool) {
    do {
      exportType = json ? .json : .commaSeparatedText
      document = ExportDocument(
        data: try json ? BackupCodec.encode(model.matches) : BackupCodec.csv(model.matches),
        type: exportType)
      exporting = true
    } catch { model.error = error.localizedDescription }
  }
}

struct PrivacyView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("Private by design").font(.title.bold())
        Text(
          "Court Tally stores player names, rules, matches, and score events in the app's private storage on your device. There are no accounts, ads, analytics, tracking SDKs, or developer-operated servers."
        )
        Text(
          "Export and import happen only when you request them. You choose a destination in the system file picker. Once you share a backup with another service, that service's privacy terms apply."
        )
        Text(
          "You can delete matches or all local history. Following a Flutter migration, the original database remains as a recovery copy until you remove it in Your data. Delete all local history removes that copy too. Device backups may retain data under your system backup settings."
        )
        Text(
          "Uninstalling may remove local data. Keep a JSON backup before changing devices or removing the app. CSV cannot restore your history."
        )
        Link(
          "Questions or privacy issues",
          destination: URL(string: "https://github.com/rwrife/court-tally/issues")!)
        Text("Do not include private match data in a public issue.").font(.footnote)
          .foregroundStyle(.secondary)
      }.padding(24)
    }.navigationTitle("Privacy").navigationBarTitleDisplayMode(.inline)
  }
}
