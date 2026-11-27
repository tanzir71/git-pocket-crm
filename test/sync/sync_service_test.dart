import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/native/device_api.g.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/sync/data/sync_service.dart';
import 'package:pocket_crm/features/sync/data/sync_state_repository.dart';

class _FakeDeviceDataSource implements DeviceDataSource {
  _FakeDeviceDataSource({
    this.contacts = const [],
    this.calls = const [],
    this.sms = const [],
    this.region = 'BD',
  });

  final List<DeviceContactInput> contacts;
  final List<CallRecord> calls;
  final List<SmsRecord> sms;
  final String region;

  int readCallsBatches = 0;
  int readSmsBatches = 0;
  int maxCallBatchRequested = 0;
  int maxSmsBatchRequested = 0;

  @override
  Future<List<DeviceContactInput>> readContacts() async => contacts;

  @override
  Future<List<CallRecord>> readCalls(int afterId, int limit) async {
    readCallsBatches++;
    if (limit > maxCallBatchRequested) maxCallBatchRequested = limit;
    return calls.where((c) => c.id > afterId).take(limit).toList();
  }

  @override
  Future<List<SmsRecord>> readSms(int afterId, int limit) async {
    readSmsBatches++;
    if (limit > maxSmsBatchRequested) maxSmsBatchRequested = limit;
    return sms.where((s) => s.id > afterId).take(limit).toList();
  }

  @override
  Future<String?> simCountryIso() async => region;

  @override
  Future<void> startObserving() async {}

  @override
  Future<void> stopObserving() async {}
}

void main() {
  test('syncs 20,000 SMS and 5,000 calls in 500-row batches; second sync reads nothing', () async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final contacts = [
      const DeviceContactInput(
        deviceId: 'dev_1',
        displayName: 'Amara Okafor',
        phones: [DevicePhoneInput(raw: '+8801712345678', isPrimary: true)],
      ),
    ];

    // 5,000 calls (500 matching Amara, 4,500 unknown numbers)
    final calls = List.generate(5000, (i) {
      final id = i + 1;
      final isMatch = id % 10 == 0;
      return CallRecord(
        id: id,
        number: isMatch ? '01712345678' : '+1415999${id.toString().padLeft(4, '0')}',
        type: 'outgoing',
        dateMs: 1700000000000 + id * 1000,
        durationSeconds: 60,
      );
    });

    // 20,000 SMS (1,000 matching Amara, 19,000 unknown/promo senders)
    final sms = List.generate(20000, (i) {
      final id = i + 1;
      final isMatch = id % 20 == 0;
      return SmsRecord(
        id: id,
        address: isMatch ? '+8801712345678' : 'bKash',
        body: 'Message $id',
        dateMs: 1700000000000 + id * 1000,
        box: 'inbox',
      );
    });

    final source = _FakeDeviceDataSource(contacts: contacts, calls: calls, sms: sms);
    final service = SyncService(db: db, source: source, batchSize: 500);
    addTearDown(() async => service.dispose());

    final first = await service.syncAll();
    expect(first.contactsSynced, 1);
    expect(first.callsSynced, 500);
    expect(first.smsSynced, 1000);
    // 5000 / 500 = 10 full batches + 1 empty terminating batch = 11 calls
    expect(source.readCallsBatches, 11);
    // 20000 / 500 = 40 full batches + 1 empty terminating batch = 41 calls
    expect(source.readSmsBatches, 41);
    expect(source.maxCallBatchRequested, 500);
    expect(source.maxSmsBatchRequested, 500);

    // Second sync: watermarks are at 5000 and 20000 -> reads 0 new rows (1 empty probe each)
    source.readCallsBatches = 0;
    source.readSmsBatches = 0;
    final second = await service.syncAll();
    expect(second.contactsSynced, 0);
    expect(second.callsSynced, 0);
    expect(second.smsSynced, 0);
    expect(source.readCallsBatches, 1);
    expect(source.readSmsBatches, 1);
  });

  test('saved contact invoice SMS is kept, multi-number calls match, and amounts become suggestions only',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final source = _FakeDeviceDataSource(
      contacts: const [
        DeviceContactInput(
          deviceId: 'dev_2',
          displayName: 'Tanvir Hasan',
          phones: [
            DevicePhoneInput(raw: '01712345678', label: 'mobile', isPrimary: true),
            DevicePhoneInput(raw: '01812345678', label: 'work'),
          ],
          company: 'Dhaka Lighting',
        ),
      ],
      calls: [
        CallRecord(
          id: 10,
          number: '+8801712345678',
          type: 'outgoing',
          dateMs: 1700000100000,
          durationSeconds: 120,
        ),
        CallRecord(
          id: 11,
          number: '01812345678',
          type: 'incoming',
          dateMs: 1700000200000,
          durationSeconds: 45,
        ),
      ],
      sms: [
        SmsRecord(
          id: 100,
          address: '+8801712345678',
          body: 'Please send the invoice and the bill reference',
          dateMs: 1700000300000,
          box: 'inbox',
        ),
        SmsRecord(
          id: 101,
          address: '+8801712345678',
          body: 'I will pay Tk 500 tomorrow',
          dateMs: 1700000400000,
          box: 'inbox',
        ),
      ],
      region: 'BD',
    );

    final service = SyncService(db: db, source: source);
    addTearDown(() async => service.dispose());

    final res = await service.syncAll();
    expect(res.contactsSynced, 1);
    expect(res.callsSynced, 2);
    expect(res.smsSynced, 2);

    final timeline = await db.select(db.timelineEntries).get();
    // 2 calls + 2 SMS = 4 rows; ZERO auto-created payment rows!
    expect(timeline.length, 4);
    expect(timeline.where((e) => e.type == 'payment'), isEmpty);

    // Invoice SMS from saved contact was NOT filtered out
    final invoiceSms = timeline.firstWhere((e) => e.nativeMessageId == 'sms:100');
    expect(invoiceSms.content, 'Please send the invoice and the bill reference');

    // Amount in SMS became a suggestion on the SMS row, not a payment
    final paySms = timeline.firstWhere((e) => e.nativeMessageId == 'sms:101');
    expect(paySms.suggestedAmount, 500.0);
    expect(paySms.suggestionState, 'open');

    // Both phone numbers stored and matched
    final phones = await db.select(db.contactPhones).get();
    expect(phones.length, 2);
  });

  test('re-running sync after migrating legacy rows creates zero duplicates', () async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final peopleRepo = PeopleRepository(db);
    final cid = await peopleRepo.createPerson(
      displayName: 'Priya Nair',
      phoneNumber: '+8801712345678',
    );

    // Seed legacy-format rows: bare numeric SMS id and null-id call row
    await db.into(db.timelineEntries).insert(
          TimelineEntriesCompanion.insert(
            contactId: Value(cid),
            type: 'sms_incoming',
            timestamp: 1700001000000,
            content: const Value('Old SMS'),
            nativeMessageId: const Value('55'),
          ),
        );
    await db.into(db.timelineEntries).insert(
          TimelineEntriesCompanion.insert(
            contactId: Value(cid),
            type: 'call_outgoing',
            timestamp: 1700002000000,
            content: const Value('Duration: 1 min 0 sec'),
            durationSeconds: const Value(60),
          ),
        );

    final source = _FakeDeviceDataSource(
      calls: [
        CallRecord(
          id: 7,
          number: '01712345678',
          type: 'outgoing',
          dateMs: 1700002000000,
          durationSeconds: 60,
        ),
      ],
      sms: [
        SmsRecord(
          id: 55,
          address: '+8801712345678',
          body: 'Old SMS',
          dateMs: 1700001000000,
          box: 'inbox',
        ),
      ],
      region: 'BD',
    );

    final service = SyncService(db: db, source: source);
    addTearDown(() async => service.dispose());

    await service.syncAll();

    final timeline = await db.select(db.timelineEntries).get();
    expect(timeline.length, 2);
    expect(
      timeline.firstWhere((e) => e.type == 'sms_incoming').nativeMessageId,
      'sms:55',
    );
    expect(
      timeline.firstWhere((e) => e.type == 'call_outgoing').nativeMessageId,
      'call:7',
    );
  });

  test('phone migration detects duplicate E.164 across two contacts and records merge suggestion',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final peopleRepo = PeopleRepository(db);
    await peopleRepo.createPerson(displayName: 'Contact A', phoneNumber: '01712345678');
    await peopleRepo.createPerson(displayName: 'Contact B', phoneNumber: '+8801712345678');

    final source = _FakeDeviceDataSource(region: 'BD');
    final service = SyncService(db: db, source: source);
    addTearDown(() async => service.dispose());

    await service.syncAll();

    // Both contacts preserved
    expect((await db.select(db.contacts).get()).length, 2);
    // Merge suggestion recorded
    final rawSuggestions = await SyncStateRepository(db).get('merge_suggestions');
    expect(rawSuggestions, isNotNull);
    expect(rawSuggestions, contains('+8801712345678'));
  });
}
