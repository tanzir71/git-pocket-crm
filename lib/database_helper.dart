import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static set testDatabase(Database? db) => _database = db;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pocket_crm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Contacts Table
    await db.execute('''
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

    // Timeline Table
    await db.execute('''
      CREATE TABLE timeline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        type TEXT NOT NULL, -- 'call_incoming', 'call_outgoing', 'call_missed', 'sms_incoming', 'sms_outgoing', 'note', 'payment', 'screenshot', 'attachment', 'promise', 'sms_scheduled'
        timestamp INTEGER NOT NULL,
        content TEXT,
        amount REAL,
        attachment_path TEXT,
        native_message_id TEXT, -- to prevent duplicate SMS logs
        is_pinned INTEGER DEFAULT 0,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Scheduled SMS Table
    await db.execute('''
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

    // Tasks Table
    await db.execute('''
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

    // Contact Lists Table
    await db.execute('''
      CREATE TABLE contact_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    // Contact List Members Table
    await db.execute('''
      CREATE TABLE contact_list_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER,
        contact_id INTEGER,
        FOREIGN KEY (list_id) REFERENCES contact_lists(id) ON DELETE CASCADE,
        FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
        UNIQUE(list_id, contact_id)
      )
    ''');

    // Bulk SMS Jobs Table
    await db.execute('''
      CREATE TABLE bulk_sms_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_name TEXT NOT NULL,
        message TEXT NOT NULL,
        scheduled_time INTEGER NOT NULL,
        is_sent INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE contact_lists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE contact_list_members (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          list_id INTEGER,
          contact_id INTEGER,
          FOREIGN KEY (list_id) REFERENCES contact_lists(id) ON DELETE CASCADE,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
          UNIQUE(list_id, contact_id)
        )
      ''');
      await db.execute('''
        CREATE TABLE bulk_sms_jobs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          list_name TEXT NOT NULL,
          message TEXT NOT NULL,
          scheduled_time INTEGER NOT NULL,
          is_sent INTEGER DEFAULT 0
        )
      ''');
      await db.execute('ALTER TABLE scheduled_sms ADD COLUMN bulk_job_id INTEGER');
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN reminder_time INTEGER');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE timeline ADD COLUMN is_pinned INTEGER DEFAULT 0');
      } catch (_) {}
    }
  }

  // --- Contact Lists Helper Methods ---

  Future<int> createContactList(String name) async {
    final db = await database;
    return await db.insert('contact_lists', {'name': name});
  }

  Future<int> deleteContactList(int listId) async {
    final db = await database;
    return await db.delete('contact_lists', where: 'id = ?', whereArgs: [listId]);
  }

  Future<int> addContactToList(int listId, int contactId) async {
    final db = await database;
    try {
      return await db.insert('contact_list_members', {
        'list_id': listId,
        'contact_id': contactId,
      });
    } catch (_) {
      return -1; // Ignore duplicates due to UNIQUE constraint
    }
  }

  Future<int> removeContactFromList(int listId, int contactId) async {
    final db = await database;
    return await db.delete(
      'contact_list_members',
      where: 'list_id = ? AND contact_id = ?',
      whereArgs: [listId, contactId],
    );
  }

  Future<List<Map<String, dynamic>>> getContactLists() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT cl.*, COUNT(clm.contact_id) as member_count
      FROM contact_lists cl
      LEFT JOIN contact_list_members clm ON cl.id = clm.list_id
      GROUP BY cl.id
      ORDER BY cl.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getContactsInList(int listId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.* 
      FROM contacts c
      JOIN contact_list_members clm ON c.id = clm.contact_id
      WHERE clm.list_id = ?
      ORDER BY c.display_name ASC
    ''', [listId]);
  }

  Future<List<Map<String, dynamic>>> getContactsNotInList(int listId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.* 
      FROM contacts c
      WHERE c.id NOT IN (
        SELECT contact_id FROM contact_list_members WHERE list_id = ?
      )
      ORDER BY c.display_name ASC
    ''', [listId]);
  }

  Future<int> createBulkSmsJob(String listName, String message, int scheduledTime, List<int> contactIds) async {
    final db = await database;
    int jobId = 0;
    await db.transaction((txn) async {
      jobId = await txn.insert('bulk_sms_jobs', {
        'list_name': listName,
        'message': message,
        'scheduled_time': scheduledTime,
        'is_sent': 0,
      });

      for (var cId in contactIds) {
        final contactRows = await txn.query('contacts', where: 'id = ?', whereArgs: [cId]);
        if (contactRows.isEmpty) continue;
        final phone = contactRows.first['phone_number'] as String;

        // 1. Insert individual scheduled SMS linked to the job
        await txn.insert('scheduled_sms', {
          'contact_id': cId,
          'phone_number': phone,
          'message': message,
          'scheduled_time': scheduledTime,
          'is_sent': 0,
          'bulk_job_id': jobId,
        });

        // 2. Add an explicit 'sms_scheduled' timeline event for this contact
        await txn.insert('timeline', {
          'contact_id': cId,
          'type': 'sms_scheduled',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'content': 'SMS Scheduled (Bulk to $listName): "$message" at ${DateFormat('yMMMd').add_jm().format(DateTime.fromMillisecondsSinceEpoch(scheduledTime))}',
        });
      }
    });
    return jobId;
  }

  Future<void> clearAllTables() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tasks');
      await txn.delete('scheduled_sms');
      await txn.delete('timeline');
      await txn.delete('contacts');
      await txn.delete('contact_list_members');
      await txn.delete('contact_lists');
      await txn.delete('bulk_sms_jobs');
    });
  }

  // Utility to copy picked/attached file locally to app database folder
  // so it persists even if the source file is deleted or modified.
  Future<String> replicateAttachment(String? sourcePath) async {
    if (sourcePath == null || sourcePath.isEmpty) return '';
    
    // Ignore mock paths or already replicated paths
    if (sourcePath.startsWith('/mock_storage/') || sourcePath.contains('/app_flutter/attachments/')) {
      return sourcePath;
    }
    
    try {
      final file = File(sourcePath);
      if (!await file.exists()) {
        return sourcePath;
      }
      
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(join(appDir.path, 'attachments'));
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }
      
      final fileName = basename(sourcePath);
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final destinationPath = join(attachmentsDir.path, uniqueName);
      
      await file.copy(destinationPath);
      return destinationPath;
    } catch (e) {
      print('Error replicating attachment: $e');
      return sourcePath;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
