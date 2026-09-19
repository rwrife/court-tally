/// Boundary for explicit user-driven document import and platform sharing.
/// Implementations must use platform pickers/sheets rather than broad storage.
abstract interface class DataTransferGateway {
  Future<void> shareDocument({
    required String fileName,
    required String mimeType,
    required String contents,
  });

  /// Returns null when the operating-system picker is cancelled.
  Future<String?> pickJsonBackup();
}
