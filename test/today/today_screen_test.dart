import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/followups/data/followups_repository.dart';
import 'package:pocket_crm/features/history/data/history_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/today/ui/today_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

import 'cadence_and_notifications_test.dart';

final _fixedNow = DateTime(2026, 11, 26, 11, 0);

Widget _wrapToday(AppDatabase db) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => _fixedNow),
      notificationsBackendProvider.overrideWithValue(FakeNotificationsBackend()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TodayScreen(),
    ),
  );
}

Future<void> _pumpStream(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _disposeDb(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.runAsync(db.close);
}

void main() {
  testWidgets('Today shows prompt card, follow-ups, reconnect, and birthdays in Figma order',
      (tester) async {
    final db = AppDatabase.inMemory();
    final people = PeopleRepository(db);
    final followUps = FollowUpsRepository(db);
    final history = HistoryRepository(db);

    await tester.runAsync(() async {
      final amaraId = await people.createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
        company: 'Okafor Textiles',
      );
      // Unreviewed call 48 minutes ago -> Prompt card
      await db.into(db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(amaraId),
              type: 'call_outgoing',
              timestamp: DateTime(2026, 11, 26, 10, 12).millisecondsSinceEpoch,
              durationSeconds: const Value(240),
              source: const Value('device'),
            ),
          );
      // Due follow-up today at 15:00
      await followUps.createFollowUp(
        contactId: amaraId,
        title: 'Send revised pricing sheet',
        dueDateMs: DateTime(2026, 11, 26, 15, 0).millisecondsSinceEpoch,
      );

      // Overdue reconnect person (cadence 30 days, last spoke 6 weeks ago)
      final laylaId = await people.createPerson(
        displayName: 'Layla Haddad',
        phoneNumber: '+447400123456',
        company: 'Cedar Studio',
      );
      await people.setCadence(laylaId, 30);
      await history.addCall(
        contactId: laylaId,
        directionType: 'call_outgoing',
        timestamp: _fixedNow.subtract(const Duration(days: 42)).millisecondsSinceEpoch,
        durationSeconds: 300,
      );

      // Birthday on Saturday (2 days from Thursday 26 November -> 28 November)
      await people.createPerson(
        displayName: 'Priya Nair',
        phoneNumber: '+919876543210',
        birthday: '1991-11-28',
      );
    });

    await tester.pumpWidget(_wrapToday(db));
    await _pumpStream(tester);

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Thursday 26 November'), findsOneWidget);

    // 1. Prompt card
    expect(find.text('You spoke with Amara Okafor'), findsOneWidget);
    expect(find.text('Add note'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // 2. Follow-ups
    expect(find.text('Follow-ups · 1'), findsOneWidget);
    expect(find.text('Send revised pricing sheet'), findsOneWidget);

    // 3. Reconnect
    expect(find.text('Reconnect · 1'), findsOneWidget);
    expect(find.text('Layla Haddad'), findsOneWidget);
    expect(find.textContaining('Every month'), findsOneWidget);

    // 4. Coming up
    expect(find.text('Coming up · 1'), findsOneWidget);
    expect(find.text('Priya Nair'), findsOneWidget);
    expect(find.text('Birthday on Saturday'), findsOneWidget);

    // Order check: Prompt card above Follow-ups above Reconnect above Coming up
    final promptY = tester.getTopLeft(find.text('You spoke with Amara Okafor')).dy;
    final followUpY = tester.getTopLeft(find.text('Follow-ups · 1')).dy;
    final reconnectY = tester.getTopLeft(find.text('Reconnect · 1')).dy;
    final comingUpY = tester.getTopLeft(find.text('Coming up · 1')).dy;
    expect(promptY, lessThan(followUpY));
    expect(followUpY, lessThan(reconnectY));
    expect(reconnectY, lessThan(comingUpY));

    // Skip dismisses prompt card
    await tester.tap(find.text('Skip'));
    await _pumpStream(tester);
    expect(find.text('You spoke with Amara Okafor'), findsNothing);

    await _disposeDb(tester, db);
  });

  testWidgets('Today empty state shows All caught up with zero section headers', (tester) async {
    final db = AppDatabase.inMemory();
    await tester.runAsync(() async {
      await PeopleRepository(db).createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );
    });

    await tester.pumpWidget(_wrapToday(db));
    await _pumpStream(tester);

    expect(find.text('All caught up'), findsOneWidget);
    expect(find.text('Choose people to stay in touch with'), findsOneWidget);
    expect(find.text('Follow-ups'), findsNothing);
    expect(find.text('Reconnect'), findsNothing);
    expect(find.text('Coming up'), findsNothing);
    expect(find.text('Needs attention'), findsNothing);

    await _disposeDb(tester, db);
  });
}
