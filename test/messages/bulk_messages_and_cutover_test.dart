import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/messages/sms_counter.dart';
import 'package:pocket_crm/core/messages/template_renderer.dart';
import 'package:pocket_crm/core/native/device_api.g.dart';
import 'package:pocket_crm/core/native/outbox_api.g.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/messages/data/campaigns_repository.dart';
import 'package:pocket_crm/features/messages/data/outbox_repository.dart';
import 'package:pocket_crm/features/messages/data/scheduled_sms_migrator.dart';
import 'package:pocket_crm/features/messages/ui/new_message_screen.dart';
import 'package:pocket_crm/features/people/data/lists_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/sync/data/sync_service.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

class _FakeOutboxClient implements OutboxPlatformClient {
  final List<OutboxItem> enqueued = [];
  final List<CampaignConfig> campaigns = [];
  List<SimInfo> simList = [
    SimInfo(
      subId: 1,
      slot: 0,
      carrierName: 'Carrier 1',
      displayName: 'SIM 1',
      isDefault: true,
    ),
    SimInfo(
      subId: 2,
      slot: 1,
      carrierName: 'Carrier 2',
      displayName: 'SIM 2',
      isDefault: false,
    ),
  ];

  @override
  Future<void> enqueue(List<OutboxItem> items) async {
    enqueued.addAll(items);
  }

  @override
  Future<void> upsertCampaign(CampaignConfig config) async {
    campaigns.add(config);
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
      ChangeSet(items: const [], latestSeq: seq);

  @override
  Future<List<SimInfo>> sims() async => simList;

  @override
  Future<OutboxCapabilities> capabilities() async => OutboxCapabilities(
        exactAlarms: true,
        ignoringBatteryOptimisation: true,
        notifications: true,
        smsPermission: true,
      );

  @override
  Future<void> shareFile(String path, String mimeType, String subject) async {}

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

class _OptOutSyncSource implements DeviceDataSource {
  _OptOutSyncSource(this.sms);
  final List<SmsRecord> sms;

  @override
  Future<List<DeviceContactInput>> readContacts() async => const [];

  @override
  Future<List<CallRecord>> readCalls(int afterId, int limit) async => const [];

  @override
  Future<List<SmsRecord>> readSms(int afterId, int limit) async =>
      sms.where((s) => s.id > afterId).take(limit).toList();

  @override
  Future<String?> simCountryIso() async => 'US';

  @override
  Future<void> startObserving() async {}

  @override
  Future<void> stopObserving() async {}
}

void main() {
  group('renderTemplate', () {
    const settings = TemplateSettings(
      myName: 'Nadia',
      currencyCode: 'USD',
      localeName: 'en_US',
    );

    test('renders all five fields accurately', () {
      const person = TemplatePerson(
        displayName: 'Amara Okafor',
        company: 'Okafor Textiles',
        amountDue: 240,
      );
      final res = renderTemplate(
        'Hi {first name} ({name}) at {company}, {amount due} is due. - {my name}',
        person,
        settings,
      );
      expect(
        res.text,
        'Hi Amara (Amara Okafor) at Okafor Textiles, \$240 is due. - Nadia',
      );
      expect(res.unknownFields, isEmpty);
      expect(res.emptyFieldsWithoutFallback, isEmpty);
      expect(res.primaryMergeSummary, '\$240 due');
    });

    test('applies default fallbacks and explicit bar fallbacks', () {
      const emptyPerson = TemplatePerson(displayName: '');
      final defaultFb = renderTemplate(
        'Hi {first name}, welcome {name}!',
        emptyPerson,
        const TemplateSettings(),
      );
      expect(defaultFb.text, 'Hi there, welcome there!');
      expect(defaultFb.emptyFieldsWithoutFallback, isEmpty);

      final explicitFb = renderTemplate(
        'Hi {first name|friend} from {company|your team}, {amount due|your balance} due.',
        emptyPerson,
        const TemplateSettings(),
      );
      expect(explicitFb.text, 'Hi friend from your team, your balance due.');
      expect(explicitFb.emptyFieldsWithoutFallback, isEmpty);
    });

    test('collapses double spaces and removes space before punctuation for empty fields', () {
      const person = TemplatePerson(displayName: 'Amara Okafor', company: null);
      final res = renderTemplate(
        'Hi {first name} from {company} , thanks {my name} !',
        person,
        const TemplateSettings(myName: ''),
      );
      expect(res.text, 'Hi Amara from, thanks!');
      expect(res.emptyFieldsWithoutFallback, containsAll(['company', 'my name']));
    });

    test('leaves unknown fields as typed and flags them', () {
      const person = TemplatePerson(displayName: 'Amara Okafor');
      final res = renderTemplate(
        'Hi {first name}, order {order id} is ready.',
        person,
        settings,
      );
      expect(res.text, 'Hi Amara, order {order id} is ready.');
      expect(res.unknownFields, ['order id']);
    });
  });

  group('countSms', () {
    test('GSM-7 boundary 160 -> 1 part, 161 -> 2 parts', () {
      final c160 = countSms('a' * 160);
      expect(c160.encoding, SmsEncoding.gsm7);
      expect(c160.units, 160);
      expect(c160.segments, 1);

      final c161 = countSms('a' * 161);
      expect(c161.encoding, SmsEncoding.gsm7);
      expect(c161.units, 161);
      expect(c161.segments, 2);
    });

    test('literal brace { counts as two septets in GSM-7 extension table', () {
      final c = countSms('a{b');
      expect(c.encoding, SmsEncoding.gsm7);
      expect(c.units, 4); // 1 + 2 + 1
      expect(c.segments, 1);
    });

    test('70 Bangla characters is 1 part and 71 is 2 parts (UCS-2)', () {
      final b70 = countSms('ক' * 70);
      expect(b70.encoding, SmsEncoding.ucs2);
      expect(b70.units, 70);
      expect(b70.segments, 1);

      final b71 = countSms('ক' * 71);
      expect(b71.encoding, SmsEncoding.ucs2);
      expect(b71.units, 71);
      expect(b71.segments, 2);
    });

    test('emoji forces UCS-2 and counts as two UTF-16 code units', () {
      final e = countSms('Hi 😀');
      expect(e.encoding, SmsEncoding.ucs2);
      expect(e.units, 5); // H(1) + i(1) + space(1) + emoji(2)
      expect(e.segments, 1);
    });
  });

  group('NewMessageScreen & CampaignsRepository', () {
    testWidgets('Composer preview matches Figma frame 10:498 sample text', (tester) async {
      final db = AppDatabase.inMemory();
      final fakeClient = _FakeOutboxClient();
      final people = PeopleRepository(db);
      final lists = ListsRepository(db);
      final fixedNow = DateTime(2026, 11, 26, 14, 0);

      late int listId;
      await tester.runAsync(() async {
        listId = await lists.createList('Customers');
        final amaraId = await people.createPerson(
          displayName: 'Amara Okafor',
          phoneNumber: '+2348031234567',
          isMobile: true,
        );
        await lists.addMembers(listId, {amaraId});
        await db.into(db.timelineEntries).insert(
              TimelineEntriesCompanion.insert(
                contactId: Value(amaraId),
                type: 'payment',
                timestamp: fixedNow.millisecondsSinceEpoch,
                amount: const Value(240.0),
                currency: const Value('USD'),
                paymentStatus: const Value('owed_to_me'),
                source: const Value('manual'),
              ),
            );

        final priyaId = await people.createPerson(
          displayName: 'Priya Nair',
          phoneNumber: '+919820012345',
          isMobile: true,
        );
        await lists.addMembers(listId, {priyaId});
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => fixedNow),
            outboxPlatformClientProvider.overrideWithValue(fakeClient),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: NewMessageScreen(
              initialListIds: {listId},
              initialBody:
                  'Hi {first name}, a quick reminder that {amount due} is due on Friday. Thank you!',
              initialScheduledAt: DateTime(2026, 11, 26, 18, 0),
            ),
          ),
        ),
      );

      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump();
      }

      expect(
        find.text('Hi Amara, a quick reminder that \$240 is due on Friday. Thank you!'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });

    test('schedules campaign to 24-person list with 2 no-mobile and 1 opted-out -> 21 rendered rows',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final fakeClient = _FakeOutboxClient();
      final fixedNow = DateTime(2026, 11, 26, 14, 0);
      final outbox = OutboxRepository(db: db, client: fakeClient, clock: () => fixedNow);
      final campaigns = CampaignsRepository(db: db, outbox: outbox, clock: () => fixedNow);
      final people = PeopleRepository(db);
      final lists = ListsRepository(db);

      final listId = await lists.createList('Customers');
      final memberIds = <int>{};

      for (var i = 1; i <= 24; i++) {
        final isNoMobile = i <= 2;
        final isOptOut = i == 3;
        final cid = await people.createPerson(
          displayName: 'Person$i Last',
          phoneNumber: '+1415555${i.toString().padLeft(4, '0')}',
          isMobile: !isNoMobile,
        );
        if (isOptOut) {
          await people.setDoNotMessage(cid, true);
        }
        await db.into(db.timelineEntries).insert(
              TimelineEntriesCompanion.insert(
                contactId: Value(cid),
                type: 'payment',
                timestamp: fixedNow.millisecondsSinceEpoch,
                amount: Value(i * 10.0),
                currency: const Value('USD'),
                paymentStatus: const Value('owed_to_me'),
                source: const Value('manual'),
              ),
            );
        memberIds.add(cid);
      }
      await lists.addMembers(listId, memberIds);

      final resolution = await campaigns.resolveRecipients(
        listIds: {listId},
        contactIds: const {},
      );
      expect(resolution.recipients.length, 21);
      expect(resolution.countSkipped(SkipReason.noMobile), 2);
      expect(resolution.countSkipped(SkipReason.optedOut), 1);
      expect(resolution.countSkipped(SkipReason.duplicate), 0);

      final dueAt = DateTime(2026, 11, 26, 18, 0).millisecondsSinceEpoch;
      final campaignId = await campaigns.scheduleMessageOrCampaign(
        name: 'Payment reminder',
        templateBody: 'Hi {first name}, {amount due} is due.',
        recipients: resolution.recipients,
        dueAtMs: dueAt,
        settings: const TemplateSettings(currencyCode: 'USD', localeName: 'en_US'),
        paceSeconds: 4,
      );

      expect(campaignId, isNotNull);
      expect(fakeClient.campaigns.length, 1);
      expect(fakeClient.enqueued.length, 21);

      final outboxRows = await (db.select(db.outboxMessages)
            ..where((t) => t.campaignId.equals(campaignId!)))
          .get();
      expect(outboxRows.length, 21);
      // Every row stores rendered text (never raw `{first name}` placeholder)
      for (final row in outboxRows) {
        expect(row.body.contains('{'), isFalse);
        expect(row.body, startsWith('Hi Person'));
        expect(row.body, contains('\$'));
      }
    });

    test('opt-out detection marks contact do_not_message=1 on STOP and Bangla opt-out word',
        () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final people = PeopleRepository(db);
      final now = DateTime(2026, 11, 26, 14, 0);

      final c1 = await people.createPerson(
        displayName: 'Daniel Reyes',
        phoneNumber: '+14155550111',
      );
      final c2 = await people.createPerson(
        displayName: 'Rahim Uddin',
        phoneNumber: '+8801711000222',
      );

      final sync = SyncService(
        db: db,
        source: _OptOutSyncSource([
          SmsRecord(
            id: 101,
            address: '+14155550111',
            body: '  stop  ',
            dateMs: now.millisecondsSinceEpoch,
            box: 'inbox',
          ),
          SmsRecord(
            id: 102,
            address: '+8801711000222',
            body: 'বন্ধ',
            dateMs: now.millisecondsSinceEpoch + 1000,
            box: 'inbox',
          ),
        ]),
        clock: () => now,
      );

      await sync.syncAll(syncContacts: false, syncCalls: false, syncSms: true);

      expect((await people.getById(c1))!.doNotMessage, 1);
      expect((await people.getById(c2))!.doNotMessage, 1);

      final entries = await db.select(db.timelineEntries).get();
      expect(entries.where((e) => e.outcome == 'opt_out').length, 2);
    });
  });

  group('Part C cut-over migration & database path', () {
    test('migrates v4 future, overdue, sent scheduled rows and bulk job idempotently', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final fakeClient = _FakeOutboxClient();
      final now = DateTime(2026, 11, 26, 14, 0);
      final outbox = OutboxRepository(db: db, client: fakeClient, clock: () => now);
      final migrator = ScheduledSmsMigrator(db: db, outbox: outbox, clock: () => now);
      final people = PeopleRepository(db);

      final c1 = await people.createPerson(displayName: 'Amara Okafor', phoneNumber: '+2348031234567');
      final c2 = await people.createPerson(displayName: 'Priya Nair', phoneNumber: '+919820012345');

      final futureMs = now.add(const Duration(hours: 2)).millisecondsSinceEpoch;
      final pastMs = now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch;

      // Bulk job (2 future rows)
      final jobId = await db.into(db.bulkSmsJobs).insert(
            BulkSmsJobsCompanion.insert(
              listName: 'Customers',
              message: 'Hello everyone!',
              scheduledTime: futureMs,
            ),
          );
      await db.into(db.scheduledSmsEntries).insert(
            ScheduledSmsEntriesCompanion.insert(
              contactId: Value(c1),
              phoneNumber: '+2348031234567',
              message: 'Hello everyone!',
              scheduledTime: futureMs,
              isSent: const Value(0),
              bulkJobId: Value(jobId),
            ),
          );
      await db.into(db.scheduledSmsEntries).insert(
            ScheduledSmsEntriesCompanion.insert(
              contactId: Value(c2),
              phoneNumber: '+919820012345',
              message: 'Hello everyone!',
              scheduledTime: futureMs,
              isSent: const Value(0),
              bulkJobId: Value(jobId),
            ),
          );

      // Single future row
      await db.into(db.scheduledSmsEntries).insert(
            ScheduledSmsEntriesCompanion.insert(
              contactId: Value(c1),
              phoneNumber: '+2348031234567',
              message: 'Future single',
              scheduledTime: futureMs,
              isSent: const Value(0),
            ),
          );

      // Single overdue row -> missed
      await db.into(db.scheduledSmsEntries).insert(
            ScheduledSmsEntriesCompanion.insert(
              contactId: Value(c2),
              phoneNumber: '+919820012345',
              message: 'Overdue single',
              scheduledTime: pastMs,
              isSent: const Value(0),
            ),
          );

      // Already-sent row (is_sent = 1) -> left untouched
      await db.into(db.scheduledSmsEntries).insert(
            ScheduledSmsEntriesCompanion.insert(
              contactId: Value(c1),
              phoneNumber: '+2348031234567',
              message: 'Already sent',
              scheduledTime: pastMs,
              isSent: const Value(1),
            ),
          );

      final report1 = await migrator.migrateOnce();
      expect(report1.alreadyRan, isFalse);
      expect(report1.queuedCount, 3);
      expect(report1.missedCount, 1);
      expect(report1.campaignsCreated, 1);

      // Verify campaign name
      final camps = await db.select(db.campaigns).get();
      expect(camps.length, 1);
      expect(camps.first.name, 'Message to Customers');

      // Verify outbox rows (3 queued, 1 missed; already-sent untouched)
      final outboxRows = await db.select(db.outboxMessages).get();
      expect(outboxRows.length, 4);
      expect(outboxRows.where((r) => r.status == 'queued').length, 3);
      expect(outboxRows.where((r) => r.status == 'missed').length, 1);
      expect(fakeClient.enqueued.length, 3);

      // Verify old scheduled_sms flags: 4 moved rows have is_sent=2, 1 sent row stays is_sent=1
      final oldRows = await db.select(db.scheduledSmsEntries).get();
      expect(oldRows.where((r) => r.isSent == 2).length, 4);
      expect(oldRows.where((r) => r.isSent == 1).length, 1);

      // Running migrateOnce() a second time changes nothing
      final report2 = await migrator.migrateOnce();
      expect(report2.alreadyRan, isTrue);
      expect((await db.select(db.outboxMessages).get()).length, 4);
      expect(fakeClient.enqueued.length, 3);
    });

    test('resolvePocketCrmDatabasePath matches Android sqflite getDatabasesPath exactly', () {
      final path = resolvePocketCrmDatabasePath(
        documentsDirPath: '/data/user/0/com.pocketcrm.pocket_crm/app_flutter',
        isAndroid: true,
      );
      expect(
        path.replaceAll('\\', '/'),
        '/data/user/0/com.pocketcrm.pocket_crm/databases/pocket_crm.db',
      );
    });
  });
}
