// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CourtTallyCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [.library(name: "CourtTallyCore", targets: ["CourtTallyCore"])],
    targets: [
        .target(name: "CourtTallyCore", linkerSettings: [.linkedLibrary("sqlite3")]),
        .testTarget(name: "CourtTallyCoreTests", dependencies: ["CourtTallyCore"],
                    resources: [.copy("legacy-v1.json"), .copy("dart-parity.json")])
    ]
)
