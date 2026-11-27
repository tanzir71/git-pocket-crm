import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pocket_crm/database_helper.dart';
import 'package:pocket_crm/sms_processor.dart';

class _InMemoryScheduledSmsDb implements Database {
  final List<Map<String, Object?>> scheduledSmsRows = [];
  final List<Map<String, Object?>> timelineRows = [];
  final List<Map<String, Object?>> bulkJobRows = [];
  int _nextId = 1;

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table != 'scheduled_sms') return [];
    final args = whereArgs ?? const <Object?>[];
    final now = args.isNotEmpty ? args[0] as int : 0;
    final earliest = args.length > 1 ? args[1] as int : 0;
    final excludedIds = args.length > 2
        ? args.sublist(2).cast<int>().toSet()
        : <int>{};

    final matches = scheduledSmsRows.where((row) {
      final isSent = row['is_sent'] as int;
      final sched = row['scheduled_time'] as int;
      final id = row['id'] as int;
      return isSent == 0 &&
          sched <= now &&
          sched >= earliest &&
          !excludedIds.contains(id);
    }).toList()
      ..sort((a, b) {
        final cmp = (a['scheduled_time'] as int).compareTo(b['scheduled_time'] as int);
        if (cmp != 0) return cmp;
        return (a['id'] as int).compareTo(b['id'] as int);
      });

    if (limit != null && matches.length > limit) {
      return matches.sublist(0, limit);
    }
    return matches;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (table == 'scheduled_sms' && where == 'id = ?') {
      final id = whereArgs!.first as int;
      for (final row in scheduledSmsRows) {
        if (row['id'] == id) {
          row.addAll(values);
          return 1;
        }
      }
    }
    if (table == 'bulk_sms_jobs' && where == 'id = ?') {
      final id = whereArgs!.first as int;
      for (final row in bulkJobRows) {
        if (row['id'] == id) {
          row.addAll(values);
          return 1;
        }
      }
    }
    return 0;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final copy = Map<String, Object?>.from(values);
    copy['id'] = _nextId++;
    if (table == 'timeline') {
      timelineRows.add(copy);
    } else if (table == 'scheduled_sms') {
      scheduledSmsRows.add(copy);
    }
    return copy['id'] as int;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('COUNT(*)') && sql.contains('scheduled_sms')) {
      final jobId = arguments!.first as int;
      final count = scheduledSmsRows
          .where((r) => r['bulk_job_id'] == jobId && r['is_sent'] == 0)
          .length;
      return [
        {'COUNT(*)': count},
      ];
    }
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.pocketcrm.pocket_crm/sms');

  setUp(() {
    SmsProcessor.resetSessionState();
    SmsProcessor.throttleDelay = Duration.zero;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    DatabaseHelper.testDatabase = null;
    SmsProcessor.resetSessionState();
    SmsProcessor.throttleDelay = const Duration(seconds: 2);
  });

  test('failed send leaves row unsent and does not create sms_outgoing timeline row', () async {
    final fakeDb = _InMemoryScheduledSmsDb();
    final now = DateTime.now().millisecondsSinceEpoch;
    fakeDb.scheduledSmsRows.add({
      'id': 42,
      'contact_id': 7,
      'phone_number': '+14155550100',
      'message': 'Follow up reminder',
      'scheduled_time': now - 1000,
      'is_sent': 0,
      'bulk_job_id': null,
    });
    DatabaseHelper.testDatabase = fakeDb;

    int callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      callCount++;
      return false;
    });

    await SmsProcessor.processDueSms(null, null);

    expect(callCount, 1);
    expect(fakeDb.scheduledSmsRows.first['is_sent'], 0);
    expect(fakeDb.timelineRows, isEmpty);

    // Calling again in the same session does not retry the failed id
    await SmsProcessor.processDueSms(null, null);
    expect(callCount, 1);
  });

  test('successful send marks row sent and inserts sms_outgoing row', () async {
    final fakeDb = _InMemoryScheduledSmsDb();
    final now = DateTime.now().millisecondsSinceEpoch;
    fakeDb.scheduledSmsRows.add({
      'id': 43,
      'contact_id': 8,
      'phone_number': '+14155550101',
      'message': 'See you tomorrow',
      'scheduled_time': now - 5000,
      'is_sent': 0,
      'bulk_job_id': null,
    });
    DatabaseHelper.testDatabase = fakeDb;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => true);

    await SmsProcessor.processDueSms(null, null);

    expect(fakeDb.scheduledSmsRows.first['is_sent'], 1);
    expect(fakeDb.timelineRows.length, 1);
    expect(fakeDb.timelineRows.first['type'], 'sms_outgoing');
    expect(fakeDb.timelineRows.first['content'], 'See you tomorrow');
  });

  test('rows overdue by more than 30 minutes are skipped', () async {
    final fakeDb = _InMemoryScheduledSmsDb();
    final now = DateTime.now().millisecondsSinceEpoch;
    fakeDb.scheduledSmsRows.add({
      'id': 44,
      'contact_id': 9,
      'phone_number': '+14155550102',
      'message': 'Stale scheduled message',
      'scheduled_time': now - const Duration(minutes: 45).inMilliseconds,
      'is_sent': 0,
      'bulk_job_id': null,
    });
    DatabaseHelper.testDatabase = fakeDb;

    int callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      callCount++;
      return true;
    });

    await SmsProcessor.processDueSms(null, null);

    expect(callCount, 0);
    expect(fakeDb.scheduledSmsRows.first['is_sent'], 0);
    expect(fakeDb.timelineRows, isEmpty);
  });
}
