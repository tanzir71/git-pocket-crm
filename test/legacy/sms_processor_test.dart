import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/database_helper.dart';
import 'package:pocket_crm/sms_processor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.pocketcrm.pocket_crm/sms');

  late AppDatabase db;

  setUp(() async {
    SmsProcessor.resetSessionState();
    SmsProcessor.throttleDelay = Duration.zero;
    db = AppDatabase.inMemory();
    DatabaseHelper.testAppDatabase = db;
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    DatabaseHelper.testAppDatabase = null;
    await db.close();
    SmsProcessor.resetSessionState();
    SmsProcessor.throttleDelay = const Duration(seconds: 2);
  });

  Future<int> insertContact(String name, String phone) async {
    final legacy = await DatabaseHelper.instance.database;
    return legacy.insert('contacts', {
      'display_name': name,
      'phone_number': phone,
    });
  }

  test('failed send leaves row unsent and does not create sms_outgoing timeline row', () async {
    final contactId = await insertContact('Amara Okafor', '+14155550100');
    final legacy = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final smsId = await legacy.insert('scheduled_sms', {
      'contact_id': contactId,
      'phone_number': '+14155550100',
      'message': 'Follow up reminder',
      'scheduled_time': now - 1000,
      'is_sent': 0,
      'bulk_job_id': null,
    });

    int callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      callCount++;
      return false;
    });

    await SmsProcessor.processDueSms(null, null);

    expect(callCount, 1);
    final rows = await legacy.query('scheduled_sms', where: 'id = ?', whereArgs: [smsId]);
    expect(rows.first['is_sent'], 0);
    final timeline = await legacy.query('timeline');
    expect(timeline, isEmpty);

    // Calling again in the same session does not retry the failed id
    await SmsProcessor.processDueSms(null, null);
    expect(callCount, 1);
  });

  test('successful send marks row sent and inserts sms_outgoing row', () async {
    final contactId = await insertContact('Daniel Reyes', '+14155550101');
    final legacy = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final smsId = await legacy.insert('scheduled_sms', {
      'contact_id': contactId,
      'phone_number': '+14155550101',
      'message': 'See you tomorrow',
      'scheduled_time': now - 5000,
      'is_sent': 0,
      'bulk_job_id': null,
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => true);

    await SmsProcessor.processDueSms(null, null);

    final rows = await legacy.query('scheduled_sms', where: 'id = ?', whereArgs: [smsId]);
    expect(rows.first['is_sent'], 1);
    final timeline = await legacy.query('timeline');
    expect(timeline.length, 1);
    expect(timeline.first['type'], 'sms_outgoing');
    expect(timeline.first['content'], 'See you tomorrow');
  });

  test('rows overdue by more than 30 minutes are skipped', () async {
    final contactId = await insertContact('Priya Nair', '+14155550102');
    final legacy = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final smsId = await legacy.insert('scheduled_sms', {
      'contact_id': contactId,
      'phone_number': '+14155550102',
      'message': 'Stale scheduled message',
      'scheduled_time': now - const Duration(minutes: 45).inMilliseconds,
      'is_sent': 0,
      'bulk_job_id': null,
    });

    int callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      callCount++;
      return true;
    });

    await SmsProcessor.processDueSms(null, null);

    expect(callCount, 0);
    final rows = await legacy.query('scheduled_sms', where: 'id = ?', whereArgs: [smsId]);
    expect(rows.first['is_sent'], 0);
    final timeline = await legacy.query('timeline');
    expect(timeline, isEmpty);
  });
}
