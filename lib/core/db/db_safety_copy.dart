import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Copies an existing `pocket_crm.db` (and its `-wal`/`-shm` sidecars if
/// present) to `pocket_crm.v4.bak*` before Drift ever opens the file.
///
/// Does nothing if the database does not exist yet or if the `.v4.bak` file
/// already exists.
Future<void> ensureV4SafetyCopy(String dbFilePath) async {
  final dbFile = File(dbFilePath);
  if (!await dbFile.exists()) return;

  final dir = p.dirname(dbFilePath);
  final bakPath = p.join(dir, 'pocket_crm.v4.bak');
  final bakFile = File(bakPath);
  if (await bakFile.exists()) return;

  await dbFile.copy(bakPath);
  debugPrint('Created v4 safety backup at $bakPath');

  for (final suffix in const ['-wal', '-shm']) {
    final sidecar = File('$dbFilePath$suffix');
    if (await sidecar.exists()) {
      await sidecar.copy('$bakPath$suffix');
    }
  }
}
