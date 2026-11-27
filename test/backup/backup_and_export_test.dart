import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/native/outbox_api.g.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/backup/data/backup_crypto.dart';
import 'package:pocket_crm/features/backup/data/backup_service.dart';
import 'package:pocket_crm/features/backup/data/export_service.dart';
import 'package:pocket_crm/features/backup/ui/backup_screen.dart';
import 'package:pocket_crm/features/messages/data/outbox_repository.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';
import 'package:sqlite3/sqlite3.dart' as sq3;

class _FakeSafClient implements BackupSafClient {
  String? nextCreateUri;
  String? nextPickedPath;
  final Map<String, Uint8List> savedUris = {};

  @override
  Future<String?> createDocument(String name, String mime) async => nextCreateUri;

  @override
  Future<void> copyFileToUri(String path, String uri) async {
    savedUris[uri] = await File(path).readAsBytes();
  }

  @override
  Future<String?> pickDocument(List<String> mimeTypes) async => nextPickedPath;
}

class _FakeOutboxClient implements OutboxPlatformClient {
  List<OutboxItem> nativeItems = [];
  final List<OutboxItem> reEnqueued = [];
  final List<CampaignConfig> upsertedCampaigns = [];
  final List<String> sharedFiles = [];

  @override
  Future<void> enqueue(List<OutboxItem> items) async {
    reEnqueued.addAll(items);
  }

  @override
  Future<void> upsertCampaign(CampaignConfig config) async {
    upsertedCampaigns.add(config);
  }

  @override
  Future<void> cancel(List<String> clientIds) async {}
  @override
  Future<void> retry(List<String> clientIds) async {}
  @override
  Future<void> pauseCampaign(String id) async {}
  @override
  Future<void> resumeCampaign(String id) async {}
  @override
  Future<void> stopCampaign(String id) async {}
  @override
  Future<ChangeSet> changesSince(int seq) async =>
      ChangeSet(items: List<OutboxItem>.from(nativeItems), latestSeq: nativeItems.length);
  @override
  Future<List<SimInfo>> sims() async => const [];
  @override
  Future<OutboxCapabilities> capabilities() async => OutboxCapabilities(
        exactAlarms: true,
        ignoringBatteryOptimisation: true,
        notifications: true,
        smsPermission: true,
      );
  @override
  Future<void> shareFile(String path, String mimeType, String subject) async {
    sharedFiles.add(path);
  }

  @override
  Future<SetupPlatformInfo> setupInfo() async =>
      SetupPlatformInfo(sdkInt: 34, manufacturer: 'Google', installedFromStore: false);
  @override
  Future<void> openExactAlarmSettings() async {}
  @override
  Future<void> requestIgnoreBatteryOptimisations() async {}
  @override
  Future<void> openAppDetailsSettings() async {}
  @override
  void listenForChanges(void Function(int latestSeq) onChanged) {}
}

void main() {
  group('BackupService & BackupCrypto', () {
    test(
        'encrypted round-trip backs up every table and 3 attachment files, wipes, restores row-for-row and byte-for-byte',
        () async {
      final tempRoot = await Directory.systemTemp.createTemp('pcrm_spec12_rt_');
      addTearDown(() async {
        if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
      });

      final dbFile = File(p.join(tempRoot.path, 'databases', 'pocket_crm.db'));
      await dbFile.parent.create(recursive: true);
      final attDir = Directory(p.join(tempRoot.path, 'attachments'));
      await attDir.create(recursive: true);
      final cacheDir = Directory(p.join(tempRoot.path, 'cache'));
      await cacheDir.create(recursive: true);

      // Create 3 distinct attachment files
      final f1Bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4, 5, 6]);
      final f2Bytes = Uint8List.fromList(utf8.encode('Invoice #442\nTotal: 240.00\n'));
      final f3Bytes = Uint8List.fromList(List<int>.generate(2048, (i) => (i * 37) % 256));
      final f1 = File(p.join(attDir.path, 'photo_1.jpg'))..writeAsBytesSync(f1Bytes);
      final f2 = File(p.join(attDir.path, 'invoice_2.txt'))..writeAsBytesSync(f2Bytes);
      final f3 = File(p.join(attDir.path, 'scan_3.bin'))..writeAsBytesSync(f3Bytes);

      var db = AppDatabase.openFile(dbFile);
      final fixedNow = DateTime(2026, 11, 27, 12, 0);
      final nowMs = fixedNow.millisecondsSinceEpoch;

      // Populate every table
      final cid = await db.into(db.contacts).insert(
            ContactsCompanion.insert(
              phoneNumber: const Value('+2348031234567'),
              displayName: 'Amara Okafor',
              company: const Value('Kano Textiles'),
              role: const Value('Buyer'),
              city: const Value('Lagos'),
              email: const Value('amara@kanotextiles.example'),
              isStarred: const Value(1),
              about: const Value('Prefers morning calls'),
              lastInteractionAt: Value(nowMs - 3600000),
            ),
          );
      await db.into(db.contactPhones).insert(
            ContactPhonesCompanion.insert(
              contactId: cid,
              raw: const Value('+234 803 123 4567'),
              e164: const Value('+2348031234567'),
              isPrimary: const Value(1),
              isMobile: const Value(1),
            ),
          );
      final listId = await db.into(db.contactLists).insert(
            ContactListsCompanion.insert(name: 'Clients', createdAt: Value(nowMs)),
          );
      await db.into(db.contactListMembers).insert(
            ContactListMembersCompanion.insert(listId: Value(listId), contactId: Value(cid)),
          );
      final tlId = await db.into(db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(cid),
              type: 'visit',
              timestamp: nowMs - 3600000,
              note: const Value('Visited showroom'),
              placeName: const Value('Kano Textiles, Lagos'),
              attachmentPath: Value(f2.path),
            ),
          );
      await db.into(db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(cid),
              type: 'payment',
              timestamp: nowMs - 1800000,
              amount: const Value(240.0),
              currency: const Value('USD'),
              paymentStatus: const Value('owed_to_me'),
              note: const Value('Sample order'),
            ),
          );
      await db.into(db.timelineAttachments).insert(
            TimelineAttachmentsCompanion.insert(
              timelineId: tlId,
              path: f1.path,
              mime: const Value('image/jpeg'),
              createdAt: Value(nowMs),
            ),
          );
      await db.into(db.timelineAttachments).insert(
            TimelineAttachmentsCompanion.insert(
              timelineId: tlId,
              path: f3.path,
              mime: const Value('application/octet-stream'),
              createdAt: Value(nowMs),
            ),
          );
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              contactId: Value(cid),
              title: 'Send revised quote',
              dueDate: nowMs + 86400000,
            ),
          );
      await db.into(db.templates).insert(
            TemplatesCompanion.insert(
              name: 'Follow-up',
              body: 'Hi {first_name}, checking in.',
              createdAt: Value(nowMs),
              updatedAt: Value(nowMs),
            ),
          );
      await db.into(db.campaigns).insert(
            CampaignsCompanion.insert(
              id: 'camp-1',
              name: 'November check-in',
              bodyTemplate: 'Hi {first_name}',
              status: 'scheduled',
              paceSeconds: const Value(15),
              createdAt: Value(nowMs),
            ),
          );
      await db.into(db.outboxMessages).insert(
            OutboxMessagesCompanion.insert(
              clientId: 'msg-future',
              contactId: Value(cid),
              address: '+2348031234567',
              body: 'Future reminder',
              dueAt: nowMs + 3600000,
              status: 'queued',
            ),
          );
      await db.into(db.outboxMessages).insert(
            OutboxMessagesCompanion.insert(
              clientId: 'msg-past',
              contactId: Value(cid),
              address: '+2348031234567',
              body: 'Overdue reminder',
              dueAt: nowMs - 600000,
              status: 'queued',
            ),
          );
      await db.into(db.settings).insertOnConflictUpdate(
            SettingsCompanion.insert(key: 'my_name', value: const Value('Tariq')),
          );

      final outbox = _FakeOutboxClient()
        ..nativeItems = [
          OutboxItem(
            clientId: 'msg-future',
            address: '+2348031234567',
            recipientName: 'Amara Okafor',
            body: 'Future reminder',
            dueAtMs: nowMs + 3600000,
            status: 'queued',
          ),
          OutboxItem(
            clientId: 'msg-past',
            address: '+2348031234567',
            recipientName: 'Amara Okafor',
            body: 'Overdue reminder',
            dueAtMs: nowMs - 600000,
            status: 'queued',
          ),
        ];

      final saf = _FakeSafClient();
      // Use Argon2id (real KDF, fast memory for unit test speed while exercising full PCRM1 format)
      final crypto = BackupCrypto(
        kdfMethod: BackupCrypto.kdfArgon2id,
        argon2MemoryKiB: 4096,
        argon2Iterations: 2,
      );

      final service = BackupService(
        db: db,
        outboxClient: outbox,
        safClient: saf,
        cacheDirProvider: () async => cacheDir,
        attachmentsDirProvider: () async => attDir,
        dbPathProvider: () async => dbFile.path,
        crypto: crypto,
        clock: () => fixedNow,
      );

      // Snapshot original rows before backup
      final origContacts = await db.select(db.contacts).get();
      final origPhones = await db.select(db.contactPhones).get();
      final origLists = await db.select(db.contactLists).get();
      final origMembers = await db.select(db.contactListMembers).get();
      final origTimeline = await db.select(db.timelineEntries).get();
      final origAttRows = await db.select(db.timelineAttachments).get();
      final origTasks = await db.select(db.tasks).get();
      final origTemplates = await db.select(db.templates).get();
      final origCampaigns = await db.select(db.campaigns).get();

      final backupPath = p.join(tempRoot.path, 'PocketCRM 2026-11-27.pcrm');
      final manifest = await service.createBackupFile(
        destinationPath: backupPath,
        includeAttachments: true,
        passphrase: 'correct horse battery staple',
      );
      expect(manifest.counts['contacts'], 1);
      expect(manifest.counts['timeline'], 2);
      expect(manifest.counts['attachments'], 3);

      // Verify encrypted magic header PCRM1
      final encryptedBytes = await File(backupPath).readAsBytes();
      expect(BackupCrypto.isEncryptedBytes(encryptedBytes), isTrue);
      expect(BackupCrypto.isZipBytes(encryptedBytes), isFalse);

      // Inspect without passphrase -> asks for passphrase
      final needPass = await service.inspectBackup(backupPath);
      expect(needPass.format, BackupFormat.encryptedPcrm);
      expect(needPass.needsPassphrase, isTrue);

      // Wipe database & attachments completely
      await db.close();
      await dbFile.delete();
      for (final sfx in const ['-wal', '-shm']) {
        final f = File('${dbFile.path}$sfx');
        if (await f.exists()) await f.delete();
      }
      await attDir.delete(recursive: true);
      await attDir.create(recursive: true);

      // Reopen empty DB (simulating fresh phone)
      db = AppDatabase.openFile(dbFile);
      expect(await db.select(db.contacts).get(), isEmpty);

      final restoreService = BackupService(
        db: db,
        outboxClient: outbox,
        safClient: saf,
        cacheDirProvider: () async => cacheDir,
        attachmentsDirProvider: () async => attDir,
        dbPathProvider: () async => dbFile.path,
        crypto: crypto,
        clock: () => fixedNow,
      );

      final outcome = await restoreService.restorePcrmBackup(
        filePath: backupPath,
        passphrase: 'correct horse battery staple',
        closeDb: () async => db.close(),
        reopenDb: () async {
          db = AppDatabase.openFile(dbFile);
          return db;
        },
      );

      // Verify pre-restore safety backup created
      final safetyBak = File(p.join(dbFile.parent.path, 'pocket_crm.before-restore.bak'));
      expect(await safetyBak.exists(), isTrue);

      // Compare every table row for row
      expect(await db.select(db.contacts).get(), origContacts);
      expect(await db.select(db.contactPhones).get(), origPhones);
      expect(await db.select(db.contactLists).get(), origLists);
      expect(await db.select(db.contactListMembers).get(), origMembers);
      expect(await db.select(db.timelineEntries).get(), origTimeline);
      expect(await db.select(db.timelineAttachments).get(), origAttRows);
      expect(await db.select(db.tasks).get(), origTasks);
      expect(await db.select(db.templates).get(), origTemplates);
      expect(await db.select(db.campaigns).get(), origCampaigns);

      // Compare all 3 attachment files byte for byte
      expect(await File(p.join(attDir.path, 'photo_1.jpg')).readAsBytes(), f1Bytes);
      expect(await File(p.join(attDir.path, 'invoice_2.txt')).readAsBytes(), f2Bytes);
      expect(await File(p.join(attDir.path, 'scan_3.bin')).readAsBytes(), f3Bytes);

      // Verify future outbox re-enqueued and past-due marked missed
      expect(outcome.reEnqueuedOutboxCount, 1);
      expect(outcome.missedOutboxCount, 1);
      expect(outbox.reEnqueued.map((e) => e.clientId).toList(), ['msg-future']);
      final pastRow = await (db.select(db.outboxMessages)
            ..where((t) => t.clientId.equals('msg-past')))
          .getSingle();
      expect(pastRow.status, 'missed');

      await db.close();
    });

    test('older schema backup restores cleanly and migrates forward to current schema', () async {
      final tempRoot = await Directory.systemTemp.createTemp('pcrm_spec12_schema_');
      addTearDown(() async {
        if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
      });

      final dbFile = File(p.join(tempRoot.path, 'pocket_crm.db'));
      final attDir = Directory(p.join(tempRoot.path, 'attachments'))..createSync();
      final cacheDir = Directory(p.join(tempRoot.path, 'cache'))..createSync();

      // Build a literal v4 SQLite fixture inside a .pcrm zip (simulating older schema)
      final v4File = File(p.join(tempRoot.path, 'fixture_v4.sqlite'));
      final rawDb = sq3.sqlite3.open(v4File.path);
      rawDb.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          phone_number TEXT NOT NULL,
          display_name TEXT NOT NULL,
          avatar_color INTEGER DEFAULT 4281673165,
          is_starred INTEGER DEFAULT 0,
          facebook_url TEXT DEFAULT '',
          linkedin_url TEXT DEFAULT '',
          gmail_address TEXT DEFAULT '',
          pinned_note TEXT DEFAULT '',
          last_sync_time INTEGER DEFAULT 0
        );
        CREATE TABLE timeline (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          content TEXT DEFAULT '',
          amount REAL,
          attachment_path TEXT,
          native_message_id TEXT,
          is_pinned INTEGER DEFAULT 0
        );
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          due_date INTEGER NOT NULL,
          is_completed INTEGER DEFAULT 0,
          reminder_time INTEGER
        );
        CREATE TABLE scheduled_sms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          phone_number TEXT NOT NULL,
          message TEXT NOT NULL,
          scheduled_time INTEGER NOT NULL,
          is_sent INTEGER DEFAULT 0
        );
        CREATE TABLE contact_lists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          created_at INTEGER NOT NULL
        );
        CREATE TABLE contact_list_members (
          list_id INTEGER NOT NULL,
          contact_id INTEGER NOT NULL,
          PRIMARY KEY (list_id, contact_id)
        );
        CREATE TABLE bulk_sms_jobs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          list_id INTEGER NOT NULL,
          list_name TEXT NOT NULL,
          message TEXT NOT NULL,
          scheduled_time INTEGER NOT NULL,
          total_recipients INTEGER NOT NULL,
          sent_count INTEGER DEFAULT 0,
          is_completed INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL
        );
        PRAGMA user_version = 4;
      ''');
      rawDb.execute(
        "INSERT INTO contacts (id, phone_number, display_name, pinned_note) VALUES (1, '+14155550199', 'David Mensah', 'Old schema contact')",
      );
      rawDb.execute(
        "INSERT INTO timeline (contact_id, type, timestamp, content) VALUES (1, 'note', 1764200000000, 'Migrated note')",
      );
      rawDb.close();

      final archive = Archive();
      final manifestBytes = utf8.encode(jsonEncode({
        'formatVersion': 1,
        'appVersion': '1.0.0',
        'schemaVersion': 4,
        'createdAtMs': 1764200000000,
        'includeAttachments': false,
        'counts': {'contacts': 1, 'timeline': 1, 'attachments': 0},
      }));
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
      final v4Bytes = await v4File.readAsBytes();
      archive.addFile(ArchiveFile('db.sqlite', v4Bytes.length, v4Bytes));
      final outboxBytes = utf8.encode('[]');
      archive.addFile(ArchiveFile('outbox.json', outboxBytes.length, outboxBytes));

      final pcrmFile = File(p.join(tempRoot.path, 'v4_backup.pcrm'))
        ..writeAsBytesSync(ZipEncoder().encode(archive));

      var db = AppDatabase.openFile(dbFile);
      final service = BackupService(
        db: db,
        outboxClient: _FakeOutboxClient(),
        safClient: _FakeSafClient(),
        cacheDirProvider: () async => cacheDir,
        attachmentsDirProvider: () async => attDir,
        dbPathProvider: () async => dbFile.path,
      );

      await service.restorePcrmBackup(
        filePath: pcrmFile.path,
        closeDb: () async => db.close(),
        reopenDb: () async {
          db = AppDatabase.openFile(dbFile);
          return db;
        },
      );

      final contacts = await db.select(db.contacts).get();
      expect(contacts.length, 1);
      expect(contacts.first.displayName, 'David Mensah');
      expect(contacts.first.about, 'Old schema contact'); // backfilled by v4->v5 migration!
      final timeline = await db.select(db.timelineEntries).get();
      expect(timeline.length, 1);
      expect(timeline.first.content, 'Migrated note');
      await db.close();
    });

    test('wrong passphrase and truncated file both fail clearly and leave current data untouched',
        () async {
      final tempRoot = await Directory.systemTemp.createTemp('pcrm_spec12_err_');
      addTearDown(() async {
        if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
      });

      final dbFile = File(p.join(tempRoot.path, 'pocket_crm.db'));
      final attDir = Directory(p.join(tempRoot.path, 'attachments'))..createSync();
      final cacheDir = Directory(p.join(tempRoot.path, 'cache'))..createSync();

      final db = AppDatabase.openFile(dbFile);
      await db.into(db.contacts).insert(
            ContactsCompanion.insert(
              phoneNumber: const Value('+14155550111'),
              displayName: 'Existing Safe Contact',
            ),
          );

      final crypto = BackupCrypto(
        kdfMethod: BackupCrypto.kdfArgon2id,
        argon2MemoryKiB: 4096,
        argon2Iterations: 2,
      );
      final service = BackupService(
        db: db,
        outboxClient: _FakeOutboxClient(),
        safClient: _FakeSafClient(),
        cacheDirProvider: () async => cacheDir,
        attachmentsDirProvider: () async => attDir,
        dbPathProvider: () async => dbFile.path,
        crypto: crypto,
      );

      final encFile = p.join(tempRoot.path, 'enc.pcrm');
      await service.createBackupFile(
        destinationPath: encFile,
        includeAttachments: false,
        passphrase: 'real-secret',
      );

      // 1. Wrong passphrase
      await expectLater(
        () => service.restorePcrmBackup(
          filePath: encFile,
          passphrase: 'wrong-secret',
          closeDb: () async => fail('must not close db on wrong passphrase'),
          reopenDb: () async => fail('must not reopen db'),
        ),
        throwsA(isA<WrongPassphraseException>()),
      );

      // 2. Truncated encrypted file
      final encBytes = await File(encFile).readAsBytes();
      final truncEnc = File(p.join(tempRoot.path, 'trunc_enc.pcrm'))
        ..writeAsBytesSync(encBytes.sublist(0, 30));
      await expectLater(
        () => service.restorePcrmBackup(
          filePath: truncEnc.path,
          passphrase: 'real-secret',
          closeDb: () async => fail('must not close db on truncated file'),
          reopenDb: () async => fail('must not reopen db'),
        ),
        throwsA(isA<CorruptBackupException>()),
      );

      // 3. Truncated plain zip file
      final plainFile = p.join(tempRoot.path, 'plain.pcrm');
      await service.createBackupFile(destinationPath: plainFile, includeAttachments: false);
      final plainBytes = await File(plainFile).readAsBytes();
      final truncPlain = File(p.join(tempRoot.path, 'trunc_plain.pcrm'))
        ..writeAsBytesSync(plainBytes.sublist(0, plainBytes.length ~/ 2));
      await expectLater(
        () => service.restorePcrmBackup(
          filePath: truncPlain.path,
          closeDb: () async => fail('must not close db on truncated plain zip'),
          reopenDb: () async => fail('must not reopen db'),
        ),
        throwsA(isA<CorruptBackupException>()),
      );

      // Existing data is completely untouched
      final contacts = await db.select(db.contacts).get();
      expect(contacts.length, 1);
      expect(contacts.first.displayName, 'Existing Safe Contact');
      await db.close();
    });

    test('legacy v1 JSON fixture imports without duplicates when imported twice', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final tempRoot = await Directory.systemTemp.createTemp('pcrm_spec12_legacy_');
      addTearDown(() async {
        if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
      });

      final service = BackupService(
        db: db,
        outboxClient: _FakeOutboxClient(),
        safClient: _FakeSafClient(),
        cacheDirProvider: () async => tempRoot,
        attachmentsDirProvider: () async => tempRoot,
        dbPathProvider: () async => p.join(tempRoot.path, 'unused.db'),
      );

      final legacyJson = jsonEncode({
        'version': 1,
        'timestamp': 1760000000000,
        'contacts': [
          {
            'id': 10,
            'phone_number': '+14155550123',
            'display_name': 'Priya Nair',
            'is_starred': 1,
            'gmail_address': 'priya@example.com',
            'pinned_note': 'VIP distributor',
          },
        ],
        'timeline': [
          {
            'contact_id': 10,
            'type': 'sms_incoming',
            'timestamp': 1760000010000,
            'content': 'Payment sent',
            'native_message_id': 'sms_991',
          },
          {
            'contact_id': 10,
            'type': 'note',
            'timestamp': 1760000020000,
            'content': 'Met at expo',
          },
        ],
        'tasks': [
          {
            'contact_id': 10,
            'title': 'Send catalogue',
            'due_date': 1760086400000,
            'is_completed': 0,
          },
        ],
        'scheduled_sms': [
          {
            'contact_id': 10,
            'phone_number': '+14155550123',
            'message': 'Happy Diwali!',
            'scheduled_time': 1760172800000,
            'is_sent': 0,
          },
        ],
      });

      final first = await service.importV1Json(legacyJson);
      expect(first.contactsImported, 1);
      expect(first.timelineImported, 2);
      expect(first.tasksImported, 1);
      expect(first.scheduledImported, 1);

      // Import second time -> zero duplicates
      final second = await service.importV1Json(legacyJson);
      expect(second.contactsImported, 0);
      expect(second.timelineImported, 0);
      expect(second.tasksImported, 0);
      expect(second.scheduledImported, 0);

      expect((await db.select(db.contacts).get()).length, 1);
      expect((await db.select(db.timelineEntries).get()).length, 2);
      expect((await db.select(db.tasks).get()).length, 1);
      expect((await db.select(db.scheduledSmsEntries).get()).length, 1);
    });

    test('weekly automatic backups keep last 4 plain backups without attachments', () async {
      final tempRoot = await Directory.systemTemp.createTemp('pcrm_spec12_auto_');
      addTearDown(() async {
        if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
      });
      final dbFile = File(p.join(tempRoot.path, 'pocket_crm.db'));
      final autoDir = Directory(p.join(tempRoot.path, 'auto_backups'));
      final cacheDir = Directory(p.join(tempRoot.path, 'cache'))..createSync();
      final db = AppDatabase.openFile(dbFile);
      addTearDown(db.close);

      var now = DateTime(2026, 10, 1, 9, 0);
      final service = BackupService(
        db: db,
        outboxClient: _FakeOutboxClient(),
        safClient: _FakeSafClient(),
        cacheDirProvider: () async => cacheDir,
        attachmentsDirProvider: () async => cacheDir,
        dbPathProvider: () async => dbFile.path,
        autoBackupDirProvider: () async => autoDir,
        clock: () => now,
      );

      for (var week = 0; week < 6; week++) {
        final created = await service.runAutoBackupIfDue();
        expect(created, isNotNull);
        // Calling again the next day should skip (< 7 days)
        now = now.add(const Duration(days: 1));
        expect(await service.runAutoBackupIfDue(), isNull);
        // Advance 7 days for next week
        now = now.add(const Duration(days: 7));
      }

      final kept = await service.listAutoBackups();
      expect(kept.length, 4);
      // Verify they are plain zips without attachments
      final inspection = await service.inspectBackup(kept.first.path);
      expect(inspection.format, BackupFormat.plainPcrm);
      expect(inspection.manifest?.includeAttachments, isFalse);
    });

    test('ExportService generates valid People CSV, People vCard 3.0, and Person History CSV',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final tempRoot = await Directory.systemTemp.createTemp('pcrm_spec12_exp_');
      addTearDown(() async {
        if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
      });

      final cid = await db.into(db.contacts).insert(
            ContactsCompanion.insert(
              phoneNumber: const Value('+2348031234567'),
              displayName: 'Amara Okafor',
              company: const Value('Kano, Textiles'),
              role: const Value('Buyer'),
              city: const Value('Lagos'),
              email: const Value('amara@example.com'),
            ),
          );
      final listId = await db.into(db.contactLists).insert(
            ContactListsCompanion.insert(name: 'Clients', createdAt: const Value(1764200000000)),
          );
      await db.into(db.contactListMembers).insert(
            ContactListMembersCompanion.insert(listId: Value(listId), contactId: Value(cid)),
          );
      await db.into(db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(cid),
              type: 'payment',
              timestamp: 1764200000000,
              amount: const Value(240.0),
              currency: const Value('USD'),
              paymentStatus: const Value('owed_to_me'),
              note: const Value('Invoice "44", net 7'),
            ),
          );

      final exporter = ExportService(
        db: db,
        safClient: _FakeSafClient(),
        outboxClient: _FakeOutboxClient(),
        cacheDirProvider: () async => tempRoot,
      );

      final peopleCsv = await exporter.buildPeopleCsv();
      expect(peopleCsv, contains('name,numbers,company,role,city,email,lists,last_contact,balance'));
      expect(peopleCsv, contains('Amara Okafor,+2348031234567,"Kano, Textiles",Buyer,Lagos,amara@example.com,Clients,,240.00'));

      final vcard = await exporter.buildPeopleVcard();
      expect(vcard, contains('BEGIN:VCARD'));
      expect(vcard, contains('VERSION:3.0'));
      expect(vcard, contains('FN:Amara Okafor'));
      expect(vcard, contains('TEL;TYPE=CELL:+2348031234567'));
      expect(vcard, contains(r'ORG:Kano\, Textiles'));
      expect(vcard, contains('END:VCARD'));

      final historyCsv = await exporter.buildPersonHistoryCsv(cid);
      expect(historyCsv, contains('date,type,duration_seconds,outcome,place,content,note,amount,currency,payment_status'));
      expect(historyCsv, contains('"Invoice ""44"", net 7",240.00,USD,owed_to_me'));
    });

    test('lib/ contains zero uses of Permission.storage or /storage/emulated', () {
      final libDir = Directory('lib');
      final offenders = <String>[];
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = entity.readAsStringSync();
          if (content.contains('Permission.storage') || content.contains('/storage/emulated')) {
            offenders.add(entity.path);
          }
        }
      }
      expect(offenders, isEmpty);
    });
  });

  group('BackupSettingsScreen UI', () {
    testWidgets('shows switches, passphrase warning when enabled, and auto-backup explanation',
        (tester) async {
      final db = AppDatabase.inMemory();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            outboxPlatformClientProvider.overrideWithValue(_FakeOutboxClient()),
            backupSafClientProvider.overrideWithValue(_FakeSafClient()),
            backupServiceProvider.overrideWith(
              (ref) => BackupService(
                db: db,
                outboxClient: _FakeOutboxClient(),
                safClient: _FakeSafClient(),
                cacheDirProvider: () async => Directory.systemTemp,
                attachmentsDirProvider: () async => Directory.systemTemp,
                dbPathProvider: () async => 'unused.db',
                autoBackupDirProvider: () async => null,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BackupSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Include photos and files'), findsOneWidget);
      expect(find.text('Protect with a passphrase'), findsOneWidget);
      expect(find.text('Back up now'), findsOneWidget);
      expect(find.text('Restore from a backup'), findsOneWidget);
      expect(
        find.text('Kept on this phone and removed if the app is uninstalled. Save a backup elsewhere now and then.'),
        findsOneWidget,
      );

      // Toggle passphrase switch -> shows warning and 2 fields
      await tester.tap(find.text('Protect with a passphrase'));
      await tester.pumpAndSettle();
      expect(
        find.text('If you forget this passphrase the backup cannot be opened.'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
  });
}
