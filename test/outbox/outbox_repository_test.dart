import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/messages/sms_counter.dart';
import 'package:pocket_crm/core/native/device_api.g.dart';
import 'package:pocket_crm/core/native/outbox_api.g.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/messages/data/outbox_repository.dart';
import 'package:pocket_crm/features/messages/ui/single_message_sheet.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/sync/data/sync_service.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

class FakeOutboxPlatformClient implements OutboxPlatformClient {
  final List<OutboxItem> enqueued = [];
  final List<String> cancelled = [];
  final List<String> retried = [];
  final Map<String, OutboxItem> store = {};
  final List<OutboxItem> changeLog = [];
  int seq = 0;
  bool failNextEnqueue = false;
  List<SimInfo> simList = const [];
  OutboxCapabilities caps = OutboxCapabilities(
    exactAlarms: true,
    ignoringBatteryOptimisation: true,
    notifications: true,
    smsPermission: true,
  );
  void Function(int latestSeq)? onChangedCallback;

  void recordNativeChange(OutboxItem item) {
    seq++;
    final updated = OutboxItem(
      clientId: item.clientId,
      campaignId: item.campaignId,
      address: item.address,
      recipientName: item.recipientName,
      body: item.body,
      dueAtMs: item.dueAtMs,
      subId: item.subId,
      status: item.status,
      attempt: item.attempt,
      partsTotal: item.partsTotal,
      partsSent: item.partsSent,
      partsFailed: item.partsFailed,
      partsDelivered: item.partsDelivered,
      errorCode: item.errorCode,
      sentAtMs: item.sentAtMs,
      deliveredAtMs: item.deliveredAtMs,
      seq: seq,
    );
    store[item.clientId] = updated;
    changeLog.add(updated);
  }

  @override
  Future<void> enqueue(List<OutboxItem> items) async {
    if (failNextEnqueue) {
      failNextEnqueue = false;
      throw StateError('Simulated bridge failure');
    }
    for (final item in items) {
      if (!store.containsKey(item.clientId)) {
        enqueued.add(item);
        recordNativeChange(item);
      }
    }
  }

  @override
  Future<void> upsertCampaign(CampaignConfig config) async {}

  @override
  Future<void> cancel(List<String> clientIds) async {
    cancelled.addAll(clientIds);
  }

  @override
  Future<void> retry(List<String> clientIds) async {
    retried.addAll(clientIds);
  }

  @override
  Future<void> pauseCampaign(String id) async {}

  @override
  Future<void> resumeCampaign(String id) async {}

  @override
  Future<void> stopCampaign(String id) async {}

  @override
  Future<ChangeSet> changesSince(int sinceSeq) async {
    final matching = changeLog.where((i) => i.seq > sinceSeq).toList();
    return ChangeSet(items: matching, latestSeq: seq);
  }

  @override
  Future<List<SimInfo>> sims() async => simList;

  @override
  Future<OutboxCapabilities> capabilities() async => caps;

  @override
  Future<void> shareFile(String path, String mimeType, String subject) async {}

  @override
  void listenForChanges(void Function(int latestSeq) onChanged) {
    onChangedCallback = onChanged;
  }
}

class _FakeSyncSource implements DeviceDataSource {
  _FakeSyncSource({this.sms = const []});

  final List<SmsRecord> sms;

  @override
  Future<List<DeviceContactInput>> readContacts() async => const [];

  @override
  Future<List<CallRecord>> readCalls(int afterId, int limit) async => const [];

  @override
  Future<List<SmsRecord>> readSms(int afterId, int limit) async {
    return sms.where((s) => s.id > afterId).take(limit).toList();
  }

  @override
  Future<String?> simCountryIso() async => 'US';

  @override
  Future<void> startObserving() async {}

  @override
  Future<void> stopObserving() async {}
}

void main() {
  group('OutboxRepository', () {
    test('reconcile applies changes in order and creates exactly one timeline row even when run twice',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final people = PeopleRepository(db);
      final fakeClient = FakeOutboxPlatformClient();
      final fixedNow = DateTime(2026, 11, 27, 10, 0);
      final repo = OutboxRepository(
        db: db,
        client: fakeClient,
        clock: () => fixedNow,
      );

      final contactId = await people.createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );

      final clientId = await repo.scheduleSingle(
        contactId: contactId,
        address: '+2348031234567',
        recipientName: 'Amara Okafor',
        body: 'Hi Amara, confirming delivery for 3pm.',
        dueAtMs: fixedNow.millisecondsSinceEpoch,
      );

      expect(fakeClient.enqueued.length, 1);

      // Simulate native transitions in order: sending -> sent -> delivered
      final base = fakeClient.store[clientId]!;
      final sentAtMs = fixedNow.add(const Duration(seconds: 5)).millisecondsSinceEpoch;
      final deliveredAtMs = fixedNow.add(const Duration(seconds: 12)).millisecondsSinceEpoch;

      fakeClient.recordNativeChange(
        OutboxItem(
          clientId: clientId,
          address: base.address,
          recipientName: base.recipientName,
          body: base.body,
          dueAtMs: base.dueAtMs,
          status: 'sending',
          partsTotal: 1,
        ),
      );
      fakeClient.recordNativeChange(
        OutboxItem(
          clientId: clientId,
          address: base.address,
          recipientName: base.recipientName,
          body: base.body,
          dueAtMs: base.dueAtMs,
          status: 'sent',
          partsTotal: 1,
          partsSent: 1,
          sentAtMs: sentAtMs,
        ),
      );

      final count1 = await repo.reconcile();
      expect(count1, greaterThanOrEqualTo(2));

      // Verify outbox row is `sent` and exactly ONE timeline row exists
      final msgAfter1 = await (db.select(db.outboxMessages)
            ..where((t) => t.clientId.equals(clientId)))
          .getSingle();
      expect(msgAfter1.status, 'sent');
      expect(msgAfter1.sentAt, sentAtMs);

      var timelineRows = await (db.select(db.timelineEntries)
            ..where((t) => t.contactId.equals(contactId)))
          .get();
      expect(timelineRows.length, 1);
      expect(timelineRows.first.type, 'sms_outgoing');
      expect(timelineRows.first.nativeMessageId, 'outbox:$clientId');
      expect(timelineRows.first.outboxClientId, clientId);

      // Simulate delivered transition and force a re-reconcile from seq 0
      fakeClient.recordNativeChange(
        OutboxItem(
          clientId: clientId,
          address: base.address,
          recipientName: base.recipientName,
          body: base.body,
          dueAtMs: base.dueAtMs,
          status: 'delivered',
          partsTotal: 1,
          partsSent: 1,
          partsDelivered: 1,
          sentAtMs: sentAtMs,
          deliveredAtMs: deliveredAtMs,
        ),
      );
      await repo.reconcile();
      // Even if seq is reset to 0 and reconcile runs again, still exactly 1 timeline row
      await (db.update(db.syncStates)..where((t) => t.key.equals('outbox_last_seq')))
          .write(const SyncStatesCompanion(value: Value('0')));
      await repo.reconcile();

      timelineRows = await (db.select(db.timelineEntries)
            ..where((t) => t.contactId.equals(contactId)))
          .get();
      expect(timelineRows.length, 1);

      final msgFinal = await (db.select(db.outboxMessages)
            ..where((t) => t.clientId.equals(clientId)))
          .getSingle();
      expect(msgFinal.status, 'delivered');
      expect(msgFinal.deliveredAt, deliveredAtMs);

      final updatedContact = await people.getById(contactId);
      expect(updatedContact!.lastInteractionAt, sentAtMs);
    });

    test('failed native enqueue leaves row queued and reconcile re-enqueues idempotently',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final fakeClient = FakeOutboxPlatformClient()..failNextEnqueue = true;
      final now = DateTime(2026, 11, 27, 10, 0);
      final repo = OutboxRepository(db: db, client: fakeClient, clock: () => now);

      final clientId = await repo.scheduleSingle(
        contactId: null,
        address: '+14155550100',
        body: 'Hello',
        dueAtMs: now.millisecondsSinceEpoch,
      );

      expect(fakeClient.enqueued, isEmpty);
      await repo.reconcile();
      expect(fakeClient.enqueued.map((e) => e.clientId), [clientId]);
    });

    test('sync deduplication stamps provider_sms_id and skips duplicate outgoing SMS insert',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final people = PeopleRepository(db);
      final fakeClient = FakeOutboxPlatformClient();
      final sentTime = DateTime(2026, 11, 27, 11, 0);
      final repo = OutboxRepository(db: db, client: fakeClient, clock: () => sentTime);

      final contactId = await people.createPerson(
        displayName: 'Kenji Sato',
        phoneNumber: '+14155550199',
      );

      final clientId = await repo.scheduleSingle(
        contactId: contactId,
        address: '+14155550199',
        recipientName: 'Kenji Sato',
        body: 'Invoice #42 sent.',
        dueAtMs: sentTime.millisecondsSinceEpoch,
      );

      // Native reports sent
      final base = fakeClient.store[clientId]!;
      fakeClient.recordNativeChange(
        OutboxItem(
          clientId: clientId,
          address: base.address,
          recipientName: base.recipientName,
          body: base.body,
          dueAtMs: base.dueAtMs,
          status: 'sent',
          partsTotal: 1,
          partsSent: 1,
          sentAtMs: sentTime.millisecondsSinceEpoch,
        ),
      );
      await repo.reconcile();

      // Now Android's system SMS store also has this sent message 15 seconds later
      // in a local formatting variant `(415) 555-0199`.
      final sync = SyncService(
        db: db,
        source: _FakeSyncSource(
          sms: [
            SmsRecord(
              id: 9001,
              address: '(415) 555-0199',
              body: 'Invoice #42 sent.',
              dateMs: sentTime.add(const Duration(seconds: 15)).millisecondsSinceEpoch,
              box: 'sent',
            ),
            // A different outgoing SMS outside outbox MUST still be inserted
            SmsRecord(
              id: 9002,
              address: '+14155550199',
              body: 'Sent manually from Messages app.',
              dateMs: sentTime.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
              box: 'sent',
            ),
          ],
        ),
        clock: () => sentTime.add(const Duration(minutes: 6)),
      );

      await sync.syncAll(syncContacts: false, syncCalls: false, syncSms: true);

      // Outbox row stamped with provider_sms_id
      final outboxRow = await (db.select(db.outboxMessages)
            ..where((t) => t.clientId.equals(clientId)))
          .getSingle();
      expect(outboxRow.providerSmsId, 'sms:9001');

      // Timeline has 2 rows total: 1 outbox row + 1 manual SMS row (no duplicate of 9001!)
      final timelineRows = await (db.select(db.timelineEntries)
            ..where((t) => t.contactId.equals(contactId)))
          .get();
      expect(timelineRows.length, 2);
      expect(
        timelineRows.map((r) => r.nativeMessageId).toSet(),
        {'outbox:$clientId', 'sms:9002'},
      );
    });

    test('reason label mapping covers all required Android SmsManager codes', () {
      expect(smsErrorReasonLabel(AndroidSmsResultCodes.noService), 'No service');
      expect(
        smsErrorReasonLabel(AndroidSmsResultCodes.radioOff),
        'Airplane mode or radio off',
      );
      expect(
        smsErrorReasonLabel(AndroidSmsResultCodes.limitExceeded),
        'Sending limit reached',
      );
      expect(
        smsErrorReasonLabel(AndroidSmsResultCodes.shortCodeNotAllowed),
        'Not allowed by the network',
      );
      expect(smsErrorReasonLabel(99), 'Unknown error (99)');
    });
  });

  group('countSms', () {
    test('GSM-7 basic & extension table and UCS-2 boundaries', () {
      expect(countSms('a' * 160).segments, 1);
      expect(countSms('a' * 161).segments, 2);
      // Euro sign is in GSM-7 extension table -> 2 septets
      final euro159 = '${'a' * 159}€';
      expect(countSms(euro159).encoding, SmsEncoding.gsm7);
      expect(countSms(euro159).units, 161);
      expect(countSms(euro159).segments, 2);
      // Bangla -> UCS-2 (70/67)
      final bangla70 = 'ক' * 70;
      expect(countSms(bangla70).encoding, SmsEncoding.ucs2);
      expect(countSms(bangla70).segments, 1);
      expect(countSms('ক' * 71).segments, 2);
    });
  });

  group('SingleMessageSheet', () {
    testWidgets('shows live counter, dual-SIM selector, and schedules message into outbox',
        (tester) async {
      final db = AppDatabase.inMemory();
      final fakeClient = FakeOutboxPlatformClient()
        ..simList = [
          SimInfo(
            subId: 1,
            slot: 0,
            carrierName: 'Carrier A',
            displayName: 'Work SIM',
            isDefault: true,
          ),
          SimInfo(
            subId: 2,
            slot: 1,
            carrierName: 'Carrier B',
            displayName: 'Personal',
            isDefault: false,
          ),
        ];
      final now = DateTime(2026, 11, 27, 10, 0);
      final people = PeopleRepository(db);
      late Contact contact;

      await tester.runAsync(() async {
        final id = await people.createPerson(
          displayName: 'Amara Okafor',
          phoneNumber: '+2348031234567',
        );
        contact = (await people.getById(id))!;
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => now),
            outboxPlatformClientProvider.overrideWithValue(fakeClient),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showSingleMessageSheet(
                      ctx,
                      contact: contact,
                      address: '+2348031234567',
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dual-SIM selector visible
      expect(find.text('SIM 1 · Work SIM'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'See you at 3pm!');
      await tester.pump();
      expect(find.text('15 / 160 · 1 SMS'), findsOneWidget);

      // Tap primary Send now button (last 'Send now' text is the primary CTA)
      await tester.tap(find.text('Send now').last);
      await tester.pumpAndSettle();

      expect(fakeClient.enqueued.length, 1);
      expect(fakeClient.enqueued.first.body, 'See you at 3pm!');
      expect(fakeClient.enqueued.first.subId, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });
  });
}
