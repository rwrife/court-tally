import '../application/match_repository.dart';
import 'data_backup_codec.dart';
import 'match_csv_codec.dart';

final class ImportPreview {
  const ImportPreview({
    required this.backup,
    required this.currentMatches,
    required this.additions,
    required this.conflicts,
  });

  final DecodedBackup backup;
  final int currentMatches;
  final int additions;
  final int conflicts;

  int get backupMatches => backup.matches.length;
}

/// Coordinates explicit export, fully staged import preview, and the repository's
/// single transactional import write.
final class DataOwnershipService {
  const DataOwnershipService(
    this.repository, {
    this.backupCodec = const DataBackupCodec(),
    this.csvCodec = const MatchCsvCodec(),
  });

  final MatchRepository repository;
  final DataBackupCodec backupCodec;
  final MatchCsvCodec csvCodec;

  Future<RepositoryResult<String>> createJsonBackup({
    required DateTime exportedAt,
  }) async {
    final history = await repository.queryHistory(const MatchHistoryFilter());
    return switch (history) {
      RepositorySuccess<List<PersistedMatch>>(:final value) =>
        RepositorySuccess<String>(
          backupCodec.encode(value, exportedAt: exportedAt),
        ),
      RepositoryFailure<List<PersistedMatch>>(
        :final code,
        :final message,
        :final isRecoverable,
        :final cause,
      ) =>
        RepositoryFailure<String>(
          code: code,
          message: message,
          isRecoverable: isRecoverable,
          cause: cause,
        ),
    };
  }

  Future<RepositoryResult<String>> createCsvSummary() async {
    final history = await repository.queryHistory(const MatchHistoryFilter());
    return switch (history) {
      RepositorySuccess<List<PersistedMatch>>(:final value) =>
        RepositorySuccess<String>(csvCodec.encode(value)),
      RepositoryFailure<List<PersistedMatch>>(
        :final code,
        :final message,
        :final isRecoverable,
        :final cause,
      ) =>
        RepositoryFailure<String>(
          code: code,
          message: message,
          isRecoverable: isRecoverable,
          cause: cause,
        ),
    };
  }

  Future<RepositoryResult<ImportPreview>> previewImport(String source) async {
    final DecodedBackup backup;
    try {
      backup = backupCodec.decode(source);
    } on FormatException catch (error) {
      return RepositoryFailure<ImportPreview>(
        code: RepositoryFailureCode.invalidData,
        message: '${error.message} Existing data was not changed.',
        isRecoverable: true,
        cause: error,
      );
    }
    final current = await repository.queryHistory(const MatchHistoryFilter());
    if (current case RepositoryFailure<List<PersistedMatch>>(
      :final code,
      :final message,
      :final isRecoverable,
      :final cause,
    )) {
      return RepositoryFailure<ImportPreview>(
        code: code,
        message: message,
        isRecoverable: isRecoverable,
        cause: cause,
      );
    }
    final matches = (current as RepositorySuccess<List<PersistedMatch>>).value;
    final currentIds = matches.map((match) => match.configuration.id).toSet();
    final conflicts = backup.matches
        .where((match) => currentIds.contains(match.configuration.id))
        .length;
    return RepositorySuccess<ImportPreview>(
      ImportPreview(
        backup: backup,
        currentMatches: matches.length,
        additions: backup.matches.length - conflicts,
        conflicts: conflicts,
      ),
    );
  }

  Future<RepositoryResult<MatchImportResult>> applyImport(
    ImportPreview preview,
    MatchImportMode mode,
  ) {
    return repository.importMatches(
      matches: preview.backup.matches,
      mode: mode,
    );
  }
}
