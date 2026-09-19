# Third-party notices

Court Tally is distributed under the [MIT License](LICENSE). It uses the
open-source software below. Versions are locked by `pubspec.lock`; that file is
the authoritative dependency inventory for a particular source revision.

## Runtime dependencies

| Component | Purpose | License | Source |
|---|---|---|---|
| Flutter and Dart SDK | Cross-platform application framework and runtime | BSD 3-Clause | <https://github.com/flutter/flutter> |
| drift | Typed SQLite persistence | MIT | <https://pub.dev/packages/drift> |
| flutter_riverpod / riverpod | Dependency injection and application state | MIT | <https://pub.dev/packages/flutter_riverpod> |
| path_provider and platform implementations | App-local filesystem locations | BSD 3-Clause | <https://pub.dev/packages/path_provider> |
| file_selector and platform implementations | User-invoked JSON import/export picker | BSD 3-Clause | <https://pub.dev/packages/file_selector> |
| share_plus and platform implementations | User-invoked operating-system share sheet | BSD 3-Clause | <https://pub.dev/packages/share_plus> |
| sqlite3 Dart package | Native SQLite bindings used by drift | MIT | <https://pub.dev/packages/sqlite3> |
| SQLite | Embedded database engine | Public domain | <https://sqlite.org/copyright.html> |
| Material Design icons included with Flutter | Interface icon font | Apache License 2.0 | <https://fonts.google.com/icons> |

Flutter also incorporates transitive components. A Flutter build generates the
complete bundled license notice from the resolved dependency graph (for
example `build/flutter_assets/NOTICES.Z`). Keep that generated notice in every
binary distribution; do not replace it with this summary. Review dependency
changes and their licenses whenever `pubspec.lock` changes.

## Project artwork

The Court Tally app icon and its raster exports are original project artwork.
Their license is recorded in [`assets/branding/LICENSE.md`](assets/branding/LICENSE.md).
The blank generated launch placeholders contain no third-party artwork.

This notice is informational and does not alter any component's license terms.
