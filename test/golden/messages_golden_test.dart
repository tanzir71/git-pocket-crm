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
import 'package:pocket_crm/features/messages/data/outbox_repository.dart';
import 'package:pocket_crm/features/messages/ui/campaign_screen.dart';
import 'package:pocket_crm/features/messages/ui/messages_screen.dart';
import 'package:pocket_crm/features/messages/ui/new_message_screen.dart';
import 'package:pocket_crm/features/people/data/lists_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

final _fixedNow = DateTime(2026, 11, 26, 9, 41);

Future<void> _loadInterFont() async {
  final loader = FontLoader('Inter');
  for (final path in const [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
  ]) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

class _GoldenOutboxClient implements OutboxPlatformClient {
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
  Future<ChangeSet> changesSince(int seq) async =>
      ChangeSet(items: const [], latestSeq: seq);
  @override
  Future<List<SimInfo>> sims() async => [
        SimInfo(subId: 1, slot: 0, carrierName: 'SIM 1', displayName: 'SIM 1', isDefault: true),
        SimInfo(subId: 2, slot: 1, carrierName: 'SIM 2', displayName: 'SIM 2', isDefault: false),
      ];
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

Future<({int listId, String campaignId})> _seedMessagesFixture(AppDatabase db) async {
  final people = PeopleRepository(db);
  final lists = ListsRepository(db);

  final listId = await lists.createList('Customers');

  final specs = <(String name, double due, String status, String? err, int? errCode)>[
    ('Amara Okafor', 240, 'delivered', null, null),
    ('Daniel Reyes', 180, 'failed', 'No service', AndroidSmsResultCodes.noService),
    ('Priya Nair', 1150, 'sent', null, null),
    ('Tanvir Hasan', 60, 'sending', null, null),
    ('Layla Haddad', 410, 'queued', null, null),
    ('Rahim Uddin', 35, 'queued', null, null),
    ('Kenji Watanabe', 220, 'queued', null, null),
  ];

  final campId = 'camp-payment-1';
  final today18 = DateTime(2026, 11, 26, 18, 0).millisecondsSinceEpoch;
  final today1730 = DateTime(2026, 11, 26, 17, 30).millisecondsSinceEpoch;
  final tomorrow09 = DateTime(2026, 11, 27, 9, 0).millisecondsSinceEpoch;
  final tuesday1802 = DateTime(2026, 11, 24, 18, 2).millisecondsSinceEpoch;

  await db.into(db.campaigns).insert(
        CampaignsCompanion.insert(
          id: campId,
          name: 'Payment reminder',
          bodyTemplate:
              'Hi {first name}, a quick reminder that {amount due} is due on Friday.',
          scheduledAt: Value(today18),
          status: 'sending',
          subId: const Value(1),
          paceSeconds: const Value(4),
          windowStartMin: const Value(540),
          windowEndMin: const Value(1260),
          createdAt: Value(_fixedNow.millisecondsSinceEpoch),
        ),
      );

  int? tanvirId;
  int? amaraId;
  int? danielId;

  for (var i = 0; i < specs.length; i++) {
    final (name, due, status, err, errCode) = specs[i];
    final phone = '+141555501${(10 + i).toString()}';
    final cid = await people.createPerson(
      displayName: name,
      phoneNumber: phone,
      isMobile: true,
    );
    if (name == 'Amara Okafor') amaraId = cid;
    if (name == 'Tanvir Hasan') tanvirId = cid;
    if (name == 'Daniel Reyes') danielId = cid;
    await lists.addMembers(listId, {cid});
    await db.into(db.timelineEntries).insert(
          TimelineEntriesCompanion.insert(
            contactId: Value(cid),
            type: 'payment',
            timestamp: _fixedNow.millisecondsSinceEpoch,
            amount: Value(due),
            currency: const Value('USD'),
            paymentStatus: const Value('owed_to_me'),
            source: const Value('manual'),
          ),
        );
    await db.into(db.outboxMessages).insert(
          OutboxMessagesCompanion.insert(
            clientId: 'camp-msg-$i',
            contactId: Value(cid),
            campaignId: Value(campId),
            address: phone,
            body: 'Hi ${name.split(' ').first}, a quick reminder that \$${due.toInt()} is due.',
            dueAt: status == 'failed' ? tuesday1802 : today18,
            status: status,
            errorCode: Value(errCode),
            errorLabel: Value(err),
            mergeSummary: Value('\$${due.toInt()} due'),
            sentAt: Value(status == 'sent' || status == 'delivered' ? today18 : null),
          ),
        );
  }

  // Two non-mobile people in Customers list so "2 skipped: no mobile number" appears
  for (var j = 0; j < 2; j++) {
    final landId = await people.createPerson(
      displayName: 'Office Line ${j + 1}',
      phoneNumber: '+44207946010$j',
      isMobile: false,
    );
    await lists.addMembers(listId, {landId});
  }

  // Single scheduled today & tomorrow
  await db.into(db.outboxMessages).insert(
        OutboxMessagesCompanion.insert(
          clientId: 'single-today',
          contactId: Value(tanvirId),
          address: '+14155550113',
          body: 'Your order is ready for pickup from tomorrow morning.',
          dueAt: today1730,
          status: 'queued',
        ),
      );
  await db.into(db.outboxMessages).insert(
        OutboxMessagesCompanion.insert(
          clientId: 'single-tomorrow',
          contactId: Value(amaraId),
          address: '+14155550110',
          body: 'Hi Amara, sharing the revised pricing we discussed.',
          dueAt: tomorrow09,
          status: 'queued',
        ),
      );
  // Single sent this week
  await db.into(db.outboxMessages).insert(
        OutboxMessagesCompanion.insert(
          clientId: 'single-sent-1',
          contactId: Value(danielId),
          address: '+14155550111',
          body: 'Confirmed.',
          dueAt: tuesday1802,
          status: 'sent',
          sentAt: Value(tuesday1802),
        ),
      );

  return (listId: listId, campaignId: campId);
}

Future<void> _pumpGolden(
  WidgetTester tester, {
  required AppDatabase db,
  required ThemeData theme,
  required Widget child,
  required String goldenFile,
}) async {
  tester.view.physicalSize = const Size(412, 917);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => _fixedNow),
        outboxPlatformClientProvider.overrideWithValue(_GoldenOutboxClient()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(412, 917),
            alwaysUse24HourFormat: true,
          ),
          child: child,
        ),
      ),
    ),
  );

  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump();
  }

  await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$goldenFile'));

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadInterFont);

  for (final (mode, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    testWidgets('golden: Messages ($mode)', (tester) async {
      final db = AppDatabase.inMemory();
      await tester.runAsync(() => _seedMessagesFixture(db));
      await _pumpGolden(
        tester,
        db: db,
        theme: theme,
        child: const MessagesScreen(),
        goldenFile: 'messages_$mode.png',
      );
      await tester.runAsync(db.close);
    });

    testWidgets('golden: New message ($mode)', (tester) async {
      final db = AppDatabase.inMemory();
      final seeded = (await tester.runAsync(() => _seedMessagesFixture(db)))!;
      await _pumpGolden(
        tester,
        db: db,
        theme: theme,
        child: NewMessageScreen(
          initialListIds: {seeded.listId},
          initialBody:
              'Hi {first name}, a quick reminder that {amount due} is due on Friday. Thank you!',
          initialScheduledAt: DateTime(2026, 11, 26, 18, 0),
        ),
        goldenFile: 'new_message_$mode.png',
      );
      await tester.runAsync(db.close);
    });

    testWidgets('golden: Campaign progress ($mode)', (tester) async {
      final db = AppDatabase.inMemory();
      final seeded = (await tester.runAsync(() => _seedMessagesFixture(db)))!;
      await _pumpGolden(
        tester,
        db: db,
        theme: theme,
        child: CampaignScreen(campaignId: seeded.campaignId),
        goldenFile: 'campaign_$mode.png',
      );
      await tester.runAsync(db.close);
    });
  }
}
