import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// Literal v4 CREATE TABLE statements copied from legacy `lib/database_helper.dart`.
void _createLiteralV4Schema(sql.Database raw) {
  raw.execute('''
    CREATE TABLE contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone_number TEXT UNIQUE,
      display_name TEXT NOT NULL,
      avatar_color TEXT,
      is_starred INTEGER DEFAULT 0,
      facebook_url TEXT,
      linkedin_url TEXT,
      gmail_address TEXT,
      pinned_note TEXT,
      last_sync_time INTEGER DEFAULT 0
    )
  ''');
  raw.execute('''
    CREATE TABLE timeline (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_id INTEGER,
      type TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      content TEXT,
      amount REAL,
      attachment_path TEXT,
      native_message_id TEXT,
      is_pinned INTEGER DEFAULT 0,
      FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
    )
  ''');
  raw.execute('''
    CREATE TABLE scheduled_sms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_id INTEGER,
      phone_number TEXT NOT NULL,
      message TEXT NOT NULL,
      scheduled_time INTEGER NOT NULL,
      is_sent INTEGER DEFAULT 0,
      bulk_job_id INTEGER,
      FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
    )
  ''');
  raw.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_id INTEGER,
      title TEXT NOT NULL,
      due_date INTEGER NOT NULL,
      is_completed INTEGER DEFAULT 0,
      reminder_time INTEGER,
      FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
    )
  ''');
  raw.execute('''
    CREATE TABLE contact_lists (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE NOT NULL
    )
  ''');
  raw.execute('''
    CREATE TABLE contact_list_members (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      list_id INTEGER,
      contact_id INTEGER,
      FOREIGN KEY (list_id) REFERENCES contact_lists(id) ON DELETE CASCADE,
      FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
      UNIQUE(list_id, contact_id)
    )
  ''');
  raw.execute('''
    CREATE TABLE bulk_sms_jobs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      list_name TEXT NOT NULL,
      message TEXT NOT NULL,
      scheduled_time INTEGER NOT NULL,
      is_sent INTEGER DEFAULT 0
    )
  ''');
  raw.execute('PRAGMA user_version = 4');
}

/// Literal v1 schema (no lists, no bulk_sms_jobs, no bulk_job_id, no reminder_time, no is_pinned).
void _createLiteralV1Schema(sql.Database raw) {
  raw.execute('''
    CREATE TABLE contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone_number TEXT UNIQUE,
      display_name TEXT NOT NULL,
      avatar_color TEXT,
      is_starred INTEGER DEFAULT 0,
      facebook_url TEXT,
      linkedin_url TEXT,
      gmail_address TEXT,
      pinned_note TEXT,
      last_sync_time INTEGER DEFAULT 0
    )
  ''');
  raw.execute('''
    CREATE TABLE timeline (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_id INTEGER,
      type TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      content TEXT,
      amount REAL,
      attachment_path TEXT,
      native_message_id TEXT,
      FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
    )
  ''');
  raw.execute('''
    CREATE TABLE scheduled_sms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_id INTEGER,
      phone_number TEXT NOT NULL,
      message TEXT NOT NULL,
      scheduled_time INTEGER NOT NULL,
      is_sent INTEGER DEFAULT 0,
      FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
    )
  ''');
  raw.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_id INTEGER,
      title TEXT NOT NULL,
      due_date INTEGER NOT NULL,
      is_completed INTEGER DEFAULT 0,
      FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
    )
  ''');
  raw.execute('PRAGMA user_version = 1');
}

void main() {
  test('migrates literal v4 database to v5 preserving all data and running backfills', () async {
    final tmpDir = await Directory.systemTemp.createTemp('pcrm_v4_mig_');
    addTearDown(() async {
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
    });

    final dbFile = File(p.join(tmpDir.path, 'pocket_crm.db'));
    final raw = sql.sqlite3.open(dbFile.path);
    _createLiteralV4Schema(raw);

    // Insert 3 contacts
    raw.execute('''
      INSERT INTO contacts (id, phone_number, display_name, avatar_color, is_starred, gmail_address, pinned_note, last_sync_time)
      VALUES
        (1, '+14155550101', 'Amara Okafor', '#3525CD', 1, 'amara@example.com', 'Bulk buyer', 1700000001000),
        (2, '+14155550102', 'Daniel Reyes', '#4F46E5', 0, '', 'Prefers morning calls', 1700000002000),
        (3, '+14155550103', 'Priya Nair', '#6366F1', 0, 'priya@example.com', '', 0)
    ''');

    // Insert 2 lists + members
    raw.execute("INSERT INTO contact_lists (id, name) VALUES (1, 'Customers'), (2, 'Showroom')");
    raw.execute('INSERT INTO contact_list_members (list_id, contact_id) VALUES (1, 1), (1, 2), (2, 3)');

    // Calls & SMS (timestamps chosen to verify last_interaction_at)
    raw.execute('''
      INSERT INTO timeline (id, contact_id, type, timestamp, content, native_message_id)
      VALUES
        (1, 1, 'call_outgoing', 1700001000000, 'Duration: 2 min 5 sec', NULL),
        (2, 1, 'call_missed', 1700002000000, 'Duration: Missed call', NULL),
        (3, 2, 'call_incoming', 1700003000000, 'Duration: 40 sec', NULL),
        (4, 1, 'sms_incoming', 1700004000000, 'Hello Amara here', 'sms_unique_1'),
        (5, 2, 'sms_outgoing', 1700005000000, 'Sending revised quote', 'dup_sms_1'),
        (6, 2, 'sms_outgoing', 1700005000001, 'Duplicate copy', 'dup_sms_1')
    ''');

    // Payments with all 7 prefixes + auto-parsed SMS payment
    raw.execute('''
      INSERT INTO timeline (id, contact_id, type, timestamp, content, amount)
      VALUES
        (10, 1, 'payment', 1700006000000, '[Paid] Courier fee', 40.0),
        (11, 1, 'payment', 1700006001000, '[Received] Deposit', 180.0),
        (12, 1, 'payment', 1700006002000, '[To Collect] October order', 240.0),
        (13, 1, 'payment', 1700006003000, '[Owed to Me] Samples', 60.0),
        (14, 2, 'payment', 1700006004000, '[To Pay] Shipping', 25.0),
        (15, 2, 'payment', 1700006005000, '[I owe] Packaging', 35.0),
        (16, 2, 'payment', 1700006006000, '[I Owe] Return credit', 15.0),
        (17, 3, 'payment', 1700006007000, 'Parsed from SMS: Received Tk 500', 500.0)
    ''');

    // Pseudo-events
    raw.execute('''
      INSERT INTO timeline (id, contact_id, type, timestamp, content)
      VALUES
        (20, 1, 'sms_scheduled', 1700007000000, 'SMS Scheduled'),
        (21, 1, 'promise', 1700007001000, 'Reminder triggered')
    ''');

    // Orphan timeline row (contact_id 9999 does not exist)
    raw.execute('''
      INSERT INTO timeline (id, contact_id, type, timestamp, content)
      VALUES (99, 9999, 'note', 1700008000000, 'Orphan note')
    ''');

    // Task, scheduled SMS, bulk job
    raw.execute('''
      INSERT INTO tasks (id, contact_id, title, due_date, is_completed, reminder_time)
      VALUES (1, 1, 'Send revised quote', 1700010000000, 0, 1700009000000)
    ''');
    raw.execute('''
      INSERT INTO bulk_sms_jobs (id, list_name, message, scheduled_time, is_sent)
      VALUES (1, 'Customers', 'Reminder', 1700020000000, 0)
    ''');
    raw.execute('''
      INSERT INTO scheduled_sms (id, contact_id, phone_number, message, scheduled_time, is_sent, bulk_job_id)
      VALUES (1, 1, '+14155550101', 'Reminder', 1700020000000, 0, 1)
    ''');

    raw.close();

    // Open with Drift AppDatabase (performs safety copy + migration to v5)
    final db = AppDatabase.openFile(dbFile);
    addTearDown(() async => db.close());

    // Force DB open
    final contacts = await db.select(db.contacts).get();
    expect(contacts.length, 3);

    // Safety copy created
    expect(await File(p.join(tmpDir.path, 'pocket_crm.v4.bak')).exists(), isTrue);

    // Foreign keys ON
    final fkRow = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fkRow.data.values.first, 1);

    // Non-orphan counts intact
    expect((await db.select(db.contactLists).get()).length, 2);
    expect((await db.select(db.contactListMembers).get()).length, 3);
    expect((await db.select(db.tasks).get()).length, 1);
    expect((await db.select(db.scheduledSmsEntries).get()).length, 1);
    expect((await db.select(db.bulkSmsJobs).get()).length, 1);

    // Orphan timeline row removed (16 valid rows remain out of 17 inserted)
    final allTimeline = await db.select(db.timelineEntries).get();
    expect(allTimeline.length, 16);
    expect(allTimeline.where((e) => e.id == 99), isEmpty);

    // Contact backfill
    final amara = contacts.firstWhere((c) => c.id == 1);
    expect(amara.email, 'amara@example.com');
    expect(amara.about, 'Bulk buyer');
    expect(amara.createdAt, 1700000001000);
    expect(amara.lastInteractionAt, 1700004000000); // sms_incoming (missed call ignored)

    final daniel = contacts.firstWhere((c) => c.id == 2);
    expect(daniel.email, isNull);
    expect(daniel.about, 'Prefers morning calls');
    expect(daniel.lastInteractionAt, 1700005000001);

    final priya = contacts.firstWhere((c) => c.id == 3);
    expect(priya.email, 'priya@example.com');
    expect(priya.createdAt, isNull); // last_sync_time was 0

    // contact_phones backfilled
    final phones = await db.select(db.contactPhones).get();
    expect(phones.length, 3);
    expect(phones.every((ph) => ph.isPrimary == 1), isTrue);

    // Call duration_seconds backfilled
    final call1 = allTimeline.firstWhere((e) => e.id == 1);
    final call2 = allTimeline.firstWhere((e) => e.id == 2);
    final call3 = allTimeline.firstWhere((e) => e.id == 3);
    expect(call1.durationSeconds, 125);
    expect(call1.source, 'device');
    expect(call2.durationSeconds, 0);
    expect(call3.durationSeconds, 40);

    // Duplicate native_message_id deduplicated (id 5 kept, id 6 nulled & hidden)
    final dupKeep = allTimeline.firstWhere((e) => e.id == 5);
    final dupDrop = allTimeline.firstWhere((e) => e.id == 6);
    expect(dupKeep.nativeMessageId, 'dup_sms_1');
    expect(dupKeep.hidden, 0);
    expect(dupDrop.nativeMessageId, isNull);
    expect(dupDrop.hidden, 1);

    // All 7 payment prefixes + unconfirmed, original content preserved untouched
    final byId = {for (final e in allTimeline) e.id: e};
    expect(byId[10]!.paymentStatus, 'paid');
    expect(byId[10]!.note, 'Courier fee');
    expect(byId[10]!.content, '[Paid] Courier fee');
    expect(byId[11]!.paymentStatus, 'received');
    expect(byId[11]!.note, 'Deposit');
    expect(byId[12]!.paymentStatus, 'owed_to_me');
    expect(byId[12]!.note, 'October order');
    expect(byId[13]!.paymentStatus, 'owed_to_me');
    expect(byId[13]!.note, 'Samples');
    expect(byId[14]!.paymentStatus, 'i_owe');
    expect(byId[14]!.note, 'Shipping');
    expect(byId[15]!.paymentStatus, 'i_owe');
    expect(byId[15]!.note, 'Packaging');
    expect(byId[16]!.paymentStatus, 'i_owe');
    expect(byId[16]!.note, 'Return credit');
    expect(byId[17]!.paymentStatus, 'unconfirmed');
    expect(byId[17]!.content, 'Parsed from SMS: Received Tk 500');
    expect(byId[10]!.source, 'manual');

    // Pseudo-events hidden
    expect(byId[20]!.hidden, 1);
    expect(byId[21]!.hidden, 1);

    // Verify all 9 required indexes exist
    final indexRows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final indexNames = indexRows.map((r) => r.read<String>('name')).toSet();
    for (final expected in const [
      'idx_timeline_contact_ts',
      'idx_timeline_native_msg_id',
      'idx_timeline_type_ts',
      'idx_tasks_completed_due',
      'idx_tasks_contact',
      'idx_contact_phones_contact',
      'idx_outbox_status_due',
      'idx_outbox_campaign',
      'idx_contacts_last_interaction',
    ]) {
      expect(indexNames, contains(expected));
    }

    // Verify search works over backfilled data
    final peopleRepo = PeopleRepository(db);
    final matches = await peopleRepo.search('Bulk buyer');
    expect(matches.map((c) => c.displayName), contains('Amara Okafor'));
  });

  test('migrates literal v1 database all the way to v5 cleanly', () async {
    final tmpDir = await Directory.systemTemp.createTemp('pcrm_v1_mig_');
    addTearDown(() async {
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
    });

    final dbFile = File(p.join(tmpDir.path, 'pocket_crm.db'));
    final raw = sql.sqlite3.open(dbFile.path);
    _createLiteralV1Schema(raw);

    raw.execute('''
      INSERT INTO contacts (id, phone_number, display_name, gmail_address, pinned_note, last_sync_time)
      VALUES (1, '+14155550199', 'Kenji Watanabe', 'kenji@example.com', 'Architect', 1700000005000)
    ''');
    raw.execute('''
      INSERT INTO timeline (id, contact_id, type, timestamp, content)
      VALUES (1, 1, 'call_incoming', 1700001000000, 'Duration: 1 min 30 sec')
    ''');
    raw.execute('''
      INSERT INTO tasks (id, contact_id, title, due_date, is_completed)
      VALUES (1, 1, 'Send catalog', 1700010000000, 0)
    ''');
    raw.execute('''
      INSERT INTO scheduled_sms (id, contact_id, phone_number, message, scheduled_time, is_sent)
      VALUES (1, 1, '+14155550199', 'Hi Kenji', 1700020000000, 0)
    ''');
    raw.close();

    final db = AppDatabase.openFile(dbFile);
    addTearDown(() async => db.close());

    final contacts = await db.select(db.contacts).get();
    expect(contacts.length, 1);
    expect(contacts.first.displayName, 'Kenji Watanabe');
    expect(contacts.first.email, 'kenji@example.com');
    expect(contacts.first.about, 'Architect');
    expect(contacts.first.lastInteractionAt, 1700001000000);

    final timeline = await db.select(db.timelineEntries).get();
    expect(timeline.length, 1);
    expect(timeline.first.durationSeconds, 90);
    expect(timeline.first.isPinned, 0);

    final tasks = await db.select(db.tasks).get();
    expect(tasks.length, 1);
    expect(tasks.first.reminderTime, isNull);

    // New tables created from v1->v2 and v4->v5
    expect(await db.select(db.contactLists).get(), isEmpty);
    expect((await db.select(db.contactPhones).get()).length, 1);
  });
}
