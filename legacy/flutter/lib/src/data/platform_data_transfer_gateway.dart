import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

import '../application/data_transfer_gateway.dart';

final class PlatformDataTransferGateway implements DataTransferGateway {
  const PlatformDataTransferGateway();

  @override
  Future<String?> pickJsonBackup() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(
          label: 'Court Tally JSON backup',
          extensions: <String>['json'],
          mimeTypes: <String>['application/json'],
          uniformTypeIdentifiers: <String>['public.json'],
        ),
      ],
      confirmButtonText: 'Import backup',
    );
    if (file == null) {
      return null;
    }
    const maximumBackupBytes = 10 * 1024 * 1024;
    if (await file.length() > maximumBackupBytes) {
      throw const FormatException(
        'Backup is larger than the 10 MiB import safety limit.',
      );
    }
    return file.readAsString();
  }

  @override
  Future<void> shareDocument({
    required String fileName,
    required String mimeType,
    required String contents,
  }) async {
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(contents)),
      mimeType: mimeType,
      name: fileName,
    );
    await SharePlus.instance.share(
      ShareParams(
        title: 'Export Court Tally data',
        files: <XFile>[file],
        fileNameOverrides: <String>[fileName],
      ),
    );
  }
}
