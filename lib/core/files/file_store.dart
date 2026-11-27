import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stores picked photos and files inside PocketCRM's private app storage.
class FileStore {
  FileStore({Future<Directory> Function()? baseDirProvider})
      : _baseDirProvider = baseDirProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _baseDirProvider;

  /// Copies [sourcePath] into `<appDocs>/attachments/<timestamp>_<basename>`
  /// and returns the new path. Returns [sourcePath] unchanged if the file does
  /// not exist on disk (e.g. test stub paths).
  Future<String> copyIntoStorage(String sourcePath, {DateTime? now}) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      return sourcePath;
    }

    final baseDir = await _baseDirProvider();
    final attachmentsDir = Directory(p.join(baseDir.path, 'attachments'));
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final ts = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final cleanName = p.basename(sourcePath).replaceAll(RegExp(r'[^\w.\-]'), '_');
    final destPath = p.join(attachmentsDir.path, '${ts}_$cleanName');
    await source.copy(destPath);
    return destPath;
  }

  /// Deletes a stored attachment file if it exists inside app storage.
  Future<void> deleteIfExists(String path) async {
    final f = File(path);
    if (await f.exists()) {
      try {
        await f.delete();
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }
}
