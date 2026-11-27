import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/native/outbox_api.g.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/capture/ui/add_sheet.dart';
import 'package:pocket_crm/features/capture/ui/after_call_sheet.dart';
import 'package:pocket_crm/features/followups/data/followups_repository.dart';
import 'package:pocket_crm/features/history/data/history_repository.dart';
import 'package:pocket_crm/features/messages/data/outbox_repository.dart';
import 'package:pocket_crm/features/messages/ui/campaign_screen.dart';
import 'package:pocket_crm/features/messages/ui/messages_screen.dart';
import 'package:pocket_crm/features/messages/ui/new_message_screen.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/people/ui/people_screen.dart';
import 'package:pocket_crm/features/people/ui/person_screen.dart';
import 'package:pocket_crm/features/setup/data/setup_controller.dart';
import 'package:pocket_crm/features/setup/ui/setup_screen.dart';
import 'package:pocket_crm/features/today/ui/today_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

import '../today/cadence_and_notifications_test.dart';

final _fixedNow = DateTime(2026, 11, 26, 11, 0);

class _GoldenOutbox implements OutboxPlatformClient {
  @override
  Future<void> enqueue(List<OutboxItem> items) async {}
  @override
  Future<void> upsertCampaign(CampaignConfig config) async {}
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
  Future<ChangeSet> changesSince(int seq) async => ChangeSet(items: const [], latestSeq: seq);
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

class _GoldenSetupBridge implements SetupPlatformBridge {
  @override
  Future<SetupCapabilityState> readState() async => const SetupCapabilityState(
        contactsGranted: true,
        callsAndMessagesGranted: true,
        exactAlarmsGranted: false,
        batteryGranted: false,
        notificationsGranted: true,
      );
  @override
  Future<bool> requestContacts() async => true;
  @override
  Future<CallsSmsRequestResult> requestCallsAndMessages() async =>
      const CallsSmsRequestResult(granted: true, elapsed: Duration(milliseconds: 500));
  @override
  Future<void> openExactAlarmSettings() async {}
  @override
  Future<void> requestIgnoreBatteryOptimisations() async {}
  @override
  Future<bool> requestNotifications() async => true;
  @override
  Future<void> openAppDetailsSettings() async {}
}

Future<void> _loadBundledInter() async {
  final loader = FontLoader('Inter');
  for (final file in const [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
  ]) {
    final bytes = await File(file).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<({int contactId, TimelineEntry callEntry, String campaignId})> _seedData(
  AppDatabase db, {
  bool rtlPseudo = false,
}) async {
  final people = PeopleRepository(db);
  final followUps = FollowUpsRepository(db);
  final history = HistoryRepository(db);

  final amaraId = await people.createPerson(
    displayName: rtlPseudo ? 'عمارة أوكافور' : 'Amara Okafor',
    phoneNumber: '+2348031234567',
    company: rtlPseudo ? 'أوكافور للمنسوجات' : 'Okafor Textiles',
    city: rtlPseudo ? 'لاغوس' : 'Lagos',
  );
  await people.setCadence(amaraId, 14);
  final callId = await db.into(db.timelineEntries).insert(
        TimelineEntriesCompanion.insert(
          contactId: Value(amaraId),
          type: 'call_outgoing',
          timestamp: DateTime(2026, 11, 26, 10, 12).millisecondsSinceEpoch,
          durationSeconds: const Value(240),
          source: const Value('device'),
        ),
      );
  final callEntry = await (db.select(db.timelineEntries)
        ..where((t) => t.id.equals(callId)))
      .getSingle();
  await followUps.createFollowUp(
    contactId: amaraId,
    title: rtlPseudo ? 'إرسال قائمة الأسعار المحدثة' : 'Send revised pricing sheet',
    dueDateMs: DateTime(2026, 11, 26, 15, 0).millisecondsSinceEpoch,
  );
  await history.addNote(
    contactId: amaraId,
    note: rtlPseudo ? 'مناقشة طلب الجملة للربع الأول' : 'Discussed Q1 wholesale order',
    timestamp: DateTime(2026, 11, 25, 14, 0).millisecondsSinceEpoch,
  );
  await db.into(db.timelineEntries).insert(
        TimelineEntriesCompanion.insert(
          contactId: Value(amaraId),
          type: 'payment',
          timestamp: DateTime(2026, 11, 24, 12, 0).millisecondsSinceEpoch,
          amount: const Value(240.0),
          currency: const Value('USD'),
          paymentStatus: const Value('owed_to_me'),
          note: Value(rtlPseudo ? 'فاتورة ٤٤' : 'Invoice #44'),
        ),
      );

  const campId = 'camp-g13';
  await db.into(db.campaigns).insert(
        CampaignsCompanion.insert(
          id: campId,
          name: 'November check-in',
          bodyTemplate: 'Hi {first_name}, checking in.',
          status: 'running',
          paceSeconds: const Value(15),
          createdAt: Value(_fixedNow.millisecondsSinceEpoch),
        ),
      );
  await db.into(db.outboxMessages).insert(
        OutboxMessagesCompanion.insert(
          clientId: 'outbox-g13-1',
          contactId: Value(amaraId),
          campaignId: const Value(campId),
          address: '+2348031234567',
          body: 'Hi Amara, checking in.',
          dueAt: DateTime(2026, 11, 26, 16, 0).millisecondsSinceEpoch,
          status: 'queued',
        ),
      );

  return (contactId: amaraId, callEntry: callEntry, campaignId: campId);
}

Future<void> _pumpAndMatch(
  WidgetTester tester, {
  required AppDatabase db,
  required Widget home,
  required String goldenFile,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(412, 917);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => _fixedNow),
        notificationsBackendProvider.overrideWithValue(FakeNotificationsBackend()),
        outboxPlatformClientProvider.overrideWithValue(_GoldenOutbox()),
        setupPlatformBridgeProvider.overrideWithValue(_GoldenSetupBridge()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (ctx, child) => Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
        ),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$goldenFile'),
  );

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadBundledInter);

  group('RTL goldens (Today, Person, New message)', () {
    testWidgets('golden: Today (RTL)', (tester) async {
      final db = AppDatabase.inMemory();
      await _seedData(db, rtlPseudo: true);
      await _pumpAndMatch(
        tester,
        db: db,
        home: const TodayScreen(),
        goldenFile: 'rtl_today.png',
        textDirection: TextDirection.rtl,
      );
      await db.close();
    });

    testWidgets('golden: Person (RTL)', (tester) async {
      final db = AppDatabase.inMemory();
      final seeded = await _seedData(db, rtlPseudo: true);
      await _pumpAndMatch(
        tester,
        db: db,
        home: PersonScreen(contactId: seeded.contactId),
        goldenFile: 'rtl_person.png',
        textDirection: TextDirection.rtl,
      );
      await db.close();
    });

    testWidgets('golden: New message (RTL)', (tester) async {
      final db = AppDatabase.inMemory();
      final seeded = await _seedData(db, rtlPseudo: true);
      await _pumpAndMatch(
        tester,
        db: db,
        home: NewMessageScreen(
          initialContactIds: {seeded.contactId},
          initialBody: 'مرحباً {first_name}، تذكير سريع بدفعة {amount_due}.',
        ),
        goldenFile: 'rtl_new_message.png',
        textDirection: TextDirection.rtl,
      );
      await db.close();
    });
  });

  group('Text scale 1.3x and 2.0x goldens across all 9 designed screens', () {
    for (final scale in const [1.3, 2.0]) {
      final tag = scale == 1.3 ? '130' : '200';

      testWidgets('golden: 9 screens at ${scale}x', (tester) async {
        final db = AppDatabase.inMemory();
        final seeded = await _seedData(db);
        final contact = (await PeopleRepository(db).getById(seeded.contactId))!;

        final screens = <(String, Widget)>[
          ('today', const TodayScreen()),
          ('people', const PeopleScreen()),
          ('person', PersonScreen(contactId: seeded.contactId)),
          ('add', Scaffold(body: SingleChildScrollView(child: AddSheetBody(fixedPerson: contact)))),
          (
            'after_call',
            Scaffold(
              body: SingleChildScrollView(
                child: AfterCallSheetBody(contact: contact, callEntry: seeded.callEntry),
              ),
            ),
          ),
          ('messages', const MessagesScreen()),
          ('new_message', NewMessageScreen(initialContactIds: {seeded.contactId})),
          ('campaign', CampaignScreen(campaignId: seeded.campaignId)),
          ('setup', const SetupScreen()),
        ];

        for (final (name, widget) in screens) {
          await _pumpAndMatch(
            tester,
            db: db,
            home: widget,
            goldenFile: 'scale_${tag}_$name.png',
            textScale: scale,
          );
        }
        await db.close();
      });
    }
  });
}
