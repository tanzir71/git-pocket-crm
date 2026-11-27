import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'db_safety_copy.dart';
import 'migration_helpers.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Contacts,
    TimelineEntries,
    ScheduledSmsEntries,
    Tasks,
    ContactLists,
    ContactListMembers,
    BulkSmsJobs,
    ContactPhones,
    TimelineAttachments,
    Templates,
    Campaigns,
    OutboxMessages,
    Settings,
    SyncStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.openDefault() => AppDatabase(_openDefaultConnection());

  factory AppDatabase.openFile(File file) {
    return AppDatabase(
      LazyDatabase(() async {
        await ensureV4SafetyCopy(file.path);
        return NativeDatabase.createInBackground(file);
      }),
    );
  }

  factory AppDatabase.inMemory() => AppDatabase(NativeDatabase.memory());

  bool _fts5Available = false;
  bool get fts5Available => _fts5Available;

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
          await _initFts5();
        },
        onUpgrade: (m, from, to) async {
          await transaction(() async {
            if (from < 2) {
              await _upgradeV1ToV2();
            }
            if (from < 3) {
              await _addColumnIfMissing('tasks', 'reminder_time', 'INTEGER');
            }
            if (from < 4) {
              await _addColumnIfMissing('timeline', 'is_pinned', 'INTEGER DEFAULT 0');
            }
            if (from < 5) {
              await _upgradeV4ToV5();
            }
          });
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await _probeFts5();
        },
      );

  Future<void> _upgradeV1ToV2() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS contact_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS contact_list_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER,
        contact_id INTEGER,
        FOREIGN KEY (list_id) REFERENCES contact_lists(id) ON DELETE CASCADE,
        FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
        UNIQUE(list_id, contact_id)
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS bulk_sms_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_name TEXT NOT NULL,
        message TEXT NOT NULL,
        scheduled_time INTEGER NOT NULL,
        is_sent INTEGER DEFAULT 0
      )
    ''');
    await _addColumnIfMissing('scheduled_sms', 'bulk_job_id', 'INTEGER');
  }

  Future<void> _upgradeV4ToV5() async {
    // 1. Add new columns to existing tables
    await _addColumnIfMissing('contacts', 'company', 'TEXT');
    await _addColumnIfMissing('contacts', 'role', 'TEXT');
    await _addColumnIfMissing('contacts', 'city', 'TEXT');
    await _addColumnIfMissing('contacts', 'email', 'TEXT');
    await _addColumnIfMissing('contacts', 'birthday', 'TEXT');
    await _addColumnIfMissing('contacts', 'about', 'TEXT');
    await _addColumnIfMissing('contacts', 'cadence_days', 'INTEGER');
    await _addColumnIfMissing('contacts', 'cadence_snoozed_until', 'INTEGER');
    await _addColumnIfMissing('contacts', 'last_interaction_at', 'INTEGER');
    await _addColumnIfMissing('contacts', 'do_not_message', 'INTEGER DEFAULT 0');
    await _addColumnIfMissing('contacts', 'device_contact_id', 'TEXT');
    await _addColumnIfMissing('contacts', 'source', "TEXT DEFAULT 'device'");
    await _addColumnIfMissing('contacts', 'created_at', 'INTEGER');

    await _addColumnIfMissing('timeline', 'note', 'TEXT');
    await _addColumnIfMissing('timeline', 'outcome', 'TEXT');
    await _addColumnIfMissing('timeline', 'duration_seconds', 'INTEGER');
    await _addColumnIfMissing('timeline', 'place_name', 'TEXT');
    await _addColumnIfMissing('timeline', 'lat', 'REAL');
    await _addColumnIfMissing('timeline', 'lng', 'REAL');
    await _addColumnIfMissing('timeline', 'currency', 'TEXT');
    await _addColumnIfMissing('timeline', 'payment_status', 'TEXT');
    await _addColumnIfMissing('timeline', 'suggested_amount', 'REAL');
    await _addColumnIfMissing('timeline', 'suggestion_state', 'TEXT');
    await _addColumnIfMissing('timeline', 'reviewed_at', 'INTEGER');
    await _addColumnIfMissing('timeline', 'hidden', 'INTEGER DEFAULT 0');
    await _addColumnIfMissing('timeline', 'source', 'TEXT');
    await _addColumnIfMissing('timeline', 'outbox_client_id', 'TEXT');
    await _addColumnIfMissing('timeline', 'edited_at', 'INTEGER');

    await _addColumnIfMissing('tasks', 'note', 'TEXT');
    await _addColumnIfMissing('tasks', 'created_at', 'INTEGER');
    await _addColumnIfMissing('tasks', 'completed_at', 'INTEGER');
    await _addColumnIfMissing('tasks', 'source_timeline_id', 'INTEGER');

    await _addColumnIfMissing('contact_lists', 'cadence_days', 'INTEGER');
    await _addColumnIfMissing('contact_lists', 'created_at', 'INTEGER');

    // 2. Create new v5 tables
    await customStatement('''
      CREATE TABLE IF NOT EXISTS contact_phones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
        e164 TEXT UNIQUE,
        raw TEXT,
        label TEXT,
        is_primary INTEGER DEFAULT 0,
        is_mobile INTEGER DEFAULT 1
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS timeline_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timeline_id INTEGER NOT NULL REFERENCES timeline(id) ON DELETE CASCADE,
        path TEXT NOT NULL,
        mime TEXT,
        created_at INTEGER
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        body TEXT NOT NULL,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS campaigns (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        body_template TEXT NOT NULL,
        scheduled_at INTEGER,
        status TEXT NOT NULL,
        sub_id INTEGER,
        pace_seconds INTEGER,
        window_start_min INTEGER,
        window_end_min INTEGER,
        created_at INTEGER
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS outbox_messages (
        client_id TEXT NOT NULL PRIMARY KEY,
        contact_id INTEGER REFERENCES contacts(id) ON DELETE SET NULL,
        campaign_id TEXT,
        address TEXT NOT NULL,
        body TEXT NOT NULL,
        due_at INTEGER NOT NULL,
        sub_id INTEGER,
        status TEXT NOT NULL,
        error_code INTEGER,
        error_label TEXT,
        parts INTEGER,
        attempt INTEGER DEFAULT 0,
        sent_at INTEGER,
        delivered_at INTEGER,
        provider_sms_id TEXT,
        merge_summary TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_state (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT
      )
    ''');

    // 3. Delete orphan rows before indexing/backfilling
    final orphanTimeline = await customUpdate(
      'DELETE FROM timeline WHERE contact_id IS NOT NULL AND contact_id NOT IN (SELECT id FROM contacts)',
    );
    final orphanTasks = await customUpdate(
      'DELETE FROM tasks WHERE contact_id IS NOT NULL AND contact_id NOT IN (SELECT id FROM contacts)',
    );
    final orphanScheduled = await customUpdate(
      'DELETE FROM scheduled_sms WHERE contact_id IS NOT NULL AND contact_id NOT IN (SELECT id FROM contacts)',
    );
    final orphanMembers = await customUpdate(
      'DELETE FROM contact_list_members WHERE contact_id NOT IN (SELECT id FROM contacts) OR list_id NOT IN (SELECT id FROM contact_lists)',
    );
    debugPrint(
      'v5 migration removed orphans: timeline=$orphanTimeline, tasks=$orphanTasks, '
      'scheduled_sms=$orphanScheduled, contact_list_members=$orphanMembers',
    );

    // 4. Deduplicate timeline.native_message_id before creating unique index
    await customStatement('''
      UPDATE timeline
      SET native_message_id = NULL, hidden = 1
      WHERE native_message_id IS NOT NULL
        AND id NOT IN (
          SELECT MIN(id) FROM timeline
          WHERE native_message_id IS NOT NULL
          GROUP BY native_message_id
        )
    ''');

    // 5. Create indexes
    await _createIndexes();

    // 6. Backfill contact_phones & contacts metadata
    await customStatement('''
      INSERT OR IGNORE INTO contact_phones (contact_id, e164, raw, label, is_primary, is_mobile)
      SELECT id, phone_number, phone_number, 'mobile', 1, 1
      FROM contacts
      WHERE phone_number IS NOT NULL AND TRIM(phone_number) != ''
    ''');

    await customStatement('''
      UPDATE contacts
      SET
        email = CASE WHEN gmail_address IS NOT NULL AND TRIM(gmail_address) != '' THEN gmail_address ELSE email END,
        about = CASE WHEN pinned_note IS NOT NULL AND TRIM(pinned_note) != '' THEN pinned_note ELSE about END,
        created_at = CASE WHEN last_sync_time IS NOT NULL AND last_sync_time > 0 THEN last_sync_time ELSE created_at END,
        do_not_message = COALESCE(do_not_message, 0),
        source = COALESCE(source, 'device')
    ''');

    // 7. Backfill timeline.hidden and timeline.source
    await customStatement('''
      UPDATE timeline
      SET hidden = 1
      WHERE type IN ('sms_scheduled', 'promise')
    ''');

    await customStatement('''
      UPDATE timeline
      SET hidden = COALESCE(hidden, 0),
          source = CASE
            WHEN type IN ('call_incoming', 'call_outgoing', 'call_missed', 'sms_incoming', 'sms_outgoing')
            THEN 'device'
            ELSE 'manual'
          END
    ''');

    // 8. Backfill payment_status & note (without mutating content)
    final paymentRows = await customSelect(
      "SELECT id, content FROM timeline WHERE type = 'payment'",
    ).get();
    for (final row in paymentRows) {
      final id = row.read<int>('id');
      final content = row.readNullable<String>('content');
      final parsed = parseLegacyPaymentContent(content);
      if (parsed != null) {
        await customStatement(
          'UPDATE timeline SET payment_status = ?, note = ? WHERE id = ?',
          [parsed.status, parsed.note, id],
        );
      }
    }

    // 9. Backfill duration_seconds for calls
    final callRows = await customSelect(
      "SELECT id, content FROM timeline WHERE type IN ('call_incoming', 'call_outgoing', 'call_missed')",
    ).get();
    for (final row in callRows) {
      final id = row.read<int>('id');
      final content = row.readNullable<String>('content');
      final duration = parseLegacyDurationSeconds(content);
      if (duration != null) {
        await customStatement(
          'UPDATE timeline SET duration_seconds = ? WHERE id = ?',
          [duration, id],
        );
      }
    }

    // 10. Backfill contacts.last_interaction_at
    await customStatement('''
      UPDATE contacts
      SET last_interaction_at = (
        SELECT MAX(t.timestamp)
        FROM timeline t
        WHERE t.contact_id = contacts.id
          AND (
            (t.type IN ('call_incoming', 'call_outgoing') AND COALESCE(t.duration_seconds, 0) > 0)
            OR t.type IN ('sms_incoming', 'sms_outgoing')
          )
      )
    ''');

    // 11. Initialize & populate FTS5 search index
    await _initFts5();
    await rebuildAllFts();
  }

  Future<void> _addColumnIfMissing(String table, String column, String definition) async {
    final cols = await customSelect('PRAGMA table_info($table)').get();
    final exists = cols.any((row) => row.read<String>('name') == column);
    if (!exists) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_timeline_contact_ts ON timeline(contact_id, timestamp DESC)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_timeline_native_msg_id ON timeline(native_message_id) WHERE native_message_id IS NOT NULL',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_timeline_type_ts ON timeline(type, timestamp)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_completed_due ON tasks(is_completed, due_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_contact ON tasks(contact_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_phones_contact ON contact_phones(contact_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_status_due ON outbox_messages(status, due_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_campaign ON outbox_messages(campaign_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contacts_last_interaction ON contacts(last_interaction_at)',
    );
  }

  Future<void> _initFts5() async {
    try {
      await customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS contacts_fts USING fts5(
          contact_id UNINDEXED,
          display_name,
          company,
          phones,
          about,
          notes
        )
      ''');
      _fts5Available = true;
    } catch (e) {
      debugPrint('FTS5 unavailable, will fall back to LIKE search: $e');
      _fts5Available = false;
    }
  }

  Future<void> _probeFts5() async {
    try {
      await customSelect('SELECT COUNT(*) AS c FROM contacts_fts').getSingle();
      _fts5Available = true;
    } catch (_) {
      await _initFts5();
    }
  }

  /// Rebuilds the FTS5 index row for a single contact.
  Future<void> rebuildFtsForContact(int contactId) async {
    if (!_fts5Available) return;
    await customStatement('DELETE FROM contacts_fts WHERE contact_id = ?', [contactId]);

    final contactRows = await customSelect(
      'SELECT id, display_name, company, phone_number, about FROM contacts WHERE id = ?',
      variables: [Variable<int>(contactId)],
    ).get();
    if (contactRows.isEmpty) return;

    final c = contactRows.first;
    final phoneRows = await customSelect(
      'SELECT e164, raw FROM contact_phones WHERE contact_id = ?',
      variables: [Variable<int>(contactId)],
    ).get();
    final phones = <String>{
      if ((c.readNullable<String>('phone_number') ?? '').isNotEmpty)
        c.read<String>('phone_number'),
      for (final p in phoneRows) ...[
        if ((p.readNullable<String>('e164') ?? '').isNotEmpty) p.read<String>('e164'),
        if ((p.readNullable<String>('raw') ?? '').isNotEmpty) p.read<String>('raw'),
      ],
    }.join(' ');

    final noteRows = await customSelect(
      "SELECT content, note FROM timeline WHERE contact_id = ? AND COALESCE(hidden, 0) = 0 AND (note IS NOT NULL OR type IN ('note', 'visit'))",
      variables: [Variable<int>(contactId)],
    ).get();
    final notes = noteRows
        .map((r) => [r.readNullable<String>('note'), r.readNullable<String>('content')]
            .whereType<String>()
            .join(' '))
        .where((s) => s.trim().isNotEmpty)
        .join(' ');

    await customStatement(
      'INSERT INTO contacts_fts (contact_id, display_name, company, phones, about, notes) VALUES (?, ?, ?, ?, ?, ?)',
      [
        contactId,
        c.read<String>('display_name'),
        c.readNullable<String>('company') ?? '',
        phones,
        c.readNullable<String>('about') ?? '',
        notes,
      ],
    );
  }

  /// Rebuilds the entire FTS5 index from scratch.
  Future<void> rebuildAllFts() async {
    if (!_fts5Available) return;
    await customStatement('DELETE FROM contacts_fts');
    final ids = await customSelect('SELECT id FROM contacts').get();
    for (final row in ids) {
      await rebuildFtsForContact(row.read<int>('id'));
    }
  }

  /// Creates a consistent standalone SQLite snapshot at [destinationPath] using
  /// `VACUUM INTO`, deleting any pre-existing file at that path first.
  Future<void> vacuumInto(String destinationPath) async {
    final destFile = File(destinationPath);
    if (await destFile.exists()) {
      await destFile.delete();
    }
    final escaped = destinationPath.replaceAll("'", "''");
    await customStatement("VACUUM INTO '$escaped'");
  }
}

/// Computes the exact SQLite database path matching Android's historical
/// `sqflite` `getDatabasesPath()` location (`<appDataDir>/databases/pocket_crm.db`)
/// using `path_provider`'s [documentsDirPath] (`<appDataDir>/app_flutter`).
String resolvePocketCrmDatabasePath({
  required String documentsDirPath,
  required bool isAndroid,
}) {
  if (isAndroid) {
    final appDataDir = p.dirname(documentsDirPath);
    return p.join(appDataDir, 'databases', 'pocket_crm.db');
  }
  return p.join(documentsDirPath, 'pocket_crm.db');
}

LazyDatabase _openDefaultConnection() {
  return LazyDatabase(() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final filePath = resolvePocketCrmDatabasePath(
      documentsDirPath: docsDir.path,
      isAndroid: Platform.isAndroid,
    );
    final parentDir = Directory(p.dirname(filePath));
    if (!parentDir.existsSync()) {
      await parentDir.create(recursive: true);
    }
    await ensureV4SafetyCopy(filePath);
    return NativeDatabase.createInBackground(File(filePath));
  });
}
