import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'core/db/app_database.dart';
import 'core/db/legacy_db.dart';
import 'core/files/file_store.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static AppDatabase? _appDatabase;
  static LegacyDb? _legacyDb;

  DatabaseHelper._init();

  /// Replaces the backing Drift database (primarily for tests).
  static set testAppDatabase(AppDatabase? db) {
    _appDatabase = db;
    _legacyDb = db == null ? null : LegacyDb(db);
  }

  /// Replaces the legacy adapter directly (for existing tests).
  static set testDatabase(LegacyDb? db) {
    _legacyDb = db;
    _appDatabase = db?.appDatabase;
  }

  /// Returns the single Drift [AppDatabase] instance.
  AppDatabase get appDatabase {
    return _appDatabase ??= AppDatabase.openDefault();
  }

  /// Returns the legacy SQLite-like adapter backed by the single Drift connection.
  Future<LegacyDb> get database async {
    if (_legacyDb != null) return _legacyDb!;
    _legacyDb = LegacyDb(appDatabase);
    return _legacyDb!;
  }

  // --- Contact Lists Helper Methods ---

  Future<int> createContactList(String name) async {
    final db = await database;
    return db.insert('contact_lists', {'name': name});
  }

  Future<int> deleteContactList(int listId) async {
    final db = await database;
    return db.delete('contact_lists', where: 'id = ?', whereArgs: [listId]);
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
    return db.delete(
      'contact_list_members',
      where: 'list_id = ? AND contact_id = ?',
      whereArgs: [listId, contactId],
    );
  }

  Future<List<Map<String, dynamic>>> getContactLists() async {
    final db = await database;
    return db.rawQuery('''
      SELECT cl.*, COUNT(clm.contact_id) as member_count
      FROM contact_lists cl
      LEFT JOIN contact_list_members clm ON cl.id = clm.list_id
      GROUP BY cl.id
      ORDER BY cl.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getContactsInList(int listId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.*
      FROM contacts c
      JOIN contact_list_members clm ON c.id = clm.contact_id
      WHERE clm.list_id = ?
      ORDER BY c.display_name ASC
    ''', [listId]);
  }

  Future<List<Map<String, dynamic>>> getContactsNotInList(int listId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.*
      FROM contacts c
      WHERE c.id NOT IN (
        SELECT contact_id FROM contact_list_members WHERE list_id = ?
      )
      ORDER BY c.display_name ASC
    ''', [listId]);
  }

  Future<int> createBulkSmsJob(
    String listName,
    String message,
    int scheduledTime,
    List<int> contactIds,
  ) async {
    final db = await database;
    int jobId = 0;
    await db.transaction((txn) async {
      jobId = await txn.insert('bulk_sms_jobs', {
        'list_name': listName,
        'message': message,
        'scheduled_time': scheduledTime,
        'is_sent': 0,
      });

      for (final cId in contactIds) {
        final contactRows = await txn.query('contacts', where: 'id = ?', whereArgs: [cId]);
        if (contactRows.isEmpty) continue;
        final phone = contactRows.first['phone_number'] as String;

        await txn.insert('scheduled_sms', {
          'contact_id': cId,
          'phone_number': phone,
          'message': message,
          'scheduled_time': scheduledTime,
          'is_sent': 0,
          'bulk_job_id': jobId,
        });

        await txn.insert('timeline', {
          'contact_id': cId,
          'type': 'sms_scheduled',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'content':
              'SMS Scheduled (Bulk to $listName): "$message" at ${DateFormat('yMMMd').add_jm().format(DateTime.fromMillisecondsSinceEpoch(scheduledTime))}',
          'hidden': 1,
          'source': 'app',
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

  /// Copies a picked/attached file into app storage so it persists even if
  /// the source file is deleted or moved.
  Future<String> replicateAttachment(String? sourcePath) async {
    if (sourcePath == null || sourcePath.isEmpty) return '';

    if (sourcePath.startsWith('/mock_storage/') ||
        sourcePath.contains('/app_flutter/attachments/')) {
      return sourcePath;
    }

    try {
      return await FileStore().copyIntoStorage(sourcePath);
    } catch (e) {
      debugPrint('Error replicating attachment: $e');
      return sourcePath;
    }
  }

  Future<void> close() async {
    final db = _appDatabase;
    _appDatabase = null;
    _legacyDb = null;
    if (db != null) {
      await db.close();
    }
  }
}
