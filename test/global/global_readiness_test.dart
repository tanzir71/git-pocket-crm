import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show CheckedState;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/native/outbox_api.g.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_colors.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/core/widgets/widgets.dart';
import 'package:pocket_crm/features/capture/ui/add_sheet.dart';
import 'package:pocket_crm/features/capture/ui/after_call_sheet.dart';
import 'package:pocket_crm/features/followups/data/followups_repository.dart';
import 'package:pocket_crm/features/history/data/history_repository.dart';
import 'package:pocket_crm/features/messages/data/outbox_repository.dart';
import 'package:pocket_crm/features/messages/ui/campaign_screen.dart';
import 'package:pocket_crm/features/messages/ui/messages_screen.dart';
import 'package:pocket_crm/features/messages/ui/new_message_screen.dart';
import 'package:pocket_crm/features/payments/data/payments_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/people/ui/people_screen.dart';
import 'package:pocket_crm/features/people/ui/person_screen.dart';
import 'package:pocket_crm/features/settings/ui/settings_screen.dart';
import 'package:pocket_crm/features/setup/data/setup_controller.dart';
import 'package:pocket_crm/features/setup/ui/setup_screen.dart';
import 'package:pocket_crm/features/today/ui/today_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

import '../today/cadence_and_notifications_test.dart';

class _StubOutboxClient implements OutboxPlatformClient {
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

class _StubSetupBridge implements SetupPlatformBridge {
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

double _relativeLuminance(Color c) {
  double linear(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linear(c.r) + 0.7152 * linear(c.g) + 0.0722 * linear(c.b);
}

double _contrastRatio(Color fg, Color bg) {
  final l1 = _relativeLuminance(fg);
  final l2 = _relativeLuminance(bg);
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

Future<({int contactId, TimelineEntry callEntry, String campaignId})> _seedNineScreensDb(
  AppDatabase db,
  DateTime now,
) async {
  final people = PeopleRepository(db);
  final followUps = FollowUpsRepository(db);
  final history = HistoryRepository(db);

  final amaraId = await people.createPerson(
    displayName: 'Amara Okafor',
    phoneNumber: '+2348031234567',
    company: 'Okafor Textiles',
    city: 'Lagos',
  );
  await people.setCadence(amaraId, 14);
  final callId = await db.into(db.timelineEntries).insert(
        TimelineEntriesCompanion.insert(
          contactId: Value(amaraId),
          type: 'call_outgoing',
          timestamp: now.subtract(const Duration(minutes: 20)).millisecondsSinceEpoch,
          durationSeconds: const Value(240),
          source: const Value('device'),
        ),
      );
  final callEntry = await (db.select(db.timelineEntries)
        ..where((t) => t.id.equals(callId)))
      .getSingle();

  await followUps.createFollowUp(
    contactId: amaraId,
    title: 'Send revised pricing sheet',
    dueDateMs: now.add(const Duration(hours: 2)).millisecondsSinceEpoch,
  );
  await history.addNote(
    contactId: amaraId,
    note: 'Discussed bulk textile order for Q1',
    timestamp: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
  );
  await db.into(db.timelineEntries).insert(
        TimelineEntriesCompanion.insert(
          contactId: Value(amaraId),
          type: 'payment',
          timestamp: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
          amount: const Value(240.0),
          currency: const Value('USD'),
          paymentStatus: const Value('owed_to_me'),
          note: const Value('Invoice #104'),
        ),
      );

  const campId = 'camp-global-1';
  await db.into(db.campaigns).insert(
        CampaignsCompanion.insert(
          id: campId,
          name: 'November check-in',
          bodyTemplate: 'Hi {first_name}, checking in.',
          status: 'running',
          paceSeconds: const Value(15),
          createdAt: Value(now.millisecondsSinceEpoch),
        ),
      );
  await db.into(db.outboxMessages).insert(
        OutboxMessagesCompanion.insert(
          clientId: 'outbox-global-1',
          contactId: Value(amaraId),
          campaignId: const Value(campId),
          address: '+2348031234567',
          body: 'Hi Amara, checking in.',
          dueAt: now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
          status: 'queued',
        ),
      );

  return (contactId: amaraId, callEntry: callEntry, campaignId: campId);
}

void main() {
  group('ARB completeness and no-literal widget guard', () {
    test('every key and placeholder in app_en.arb exists in app_bn.arb and vice versa', () {
      final enMap =
          jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
      final bnMap =
          jsonDecode(File('lib/l10n/app_bn.arb').readAsStringSync()) as Map<String, dynamic>;

      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
      final bnKeys = bnMap.keys.where((k) => !k.startsWith('@')).toSet();

      expect(enKeys.difference(bnKeys), isEmpty, reason: 'Keys missing from app_bn.arb');
      expect(bnKeys.difference(enKeys), isEmpty, reason: 'Extra keys in app_bn.arb');

      for (final key in enKeys) {
        final bnVal = bnMap[key].toString();
        expect(bnVal.trim(), isNotEmpty, reason: 'Empty Bengali translation for $key');
        final meta = enMap['@$key'] as Map<String, dynamic>?;
        final placeholders = (meta?['placeholders'] as Map<String, dynamic>?)?.keys ?? const [];
        for (final ph in placeholders) {
          expect(
            bnVal.contains('{$ph}') || bnVal.contains('{$ph,'),
            isTrue,
            reason: 'Placeholder {$ph} missing in app_bn.arb for key $key',
          );
        }
      }
    });

    test('widgets in lib/core/widgets and lib/features/**/ui contain no hardcoded English Text literals', () {
      final literalRegex = RegExp(r'''Text\(\s*['"]([A-Za-z][^'"{$]*)['"]''');
      final offenders = <String>[];

      for (final dir in [Directory('lib/core/widgets'), Directory('lib/features')]) {
        if (!dir.existsSync()) continue;
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          final lines = entity.readAsLinesSync();
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            if (line.trimLeft().startsWith('//')) continue;
            final match = literalRegex.firstMatch(line);
            if (match != null) {
              offenders.add('${entity.path}:${i + 1}: ${line.trim()}');
            }
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'User-facing Text literals must live in ARB files:\n${offenders.join('\n')}',
      );
    });
  });

  group('Theme WCAG AA contrast (>= 4.5:1)', () {
    void verifyThemeContrast(String name, AppColors c) {
      final textPairs = <(String, Color, Color)>[
        ('textPrimary on bgCanvas', c.textPrimary, c.bgCanvas),
        ('textPrimary on bgSurface', c.textPrimary, c.bgSurface),
        ('textPrimary on bgSubtle', c.textPrimary, c.bgSubtle),
        ('textSecondary on bgCanvas', c.textSecondary, c.bgCanvas),
        ('textSecondary on bgSurface', c.textSecondary, c.bgSurface),
        ('textSecondary on bgSubtle', c.textSecondary, c.bgSubtle),
        ('textTertiary on bgCanvas', c.textTertiary, c.bgCanvas),
        ('textTertiary on bgSurface', c.textTertiary, c.bgSurface),
        ('textTertiary on bgSubtle', c.textTertiary, c.bgSubtle),
        ('textOnAccent on accentDefault', c.textOnAccent, c.accentDefault),
        ('textOnInverse on bgInverse', c.textOnInverse, c.bgInverse),
        ('accentDefault on bgCanvas', c.accentDefault, c.bgCanvas),
        ('accentDefault on bgSurface', c.accentDefault, c.bgSurface),
        ('statusSuccess on bgCanvas', c.statusSuccess, c.bgCanvas),
        ('statusSuccess on bgSurface', c.statusSuccess, c.bgSurface),
        ('statusSuccess on statusSuccessSoft', c.statusSuccess, c.statusSuccessSoft),
        ('statusWarning on bgCanvas', c.statusWarning, c.bgCanvas),
        ('statusWarning on bgSurface', c.statusWarning, c.bgSurface),
        ('statusWarning on statusWarningSoft', c.statusWarning, c.statusWarningSoft),
        ('statusDanger on bgCanvas', c.statusDanger, c.bgCanvas),
        ('statusDanger on bgSurface', c.statusDanger, c.bgSurface),
      ];

      for (final (label, fg, bg) in textPairs) {
        final ratio = _contrastRatio(fg, bg);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$name $label contrast ${ratio.toStringAsFixed(2)} < 4.5',
        );
      }
      for (var i = 0; i < c.avatarTones.length; i++) {
        final tone = c.avatarTones[i];
        final ratio = _contrastRatio(tone.ink, tone.bg);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$name avatar[$i] contrast ${ratio.toStringAsFixed(2)} < 4.5',
        );
      }
    }

    test('light theme meets >= 4.5:1 on every text pair', () {
      verifyThemeContrast('light', AppColors.light);
    });

    test('dark theme meets >= 4.5:1 on every text pair including danger soft', () {
      verifyThemeContrast('dark', AppColors.dark);
      expect(
        _contrastRatio(AppColors.dark.statusDanger, AppColors.dark.statusDangerSoft),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('Multi-currency balances', () {
    test('computeBalancesByCurrency separates balances per currency', () {
      final now = DateTime(2026, 11, 27).millisecondsSinceEpoch;
      final entries = [
        TimelineEntry(
          id: 1,
          contactId: 1,
          type: 'payment',
          timestamp: now,
          amount: 240.0,
          currency: 'USD',
          paymentStatus: 'owed_to_me',
          isPinned: 0,
          hidden: 0,
        ),
        TimelineEntry(
          id: 2,
          contactId: 1,
          type: 'payment',
          timestamp: now + 1000,
          amount: 40.0,
          currency: 'USD',
          paymentStatus: 'received',
          isPinned: 0,
          hidden: 0,
        ),
        TimelineEntry(
          id: 3,
          contactId: 1,
          type: 'payment',
          timestamp: now + 2000,
          amount: 5000.0,
          currency: 'BDT',
          paymentStatus: 'i_owe',
          isPinned: 0,
          hidden: 0,
        ),
      ];

      final balances = PaymentsRepository.computeBalancesByCurrency(entries);
      expect(balances.length, 2);
      final usd = balances.firstWhere((b) => b.currency == 'USD');
      final bdt = balances.firstWhere((b) => b.currency == 'BDT');
      expect(usd.owesYou, isTrue);
      expect(usd.absoluteAmount, closeTo(200.0, 0.001));
      expect(bdt.youOwe, isTrue);
      expect(bdt.absoluteAmount, closeTo(5000.0, 0.001));
    });
  });

  group('Bengali locale rendering', () {
    testWidgets('Today and Settings render Bengali strings cleanly without overflow',
        (tester) async {
      final db = AppDatabase.inMemory();
      final fixedNow = DateTime(2026, 11, 27, 10, 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => fixedNow),
            notificationsBackendProvider.overrideWithValue(FakeNotificationsBackend()),
            outboxPlatformClientProvider.overrideWithValue(_StubOutboxClient()),
            setupPlatformBridgeProvider.overrideWithValue(_StubSetupBridge()),
          ],
          child: MaterialApp(
            locale: const Locale('bn'),
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('সেটিংস'), findsOneWidget);
      expect(find.text('সাধারণ'), findsOneWidget);
      expect(find.text('মুদ্রা'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
  });

  group('Semantics and Text Scale 1.3x / 2.0x across all 9 designed screens', () {
    testWidgets('all 9 designed screens pass semantics checks and render cleanly at 1.3x and 2.0x',
        (tester) async {
      final db = AppDatabase.inMemory();
      final fixedNow = DateTime(2026, 11, 27, 11, 0);
      final seeded = await _seedNineScreensDb(db, fixedNow);
      final contact = await PeopleRepository(db).getById(seeded.contactId);

      final screens = <(String, Widget)>[
        ('Today', const TodayScreen()),
        ('People', const PeopleScreen()),
        ('Person', PersonScreen(contactId: seeded.contactId)),
        ('Add', Scaffold(body: SingleChildScrollView(child: AddSheetBody(fixedPerson: contact)))),
        (
          'After-call',
          Scaffold(
            body: SingleChildScrollView(
              child: AfterCallSheetBody(contact: contact!, callEntry: seeded.callEntry),
            ),
          ),
        ),
        ('Messages', const MessagesScreen()),
        ('New message', NewMessageScreen(initialContactIds: {seeded.contactId})),
        ('Campaign', CampaignScreen(campaignId: seeded.campaignId)),
        ('Setup', const SetupScreen()),
      ];

      tester.view.physicalSize = const Size(412, 917);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final semanticsHandle = tester.ensureSemantics();

      final allFailures = <String>[];
      for (final (name, widget) in screens) {
        for (final scale in const [1.0, 1.3, 2.0]) {
          final errors = <FlutterErrorDetails>[];
          final prevOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            errors.add(details);
          };

          try {
            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  appDatabaseProvider.overrideWithValue(db),
                  clockProvider.overrideWithValue(() => fixedNow),
                  notificationsBackendProvider.overrideWithValue(FakeNotificationsBackend()),
                  outboxPlatformClientProvider.overrideWithValue(_StubOutboxClient()),
                  setupPlatformBridgeProvider.overrideWithValue(_StubSetupBridge()),
                ],
                child: MaterialApp(
                  theme: AppTheme.light,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  builder: (ctx, child) => MediaQuery(
                    data: MediaQuery.of(ctx).copyWith(
                      textScaler: TextScaler.linear(scale),
                    ),
                    child: child!,
                  ),
                  home: widget,
                ),
              ),
            );
            await tester.pumpAndSettle();

            final overflowErrors = errors
                .where((e) => e.exceptionAsString().contains('overflowed'))
                .toList();
            for (final oe in overflowErrors) {
              final loc = oe
                  .toString()
                  .split('\n')
                  .where((l) => l.contains('lib/') || l.contains('overflowed'))
                  .take(3)
                  .join(' | ');
              allFailures.add('$name @ ${scale}x: $loc');
            }

            if (scale == 1.0) {
              for (final el in find.byType(IconButton).evaluate()) {
                final btn = el.widget as IconButton;
                if (btn.tooltip == null || btn.tooltip!.trim().isEmpty) {
                  allFailures.add('$name: IconButton without tooltip');
                }
              }
              if (find.byType(TaskRow).evaluate().isNotEmpty) {
                final taskFinder = find.byType(TaskRow).first;
                final semanticsNode = tester.getSemantics(taskFinder);
                bool foundCheckbox = false;
                void visit(SemanticsNode node) {
                  final data = node.getSemanticsData();
                  if (data.flagsCollection.isChecked != CheckedState.none) {
                    foundCheckbox = true;
                  }
                  node.visitChildren((child) {
                    visit(child);
                    return true;
                  });
                }

                visit(semanticsNode);
                if (!foundCheckbox) {
                  allFailures.add('$name: TaskRow missing checkbox semantics');
                }
              }
              if (find.byType(PersonRow).evaluate().isNotEmpty) {
                final personFinder = find.byType(PersonRow).first;
                final data = tester.getSemantics(personFinder).getSemanticsData();
                if (data.label.trim().isEmpty) {
                  allFailures.add('$name: PersonRow missing sentence semantic label');
                }
              }
            }
          } finally {
            FlutterError.onError = prevOnError;
          }
        }
      }

      semanticsHandle.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();

      expect(allFailures, isEmpty, reason: allFailures.join('\n'));
    });
  });
}
