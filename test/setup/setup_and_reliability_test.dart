import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/app.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/format/app_formatters.dart';
import 'package:pocket_crm/core/native/outbox_api.g.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/core/widgets/widgets.dart';
import 'package:pocket_crm/features/messages/data/outbox_repository.dart';
import 'package:pocket_crm/features/messages/ui/new_message_screen.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/setup/data/setup_controller.dart';
import 'package:pocket_crm/features/setup/ui/setup_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';
import 'package:pocket_crm/l10n/app_localizations_en.dart';

class _FakeSetupBridge implements SetupPlatformBridge {
  _FakeSetupBridge(this.state);

  SetupCapabilityState state;
  bool contactsResult = false;
  CallsSmsRequestResult callsSmsResult =
      const CallsSmsRequestResult(granted: false, elapsed: Duration(milliseconds: 50));
  bool notificationsResult = true;
  int openedAppDetails = 0;
  int openedExactAlarms = 0;
  int requestedBattery = 0;

  @override
  Future<SetupCapabilityState> readState() async => state;

  @override
  Future<bool> requestContacts() async {
    if (contactsResult) {
      state = SetupCapabilityState(
        contactsGranted: true,
        callsAndMessagesGranted: state.callsAndMessagesGranted,
        exactAlarmsGranted: state.exactAlarmsGranted,
        batteryGranted: state.batteryGranted,
        notificationsGranted: state.notificationsGranted,
        sdkInt: state.sdkInt,
        manufacturer: state.manufacturer,
        installedFromStore: state.installedFromStore,
        ownPhoneNumber: state.ownPhoneNumber,
      );
    }
    return contactsResult;
  }

  @override
  Future<CallsSmsRequestResult> requestCallsAndMessages() async {
    if (callsSmsResult.granted) {
      state = SetupCapabilityState(
        contactsGranted: state.contactsGranted,
        callsAndMessagesGranted: true,
        exactAlarmsGranted: state.exactAlarmsGranted,
        batteryGranted: state.batteryGranted,
        notificationsGranted: state.notificationsGranted,
        sdkInt: state.sdkInt,
        manufacturer: state.manufacturer,
        installedFromStore: state.installedFromStore,
        ownPhoneNumber: state.ownPhoneNumber,
      );
    }
    return callsSmsResult;
  }

  @override
  Future<void> openExactAlarmSettings() async => openedExactAlarms++;

  @override
  Future<void> requestIgnoreBatteryOptimisations() async => requestedBattery++;

  @override
  Future<bool> requestNotifications() async => notificationsResult;

  @override
  Future<void> openAppDetailsSettings() async => openedAppDetails++;
}

class _FakeOutbox implements OutboxPlatformClient {
  _FakeOutbox({this.smsPermission = true});
  final bool smsPermission;

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
        exactAlarms: false,
        ignoringBatteryOptimisation: false,
        notifications: false,
        smsPermission: smsPermission,
      );
  @override
  Future<void> shareFile(String path, String mimeType, String subject) async {}
  @override
  Future<SetupPlatformInfo> setupInfo() async =>
      SetupPlatformInfo(sdkInt: 34, manufacturer: 'Samsung', installedFromStore: false);
  @override
  Future<void> openExactAlarmSettings() async {}
  @override
  Future<void> requestIgnoreBatteryOptimisations() async {}
  @override
  Future<void> openAppDetailsSettings() async {}
  @override
  void listenForChanges(void Function(int latestSeq) onChanged) {}
}

void main() {
  group('SetupScreen', () {
    testWidgets(
        'shows live states, disables Continue until Contacts allowed, opens restricted-settings guide on instant file-install denial',
        (tester) async {
      final db = AppDatabase.inMemory();
      final bridge = _FakeSetupBridge(
        const SetupCapabilityState(
          contactsGranted: false,
          callsAndMessagesGranted: false,
          exactAlarmsGranted: false,
          batteryGranted: true,
          notificationsGranted: true,
          sdkInt: 34,
          manufacturer: 'Samsung',
          installedFromStore: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            outboxPlatformClientProvider.overrideWithValue(_FakeOutbox()),
            setupPlatformBridgeProvider.overrideWithValue(bridge),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // OEM Samsung battery guidance shown since batteryGranted=true
      expect(find.text('Add PocketCRM to Never sleeping apps'), findsOneWidget);
      // Notifications allowed
      expect(find.text('Allowed'), findsOneWidget);
      // Privacy note present
      expect(
        find.text('Everything stays on this phone. PocketCRM has no internet access.'),
        findsOneWidget,
      );

      // Continue is disabled while Contacts is not granted
      final continueBtnBefore = tester.widget<AppButton>(
        find.ancestor(of: find.text('Continue'), matching: find.byType(AppButton)),
      );
      expect(continueBtnBefore.onPressed, isNull);

      // Deny Contacts twice -> button becomes "Open settings"
      await tester.tap(find.text('Allow').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow').first);
      await tester.pumpAndSettle();
      expect(find.text('Open settings'), findsNWidgets(2)); // Contacts + Samsung Battery

      // Tap Calls and messages Allow -> instant denial (<300ms) on Android 14 non-store -> guide sheet!
      await tester.tap(find.text('Allow').first);
      await tester.pumpAndSettle();
      expect(find.text('Allow restricted settings'), findsOneWidget);
      expect(find.text('1. Tap the three dots at the top right.'), findsOneWidget);
      expect(find.text('Open app info'), findsOneWidget);
      await tester.tap(find.text('Open app info'));
      await tester.pumpAndSettle();
      expect(bridge.openedAppDetails, 1);

      // Grant Contacts -> Continue becomes enabled
      bridge.state = const SetupCapabilityState(
        contactsGranted: true,
        callsAndMessagesGranted: false,
        exactAlarmsGranted: false,
        batteryGranted: false,
        notificationsGranted: false,
      );
      // Trigger resume lifecycle to re-read capabilities
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      final continueBtnAfter = tester.widget<AppButton>(
        find.ancestor(of: find.text('Continue'), matching: find.byType(AppButton)),
      );
      expect(continueBtnAfter.onPressed, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
  });

  group('ReliabilityCheckService', () {
    test('reports on time, late, and failed with exact copy', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final fixedNow = DateTime(2026, 11, 27, 10, 0);
      final outbox = OutboxRepository(
        db: db,
        client: _FakeOutbox(),
        clock: () => fixedNow,
      );
      final service = ReliabilityCheckService(
        db: db,
        outbox: outbox,
        clock: () => fixedNow,
      );
      final l10n = AppLocalizationsEn();
      final fmt = AppFormatters(clock: () => fixedNow, use24Hour: true);

      final scheduled = await service.scheduleTestMessage(
        ownNumber: '+14155550100',
        formattedTime: '10:02',
        body: 'PocketCRM test, scheduled for 10:02',
      );

      // 1. Pending
      final pending = await service.evaluate();
      expect(pending.kind, ReliabilityOutcomeKind.pending);
      expect(
        pending.formatMessage(l10n, fmt),
        'Close the app and lock your phone. The message should arrive at 10:02.',
      );

      // 2. On time (+10 seconds)
      await (db.update(db.outboxMessages)
            ..where((t) => t.clientId.equals(scheduled.clientId)))
          .write(
        OutboxMessagesCompanion(
          status: const Value('sent'),
          sentAt: Value(scheduled.dueAtMs + 10 * 1000),
        ),
      );
      final onTime = await service.evaluate();
      expect(onTime.kind, ReliabilityOutcomeKind.onTime);
      expect(onTime.formatMessage(l10n, fmt), 'Arrived on time');

      // 3. Late (+4 minutes)
      await (db.update(db.outboxMessages)
            ..where((t) => t.clientId.equals(scheduled.clientId)))
          .write(
        OutboxMessagesCompanion(
          status: const Value('sent'),
          sentAt: Value(scheduled.dueAtMs + 4 * 60 * 1000),
        ),
      );
      final late = await service.evaluate();
      expect(late.kind, ReliabilityOutcomeKind.late);
      expect(
        late.formatMessage(l10n, fmt),
        'Arrived 4 minutes late: allow Alarms and reminders, and check the Battery step',
      );

      // 4. Failed (No service)
      await (db.update(db.outboxMessages)
            ..where((t) => t.clientId.equals(scheduled.clientId)))
          .write(
        const OutboxMessagesCompanion(
          status: Value('failed'),
          errorCode: Value(AndroidSmsResultCodes.noService),
          errorLabel: Value('No service'),
        ),
      );
      final failed = await service.evaluate();
      expect(failed.kind, ReliabilityOutcomeKind.failed);
      expect(failed.formatMessage(l10n, fmt), 'Not sent: No service');
    });
  });

  group('Degraded modes (all permissions denied)', () {
    testWidgets('user can go from first launch to adding a note with every permission denied',
        (tester) async {
      final db = AppDatabase.inMemory();
      final bridge = _FakeSetupBridge(SetupCapabilityState.allDenied);
      final fixedNow = DateTime(2026, 11, 27, 10, 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => fixedNow),
            outboxPlatformClientProvider.overrideWithValue(_FakeOutbox(smsPermission: false)),
            setupPlatformBridgeProvider.overrideWithValue(bridge),
          ],
          child: const PocketCrmV2App(enableBackgroundSync: false),
        ),
      );
      await tester.pumpAndSettle();

      // Starts on /setup -> tap "Do this later"
      expect(find.text('Finish setup'), findsOneWidget);
      await tester.tap(find.text('Do this later'));
      await tester.pumpAndSettle();

      // Today shows quiet "Finish setup" row because Contacts & Calls/SMS denied
      expect(find.text('Finish setup'), findsOneWidget);

      // Add a manual person in DB (simulating manual entry with no Contacts permission)
      await PeopleRepository(db).createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );
      await tester.pumpAndSettle();

      // Open Add sheet via Today FAB and save a note with every permission denied
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Choose Amara Okafor
      await tester.tap(find.text('Choose a person'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amara Okafor').first);
      await tester.pumpAndSettle();

      // Enter note text and save
      await tester.enterText(find.byType(TextField).first, 'Met at trade fair');
      await tester.pump();
      await tester.tap(find.text('Save note'));
      await tester.pumpAndSettle();

      final entries = await db.select(db.timelineEntries).get();
      expect(entries.length, 1);
      expect(entries.first.note, 'Met at trade fair');

      // Pump past the 5s undo snackbar and unmount cleanly so all Drift streams close
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });

    testWidgets('without SMS permission composer button reads Open in your SMS app',
        (tester) async {
      final db = AppDatabase.inMemory();
      late int cid;
      await tester.runAsync(() async {
        cid = await PeopleRepository(db).createPerson(
          displayName: 'Amara Okafor',
          phoneNumber: '+2348031234567',
        );
      });

      Uri? launched;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            outboxPlatformClientProvider.overrideWithValue(_FakeOutbox(smsPermission: false)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: NewMessageScreen(
              initialContactIds: {cid},
              initialBody: 'Hello Amara',
              onLaunchUri: (uri) async {
                launched = uri;
                return true;
              },
            ),
          ),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump();
      }

      expect(find.text('Open in your SMS app'), findsOneWidget);
      await tester.tap(find.text('Open in your SMS app'));
      await tester.pumpAndSettle();
      expect(launched?.scheme, 'sms');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
  });
}
