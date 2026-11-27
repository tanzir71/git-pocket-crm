import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq3;

import '../../../core/db/app_database.dart';
import '../../../core/native/backup_api.g.dart';
import '../../../core/native/outbox_api.g.dart';
import '../../../core/phone/phone_service.dart';
import '../../messages/data/outbox_repository.dart';
import '../../settings/data/settings_repository.dart';
import 'backup_crypto.dart';

/// Abstraction over Android Storage Access Framework (SAF) Pigeon API.
abstract class BackupSafClient {
  Future<String?> createDocument(String name, String mime);
  Future<void> copyFileToUri(String path, String uri);
  Future<String?> pickDocument(List<String> mimeTypes);
}

class PigeonBackupSafClient implements BackupSafClient {
  PigeonBackupSafClient([BackupSafApi? api]) : _api = api ?? BackupSafApi();
  final BackupSafApi _api;

  @override
  Future<String?> createDocument(String name, String mime) => _api.createDocument(name, mime);

  @override
  Future<void> copyFileToUri(String path, String uri) => _api.copyFileToUri(path, uri);

  @override
  Future<String?> pickDocument(List<String> mimeTypes) => _api.pickDocument(mimeTypes);
}

enum BackupFormat { plainPcrm, encryptedPcrm, v1Json, unknown }

enum BackupStage {
  preparingDatabase,
  readingOutbox,
  packingFiles,
  encrypting,
  saving,
  decrypting,
  verifying,
  restoring,
  done,
}

class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAtMs,
    required this.includeAttachments,
    required this.counts,
  });

  final int formatVersion;
  final String appVersion;
  final int schemaVersion;
  final int createdAtMs;
  final bool includeAttachments;
  final Map<String, int> counts;

  int get contactsCount => counts['contacts'] ?? 0;
  int get timelineCount => counts['timeline'] ?? 0;
  int get filesCount => counts['attachments'] ?? 0;

  Map<String, dynamic> toJson() => {
        'formatVersion': formatVersion,
        'appVersion': appVersion,
        'schemaVersion': schemaVersion,
        'createdAtMs': createdAtMs,
        'includeAttachments': includeAttachments,
        'counts': counts,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    final rawCounts = (json['counts'] as Map?) ?? const {};
    return BackupManifest(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 1,
      appVersion: (json['appVersion'] as String?) ?? '2.0.0',
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 5,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      includeAttachments: (json['includeAttachments'] as bool?) ?? false,
      counts: {
        for (final entry in rawCounts.entries)
          entry.key.toString(): (entry.value as num?)?.toInt() ?? 0,
      },
    );
  }
}

class BackupInspection {
  const BackupInspection({
    required this.format,
    required this.needsPassphrase,
    this.manifest,
    this.v1Counts,
    this.v1TimestampMs,
  });

  final BackupFormat format;
  final bool needsPassphrase;
  final BackupManifest? manifest;
  final Map<String, int>? v1Counts;
  final int? v1TimestampMs;
}

class V1JsonImportResult {
  const V1JsonImportResult({
    required this.contactsImported,
    required this.timelineImported,
    required this.tasksImported,
    required this.scheduledImported,
  });

  final int contactsImported;
  final int timelineImported;
  final int tasksImported;
  final int scheduledImported;
}

class RestoreOutcome {
  const RestoreOutcome({
    required this.manifest,
    required this.reEnqueuedOutboxCount,
    required this.missedOutboxCount,
    required this.restoredFilesCount,
  });

  final BackupManifest manifest;
  final int reEnqueuedOutboxCount;
  final int missedOutboxCount;
  final int restoredFilesCount;
}

/// Creates, inspects, and restores `.pcrm` backups (plain and `PCRM1`-encrypted),
/// imports v1 JSON backups in merge mode, and maintains weekly local auto-backups.
class BackupService {
  BackupService({
    required this._db,
    required this._outboxClient,
    required this._safClient,
    required this._cacheDirProvider,
    required this._attachmentsDirProvider,
    required this._dbPathProvider,
    this._autoBackupDirProvider,
    BackupCrypto? crypto,
    PhoneService? phoneService,
    DateTime Function()? clock,
  })  : _crypto = crypto ?? BackupCrypto(),
        _phoneService = phoneService ?? const PhoneService(),
        _clock = clock ?? DateTime.now;

  static const String appVersion = '2.0.0';
  static const int currentFormatVersion = 1;
  static const int maxAutoBackupsToKeep = 4;

  final AppDatabase _db;
  final OutboxPlatformClient _outboxClient;
  final BackupSafClient _safClient;
  final Future<Directory> Function() _cacheDirProvider;
  final Future<Directory> Function() _attachmentsDirProvider;
  final Future<String> Function() _dbPathProvider;
  final Future<Directory?> Function()? _autoBackupDirProvider;
  final BackupCrypto _crypto;
  final PhoneService _phoneService;
  final DateTime Function() _clock;

  String defaultBackupFileName([DateTime? when]) {
    final dt = when ?? _clock();
    final date = DateFormat('yyyy-MM-dd').format(dt);
    return 'PocketCRM $date.pcrm';
  }

  /// Creates a `.pcrm` backup file at [destinationPath].
  Future<BackupManifest> createBackupFile({
    required String destinationPath,
    required bool includeAttachments,
    String? passphrase,
    bool recordLastBackupTimestamp = true,
    void Function(BackupStage stage)? onStage,
  }) async {
    final cacheDir = await _cacheDirProvider();
    final workDir = Directory(
      p.join(cacheDir.path, 'pcrm_work_${_clock().millisecondsSinceEpoch}'),
    );
    await workDir.create(recursive: true);

    try {
      onStage?.call(BackupStage.preparingDatabase);
      final snapshotDbPath = p.join(workDir.path, 'db.sqlite');
      await _db.vacuumInto(snapshotDbPath);

      onStage?.call(BackupStage.readingOutbox);
      List<OutboxItem> outboxItems = const [];
      try {
        final changes = await _outboxClient.changesSince(0);
        outboxItems = changes.items;
      } catch (_) {
        final mirrorRows = await _db.select(_db.outboxMessages).get();
        outboxItems = [
          for (final r in mirrorRows)
            OutboxItem(
              clientId: r.clientId,
              campaignId: r.campaignId,
              address: r.address,
              body: r.body,
              dueAtMs: r.dueAt,
              subId: r.subId,
              status: r.status,
              attempt: r.attempt,
              partsTotal: r.parts ?? 0,
              errorCode: r.errorCode,
              sentAtMs: r.sentAt,
              deliveredAtMs: r.deliveredAt,
            ),
        ];
      }

      onStage?.call(BackupStage.packingFiles);
      final counts = await _collectTableCounts();
      final attachmentFiles = <String, File>{};
      if (includeAttachments) {
        final attDir = await _attachmentsDirProvider();
        if (await attDir.exists()) {
          await for (final entity in attDir.list(recursive: false, followLinks: false)) {
            if (entity is File) {
              attachmentFiles[p.basename(entity.path)] = entity;
            }
          }
        }
        final rows = await _db.select(_db.timelineAttachments).get();
        for (final row in rows) {
          final f = File(row.path);
          if (await f.exists()) {
            attachmentFiles.putIfAbsent(p.basename(f.path), () => f);
          }
        }
        final tlRows = await _db.select(_db.timelineEntries).get();
        for (final row in tlRows) {
          final path = row.attachmentPath;
          if (path != null && path.isNotEmpty) {
            final f = File(path);
            if (await f.exists()) {
              attachmentFiles.putIfAbsent(p.basename(f.path), () => f);
            }
          }
        }
      }
      counts['attachments'] = attachmentFiles.length;

      final nowMs = _clock().millisecondsSinceEpoch;
      final manifest = BackupManifest(
        formatVersion: currentFormatVersion,
        appVersion: appVersion,
        schemaVersion: _db.schemaVersion,
        createdAtMs: nowMs,
        includeAttachments: includeAttachments,
        counts: counts,
      );

      final archive = Archive();

      final manifestBytes =
          utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest.toJson()));
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

      final dbBytes = await File(snapshotDbPath).readAsBytes();
      archive.addFile(ArchiveFile('db.sqlite', dbBytes.length, dbBytes));

      final outboxJsonBytes = utf8.encode(
        jsonEncode(outboxItems.map(_encodeOutboxItem).toList(growable: false)),
      );
      archive.addFile(ArchiveFile('outbox.json', outboxJsonBytes.length, outboxJsonBytes));

      for (final entry in attachmentFiles.entries) {
        final bytes = await entry.value.readAsBytes();
        archive.addFile(ArchiveFile('attachments/${entry.key}', bytes.length, bytes));
      }

      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
      Uint8List finalBytes = zipBytes;

      if (passphrase != null && passphrase.isNotEmpty) {
        onStage?.call(BackupStage.encrypting);
        finalBytes = await _crypto.encrypt(zipBytes, passphrase);
      }

      onStage?.call(BackupStage.saving);
      final destFile = File(destinationPath);
      await destFile.parent.create(recursive: true);
      await destFile.writeAsBytes(finalBytes, flush: true);

      if (recordLastBackupTimestamp) {
        await SettingsRepository(_db).set('last_backup_at', '$nowMs');
      }
      onStage?.call(BackupStage.done);
      return manifest;
    } finally {
      if (await workDir.exists()) {
        try {
          await workDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// Creates a backup in cache, streams it to a SAF document picked by the user,
  /// and deletes the cache copy. Returns `null` if user cancels the SAF picker.
  Future<BackupManifest?> createAndSaveWithSaf({
    required bool includeAttachments,
    String? passphrase,
    void Function(BackupStage stage)? onStage,
  }) async {
    final fileName = defaultBackupFileName();
    final uri = await _safClient.createDocument(fileName, 'application/octet-stream');
    if (uri == null || uri.isEmpty) return null;

    final cacheDir = await _cacheDirProvider();
    final cacheFile = File(
      p.join(cacheDir.path, 'backup_${_clock().millisecondsSinceEpoch}.pcrm'),
    );
    try {
      final manifest = await createBackupFile(
        destinationPath: cacheFile.path,
        includeAttachments: includeAttachments,
        passphrase: passphrase,
        recordLastBackupTimestamp: false,
        onStage: onStage,
      );
      onStage?.call(BackupStage.saving);
      await _safClient.copyFileToUri(cacheFile.path, uri);
      await SettingsRepository(_db).set('last_backup_at', '${manifest.createdAtMs}');
      onStage?.call(BackupStage.done);
      return manifest;
    } finally {
      if (await cacheFile.exists()) {
        try {
          await cacheFile.delete();
        } catch (_) {}
      }
    }
  }

  /// Picks a backup file via Android SAF into app cache and returns the cache path.
  Future<String?> pickBackupFile() {
    return _safClient.pickDocument(const ['*/*']);
  }

  /// Detects backup format and reads manifest metadata (or requests a passphrase).
  Future<BackupInspection> inspectBackup(
    String filePath, {
    String? passphrase,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const CorruptBackupException('Backup file not found');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const CorruptBackupException('Backup file is empty');
    }

    if (BackupCrypto.isEncryptedBytes(bytes)) {
      if (passphrase == null || passphrase.isEmpty) {
        return const BackupInspection(
          format: BackupFormat.encryptedPcrm,
          needsPassphrase: true,
        );
      }
      final zipBytes = await _crypto.decrypt(bytes, passphrase);
      final manifest = _readManifestFromZip(zipBytes);
      return BackupInspection(
        format: BackupFormat.encryptedPcrm,
        needsPassphrase: false,
        manifest: manifest,
      );
    }

    if (BackupCrypto.isZipBytes(bytes)) {
      final manifest = _readManifestFromZip(bytes);
      return BackupInspection(
        format: BackupFormat.plainPcrm,
        needsPassphrase: false,
        manifest: manifest,
      );
    }

    if (BackupCrypto.isJsonBytes(bytes)) {
      try {
        final decoded = jsonDecode(utf8.decode(bytes));
        if (decoded is Map<String, dynamic> &&
            (decoded.containsKey('contacts') ||
                decoded.containsKey('timeline') ||
                decoded.containsKey('tasks') ||
                decoded.containsKey('scheduled_sms'))) {
          return BackupInspection(
            format: BackupFormat.v1Json,
            needsPassphrase: false,
            v1Counts: {
              'contacts': (decoded['contacts'] as List?)?.length ?? 0,
              'timeline': (decoded['timeline'] as List?)?.length ?? 0,
              'tasks': (decoded['tasks'] as List?)?.length ?? 0,
              'scheduled_sms': (decoded['scheduled_sms'] as List?)?.length ?? 0,
            },
            v1TimestampMs: (decoded['timestamp'] as num?)?.toInt(),
          );
        }
      } catch (e) {
        throw CorruptBackupException('Invalid JSON backup: $e');
      }
    }

    throw const CorruptBackupException('Unrecognized backup format');
  }

  /// Restores a `.pcrm` backup atomically:
  /// 1. Validates archive & SQLite snapshot in a staging directory first.
  /// 2. Copies current database to `pocket_crm.before-restore.bak`.
  /// 3. Closes DB, swaps database & attachments, reopens DB (running migrations if older).
  /// 4. Re-enqueues future outbox rows on native side and marks past due single messages missed.
  Future<RestoreOutcome> restorePcrmBackup({
    required String filePath,
    String? passphrase,
    required Future<void> Function() closeDb,
    required Future<AppDatabase> Function() reopenDb,
    void Function(BackupStage stage)? onStage,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const CorruptBackupException('Backup file does not exist');
    }
    final rawBytes = await file.readAsBytes();
    if (rawBytes.isEmpty) {
      throw const CorruptBackupException('Backup file is empty');
    }

    Uint8List zipBytes;
    if (BackupCrypto.isEncryptedBytes(rawBytes)) {
      if (passphrase == null || passphrase.isEmpty) {
        throw const WrongPassphraseException();
      }
      onStage?.call(BackupStage.decrypting);
      zipBytes = await _crypto.decrypt(rawBytes, passphrase);
    } else if (BackupCrypto.isZipBytes(rawBytes)) {
      zipBytes = rawBytes;
    } else {
      throw const CorruptBackupException('Not a valid .pcrm archive');
    }

    onStage?.call(BackupStage.verifying);
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    } catch (e) {
      throw CorruptBackupException('Archive is truncated or corrupted: $e');
    }

    final manifestEntry = _findEntry(archive, 'manifest.json');
    final dbEntry = _findEntry(archive, 'db.sqlite');
    if (manifestEntry == null || dbEntry == null) {
      throw const CorruptBackupException('Backup is missing manifest.json or db.sqlite');
    }

    final BackupManifest manifest;
    try {
      final map = jsonDecode(utf8.decode(manifestEntry.readBytes() ?? const []))
          as Map<String, dynamic>;
      manifest = BackupManifest.fromJson(map);
    } catch (e) {
      throw CorruptBackupException('Invalid manifest.json: $e');
    }

    final dbBytes = dbEntry.readBytes();
    if (dbBytes == null || dbBytes.length < 100 || !_hasSqliteHeader(dbBytes)) {
      throw const CorruptBackupException('Invalid SQLite database inside backup');
    }

    final outboxEntry = _findEntry(archive, 'outbox.json');
    final List<OutboxItem> outboxItems = [];
    if (outboxEntry != null) {
      try {
        final list =
            jsonDecode(utf8.decode(outboxEntry.readBytes() ?? const [])) as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            outboxItems.add(_decodeOutboxItem(item));
          }
        }
      } catch (e) {
        throw CorruptBackupException('Invalid outbox.json: $e');
      }
    }

    final cacheDir = await _cacheDirProvider();
    final stagingDir = Directory(
      p.join(cacheDir.path, 'pcrm_restore_${_clock().millisecondsSinceEpoch}'),
    );
    await stagingDir.create(recursive: true);

    try {
      final stagedDbFile = File(p.join(stagingDir.path, 'db.sqlite'));
      await stagedDbFile.writeAsBytes(dbBytes, flush: true);

      sq3.Database? probe;
      try {
        probe = sq3.sqlite3.open(stagedDbFile.path, mode: sq3.OpenMode.readOnly);
        final res = probe.select('PRAGMA quick_check');
        if (res.isEmpty || res.first.values.first.toString().toLowerCase() != 'ok') {
          throw const CorruptBackupException('SQLite quick_check failed');
        }
      } catch (e) {
        if (e is CorruptBackupException) rethrow;
        throw CorruptBackupException('Could not open backed-up database: $e');
      } finally {
        probe?.close();
      }

      final stagedAttachmentsDir = Directory(p.join(stagingDir.path, 'attachments'));
      await stagedAttachmentsDir.create(recursive: true);
      int restoredFilesCount = 0;
      for (final entry in archive.files) {
        if (!entry.isFile) continue;
        final normalized = entry.name.replaceAll('\\', '/');
        if (!normalized.startsWith('attachments/')) continue;
        final baseName = p.basename(normalized);
        if (baseName.isEmpty || baseName == '.' || baseName == '..') continue;
        final data = entry.readBytes();
        if (data == null) continue;
        await File(p.join(stagedAttachmentsDir.path, baseName)).writeAsBytes(data, flush: true);
        restoredFilesCount++;
      }

      onStage?.call(BackupStage.restoring);
      final targetDbPath = await _dbPathProvider();
      final targetDbFile = File(targetDbPath);
      final targetAttachmentsDir = await _attachmentsDirProvider();

      await closeDb();

      if (await targetDbFile.exists()) {
        final bakPath = p.join(p.dirname(targetDbPath), 'pocket_crm.before-restore.bak');
        await targetDbFile.copy(bakPath);
      }

      for (final suffix in const ['-wal', '-shm']) {
        final sidecar = File('$targetDbPath$suffix');
        if (await sidecar.exists()) {
          await sidecar.delete();
        }
      }

      await targetDbFile.parent.create(recursive: true);
      await stagedDbFile.copy(targetDbPath);

      if (manifest.includeAttachments) {
        if (await targetAttachmentsDir.exists()) {
          await targetAttachmentsDir.delete(recursive: true);
        }
        await targetAttachmentsDir.create(recursive: true);
        await for (final entity
            in stagedAttachmentsDir.list(recursive: false, followLinks: false)) {
          if (entity is File) {
            await entity.copy(p.join(targetAttachmentsDir.path, p.basename(entity.path)));
          }
        }
      }

      final reopened = await reopenDb();

      if (manifest.includeAttachments && restoredFilesCount > 0) {
        await _remapRestoredAttachmentPaths(reopened, targetAttachmentsDir);
      }

      final nowMs = _clock().millisecondsSinceEpoch;
      final futureToEnqueue = <OutboxItem>[];
      int missedCount = 0;

      final campaigns = await reopened.select(reopened.campaigns).get();
      for (final camp in campaigns) {
        if (camp.status == 'scheduled' || camp.status == 'running' || camp.status == 'paused') {
          try {
            await _outboxClient.upsertCampaign(
              CampaignConfig(
                id: camp.id,
                name: camp.name,
                paceSeconds: camp.paceSeconds ?? 4,
                windowStartMin: camp.windowStartMin ?? 9 * 60,
                windowEndMin: camp.windowEndMin ?? 21 * 60,
                status: camp.status,
              ),
            );
          } catch (_) {}
        }
      }

      for (final item in outboxItems) {
        final isPending = item.status == 'queued' || item.status == 'sending';
        if (!isPending) continue;
        if (item.dueAtMs <= nowMs) {
          missedCount++;
          await (reopened.update(reopened.outboxMessages)
                ..where((t) => t.clientId.equals(item.clientId)))
              .write(
            const OutboxMessagesCompanion(
              status: Value('missed'),
              errorLabel: Value('Missed'),
            ),
          );
        } else {
          futureToEnqueue.add(
            OutboxItem(
              clientId: item.clientId,
              campaignId: item.campaignId,
              address: item.address,
              recipientName: item.recipientName,
              body: item.body,
              dueAtMs: item.dueAtMs,
              subId: item.subId,
              status: 'queued',
              attempt: item.attempt,
            ),
          );
        }
      }

      if (futureToEnqueue.isNotEmpty) {
        try {
          await _outboxClient.enqueue(futureToEnqueue);
        } catch (_) {}
      }

      onStage?.call(BackupStage.done);
      return RestoreOutcome(
        manifest: manifest,
        reEnqueuedOutboxCount: futureToEnqueue.length,
        missedOutboxCount: missedCount,
        restoredFilesCount: restoredFilesCount,
      );
    } finally {
      if (await stagingDir.exists()) {
        try {
          await stagingDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// Imports an older v1 `pocket_crm_backup.json` in merge mode using the exact
  /// matching rules from v1. Safe and duplicate-free if imported more than once.
  Future<V1JsonImportResult> importV1Json(String rawJson) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (e) {
      throw CorruptBackupException('Invalid JSON backup: $e');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const CorruptBackupException('Backup JSON root must be an object');
    }

    final region = await SettingsRepository(_db).get('phone_region') ?? 'US';
    final nowMs = _clock().millisecondsSinceEpoch;
    final oldToNewContactId = <int, int>{};

    int contactsImported = 0;
    int timelineImported = 0;
    int tasksImported = 0;
    int scheduledImported = 0;

    // 1. Contacts (match by normalized phone number)
    final contactsList = (decoded['contacts'] as List?) ?? const [];
    for (final raw in contactsList) {
      if (raw is! Map<String, dynamic>) continue;
      final oldId = (raw['id'] as num?)?.toInt();
      final rawPhone = (raw['phone_number'] ?? '').toString().trim();
      final e164 = _phoneService.normalise(rawPhone, region);
      final normalizedPhone = e164 ?? rawPhone;

      Contact? existing;
      if (normalizedPhone.isNotEmpty) {
        existing = await (_db.select(_db.contacts)
              ..where((t) => t.phoneNumber.equals(normalizedPhone) | t.phoneNumber.equals(rawPhone))
              ..limit(1))
            .getSingleOrNull();
        if (existing == null) {
          final phoneRow = await (_db.select(_db.contactPhones)
                ..where((t) => t.e164.equals(normalizedPhone) | t.raw.equals(rawPhone))
                ..limit(1))
              .getSingleOrNull();
          if (phoneRow != null) {
            existing = await (_db.select(_db.contacts)
                  ..where((t) => t.id.equals(phoneRow.contactId))
                  ..limit(1))
                .getSingleOrNull();
          }
        }
      }

      if (existing != null) {
        if (oldId != null) oldToNewContactId[oldId] = existing.id;
        final fb = (raw['facebook_url'] ?? '').toString();
        final li = (raw['linkedin_url'] ?? '').toString();
        final gmail = (raw['gmail_address'] ?? raw['email'] ?? '').toString();
        final note = (raw['pinned_note'] ?? raw['about'] ?? '').toString();
        final starred = (raw['is_starred'] as num?)?.toInt() ?? 0;

        await (_db.update(_db.contacts)..where((t) => t.id.equals(existing!.id))).write(
          ContactsCompanion(
            facebookUrl:
                (existing.facebookUrl == null || existing.facebookUrl!.isEmpty) && fb.isNotEmpty
                    ? Value(fb)
                    : const Value.absent(),
            linkedinUrl:
                (existing.linkedinUrl == null || existing.linkedinUrl!.isEmpty) && li.isNotEmpty
                    ? Value(li)
                    : const Value.absent(),
            gmailAddress:
                (existing.gmailAddress == null || existing.gmailAddress!.isEmpty) && gmail.isNotEmpty
                    ? Value(gmail)
                    : const Value.absent(),
            email: (existing.email == null || existing.email!.isEmpty) && gmail.isNotEmpty
                ? Value(gmail)
                : const Value.absent(),
            pinnedNote:
                (existing.pinnedNote == null || existing.pinnedNote!.isEmpty) && note.isNotEmpty
                    ? Value(note)
                    : const Value.absent(),
            about: (existing.about == null || existing.about!.isEmpty) && note.isNotEmpty
                ? Value(note)
                : const Value.absent(),
            isStarred: existing.isStarred == 0 && starred == 1
                ? const Value(1)
                : const Value.absent(),
          ),
        );
      } else {
        final gmail = (raw['gmail_address'] ?? raw['email'] ?? '').toString();
        final note = (raw['pinned_note'] ?? raw['about'] ?? '').toString();
        final avatarRaw = raw['avatar_color'];
        final insertedId = await _db.into(_db.contacts).insert(
              ContactsCompanion.insert(
                phoneNumber: Value(normalizedPhone.isEmpty ? null : normalizedPhone),
                displayName: (raw['display_name'] ?? 'Imported Contact').toString(),
                avatarColor: Value(avatarRaw?.toString()),
                isStarred: Value((raw['is_starred'] as num?)?.toInt() ?? 0),
                facebookUrl: Value((raw['facebook_url'] ?? '').toString()),
                linkedinUrl: Value((raw['linkedin_url'] ?? '').toString()),
                gmailAddress: Value(gmail),
                email: Value(gmail.isEmpty ? null : gmail),
                pinnedNote: Value(note),
                about: Value(note.isEmpty ? null : note),
                lastSyncTime: Value((raw['last_sync_time'] as num?)?.toInt() ?? 0),
                source: const Value('manual'),
                createdAt: Value(nowMs),
              ),
            );
        if (normalizedPhone.isNotEmpty) {
          await _db.into(_db.contactPhones).insert(
                ContactPhonesCompanion.insert(
                  contactId: insertedId,
                  raw: Value(rawPhone.isNotEmpty ? rawPhone : normalizedPhone),
                  e164: Value(e164),
                  isPrimary: const Value(1),
                  isMobile: const Value(1),
                ),
              );
        }
        if (oldId != null) oldToNewContactId[oldId] = insertedId;
        contactsImported++;
      }
    }

    // 2. Timeline (match by native_message_id OR contact_id + type + timestamp)
    final timelineList = (decoded['timeline'] as List?) ?? const [];
    for (final raw in timelineList) {
      if (raw is! Map<String, dynamic>) continue;
      final oldCid = (raw['contact_id'] as num?)?.toInt();
      if (oldCid == null || !oldToNewContactId.containsKey(oldCid)) continue;
      final newCid = oldToNewContactId[oldCid]!;
      final nativeId = raw['native_message_id']?.toString();
      final type = (raw['type'] ?? 'note').toString();
      final ts = (raw['timestamp'] as num?)?.toInt() ?? nowMs;

      TimelineEntry? dup;
      if (nativeId != null && nativeId.isNotEmpty) {
        dup = await (_db.select(_db.timelineEntries)
              ..where((t) => t.nativeMessageId.equals(nativeId))
              ..limit(1))
            .getSingleOrNull();
      } else {
        dup = await (_db.select(_db.timelineEntries)
              ..where(
                (t) =>
                    t.contactId.equals(newCid) &
                    t.type.equals(type) &
                    t.timestamp.equals(ts),
              )
              ..limit(1))
            .getSingleOrNull();
      }

      if (dup == null) {
        final content = (raw['content'] ?? '').toString();
        await _db.into(_db.timelineEntries).insert(
              TimelineEntriesCompanion.insert(
                contactId: Value(newCid),
                type: type,
                timestamp: ts,
                content: Value(content),
                note: Value(type == 'note' ? content : null),
                amount: Value((raw['amount'] as num?)?.toDouble()),
                attachmentPath: Value(raw['attachment_path']?.toString()),
                nativeMessageId: Value(nativeId),
                isPinned: Value((raw['is_pinned'] as num?)?.toInt() ?? 0),
                source: const Value('manual'),
              ),
            );
        timelineImported++;
      }
    }

    // 3. Tasks (match by contact_id + title + due_date)
    final tasksList = (decoded['tasks'] as List?) ?? const [];
    for (final raw in tasksList) {
      if (raw is! Map<String, dynamic>) continue;
      final oldCid = (raw['contact_id'] as num?)?.toInt();
      if (oldCid == null || !oldToNewContactId.containsKey(oldCid)) continue;
      final newCid = oldToNewContactId[oldCid]!;
      final title = (raw['title'] ?? '').toString();
      final dueDate = (raw['due_date'] as num?)?.toInt() ?? nowMs;

      final dup = await (_db.select(_db.tasks)
            ..where(
              (t) =>
                  t.contactId.equals(newCid) &
                  t.title.equals(title) &
                  t.dueDate.equals(dueDate),
            )
            ..limit(1))
          .getSingleOrNull();

      if (dup == null) {
        await _db.into(_db.tasks).insert(
              TasksCompanion.insert(
                contactId: Value(newCid),
                title: title,
                dueDate: dueDate,
                isCompleted: Value((raw['is_completed'] as num?)?.toInt() ?? 0),
              ),
            );
        tasksImported++;
      }
    }

    // 4. Scheduled SMS (match by contact_id + message + scheduled_time)
    final scheduledList = (decoded['scheduled_sms'] as List?) ?? const [];
    for (final raw in scheduledList) {
      if (raw is! Map<String, dynamic>) continue;
      final oldCid = (raw['contact_id'] as num?)?.toInt();
      if (oldCid == null || !oldToNewContactId.containsKey(oldCid)) continue;
      final newCid = oldToNewContactId[oldCid]!;
      final message = (raw['message'] ?? '').toString();
      final schedTime = (raw['scheduled_time'] as num?)?.toInt() ?? nowMs;

      final dup = await (_db.select(_db.scheduledSmsEntries)
            ..where(
              (t) =>
                  t.contactId.equals(newCid) &
                  t.message.equals(message) &
                  t.scheduledTime.equals(schedTime),
            )
            ..limit(1))
          .getSingleOrNull();

      if (dup == null) {
        await _db.into(_db.scheduledSmsEntries).insert(
              ScheduledSmsEntriesCompanion.insert(
                contactId: Value(newCid),
                phoneNumber: (raw['phone_number'] ?? '').toString(),
                message: message,
                scheduledTime: schedTime,
                isSent: Value((raw['is_sent'] as num?)?.toInt() ?? 0),
              ),
            );
        scheduledImported++;
      }
    }

    await _db.rebuildAllFts();
    return V1JsonImportResult(
      contactsImported: contactsImported,
      timelineImported: timelineImported,
      tasksImported: tasksImported,
      scheduledImported: scheduledImported,
    );
  }

  /// Runs a weekly automatic plain backup (no attachments) into the app's
  /// external files directory, keeping at most the last 4 backups.
  Future<File?> runAutoBackupIfDue({bool force = false}) async {
    final settings = SettingsRepository(_db);
    if (!force && (await settings.get('auto_backup_enabled')) == '0') {
      return null;
    }

    final nowMs = _clock().millisecondsSinceEpoch;
    final lastAuto = int.tryParse((await settings.get('last_auto_backup_at')) ?? '');
    const sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
    if (!force && lastAuto != null && (nowMs - lastAuto) < sevenDaysMs) {
      return null;
    }

    final autoDir = await _autoBackupDirProvider?.call();
    if (autoDir == null) return null;
    if (!await autoDir.exists()) {
      await autoDir.create(recursive: true);
    }

    final fileName = 'PocketCRM ${DateFormat('yyyy-MM-dd_HHmmss').format(_clock())}.pcrm';
    final destFile = File(p.join(autoDir.path, fileName));
    await createBackupFile(
      destinationPath: destFile.path,
      includeAttachments: false,
      passphrase: null,
      recordLastBackupTimestamp: false,
    );
    await settings.set('last_auto_backup_at', '$nowMs');

    final existing = <File>[];
    await for (final entity in autoDir.list(recursive: false, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.pcrm')) {
        existing.add(entity);
      }
    }
    existing.sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    if (existing.length > maxAutoBackupsToKeep) {
      for (final old in existing.skip(maxAutoBackupsToKeep)) {
        try {
          await old.delete();
        } catch (_) {}
      }
    }
    return destFile;
  }

  Future<List<File>> listAutoBackups() async {
    final autoDir = await _autoBackupDirProvider?.call();
    if (autoDir == null || !autoDir.existsSync()) return const [];
    final files = autoDir
        .listSync(recursive: false, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.pcrm'))
        .toList();
    files.sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return files;
  }

  BackupManifest _readManifestFromZip(Uint8List zipBytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    } catch (e) {
      throw CorruptBackupException('Archive is truncated or corrupt: $e');
    }
    final manifestEntry = _findEntry(archive, 'manifest.json');
    final dbEntry = _findEntry(archive, 'db.sqlite');
    if (manifestEntry == null || dbEntry == null) {
      throw const CorruptBackupException('Archive missing manifest.json or db.sqlite');
    }
    final dbBytes = dbEntry.readBytes();
    if (dbBytes == null || dbBytes.length < 100 || !_hasSqliteHeader(dbBytes)) {
      throw const CorruptBackupException('Archive db.sqlite is invalid');
    }
    try {
      final map = jsonDecode(utf8.decode(manifestEntry.readBytes() ?? const []))
          as Map<String, dynamic>;
      return BackupManifest.fromJson(map);
    } catch (e) {
      throw CorruptBackupException('Archive manifest.json is invalid: $e');
    }
  }

  ArchiveFile? _findEntry(Archive archive, String name) {
    for (final f in archive.files) {
      if (f.isFile && f.name.replaceAll('\\', '/') == name) {
        return f;
      }
    }
    return null;
  }

  bool _hasSqliteHeader(Uint8List bytes) {
    const header = 'SQLite format 3\u0000';
    if (bytes.length < header.length) return false;
    for (var i = 0; i < header.length; i++) {
      if (bytes[i] != header.codeUnitAt(i)) return false;
    }
    return true;
  }

  Future<Map<String, int>> _collectTableCounts() async {
    return {
      'contacts': (await _db.select(_db.contacts).get()).length,
      'timeline': (await _db.select(_db.timelineEntries).get()).length,
      'tasks': (await _db.select(_db.tasks).get()).length,
      'contact_lists': (await _db.select(_db.contactLists).get()).length,
      'contact_list_members': (await _db.select(_db.contactListMembers).get()).length,
      'contact_phones': (await _db.select(_db.contactPhones).get()).length,
      'timeline_attachments': (await _db.select(_db.timelineAttachments).get()).length,
      'templates': (await _db.select(_db.templates).get()).length,
      'campaigns': (await _db.select(_db.campaigns).get()).length,
      'outbox_messages': (await _db.select(_db.outboxMessages).get()).length,
      'settings': (await _db.select(_db.settings).get()).length,
    };
  }

  Future<void> _remapRestoredAttachmentPaths(
    AppDatabase reopened,
    Directory targetAttachmentsDir,
  ) async {
    final attRows = await reopened.select(reopened.timelineAttachments).get();
    for (final row in attRows) {
      final remapped = p.join(targetAttachmentsDir.path, p.basename(row.path));
      if (remapped != row.path && await File(remapped).exists()) {
        await (reopened.update(reopened.timelineAttachments)..where((t) => t.id.equals(row.id)))
            .write(TimelineAttachmentsCompanion(path: Value(remapped)));
      }
    }
    final tlRows = await reopened.select(reopened.timelineEntries).get();
    for (final row in tlRows) {
      final path = row.attachmentPath;
      if (path != null && path.isNotEmpty) {
        final remapped = p.join(targetAttachmentsDir.path, p.basename(path));
        if (remapped != path && await File(remapped).exists()) {
          await (reopened.update(reopened.timelineEntries)..where((t) => t.id.equals(row.id)))
              .write(TimelineEntriesCompanion(attachmentPath: Value(remapped)));
        }
      }
    }
  }

  Map<String, dynamic> _encodeOutboxItem(OutboxItem i) => {
        'clientId': i.clientId,
        'campaignId': i.campaignId,
        'address': i.address,
        'recipientName': i.recipientName,
        'body': i.body,
        'dueAtMs': i.dueAtMs,
        'subId': i.subId,
        'status': i.status,
        'attempt': i.attempt,
        'partsTotal': i.partsTotal,
        'partsSent': i.partsSent,
        'partsFailed': i.partsFailed,
        'partsDelivered': i.partsDelivered,
        'errorCode': i.errorCode,
        'sentAtMs': i.sentAtMs,
        'deliveredAtMs': i.deliveredAtMs,
        'seq': i.seq,
      };

  OutboxItem _decodeOutboxItem(Map<String, dynamic> m) => OutboxItem(
        clientId: (m['clientId'] ?? '').toString(),
        campaignId: m['campaignId']?.toString(),
        address: (m['address'] ?? '').toString(),
        recipientName: m['recipientName']?.toString(),
        body: (m['body'] ?? '').toString(),
        dueAtMs: (m['dueAtMs'] as num?)?.toInt() ?? 0,
        subId: (m['subId'] as num?)?.toInt(),
        status: (m['status'] ?? 'queued').toString(),
        attempt: (m['attempt'] as num?)?.toInt() ?? 0,
        partsTotal: (m['partsTotal'] as num?)?.toInt() ?? 0,
        partsSent: (m['partsSent'] as num?)?.toInt() ?? 0,
        partsFailed: (m['partsFailed'] as num?)?.toInt() ?? 0,
        partsDelivered: (m['partsDelivered'] as num?)?.toInt() ?? 0,
        errorCode: (m['errorCode'] as num?)?.toInt(),
        sentAtMs: (m['sentAtMs'] as num?)?.toInt(),
        deliveredAtMs: (m['deliveredAtMs'] as num?)?.toInt(),
        seq: (m['seq'] as num?)?.toInt() ?? 0,
      );
}
