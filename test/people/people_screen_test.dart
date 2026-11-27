import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_colors.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/followups/data/followups_repository.dart';
import 'package:pocket_crm/features/history/data/history_repository.dart';
import 'package:pocket_crm/features/payments/data/payments_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/people/ui/people_screen.dart';
import 'package:pocket_crm/features/sync/data/sync_state_repository.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

final _fixedNow = DateTime(2026, 11, 26, 14, 0);

Widget _wrapPeople(AppDatabase db, {VoidCallback? onRowBuilt}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => _fixedNow),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: PeopleScreen(onRowBuilt: onRowBuilt),
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
  testWidgets('People: search by partial phone, Owes me chip, and overdue danger meta',
      (tester) async {
    final db = AppDatabase.inMemory();
    final people = PeopleRepository(db);
    final payments = PaymentsRepository(db);
    final followUps = FollowUpsRepository(db);
    final history = HistoryRepository(db);

    await tester.runAsync(() async {
      final amaraId = await people.createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
        company: 'Okafor Textiles',
      );
      final priyaId = await people.createPerson(
        displayName: 'Priya Nair',
        phoneNumber: '+919876543210',
        company: 'Nair Logistics',
      );
      final danielId = await people.createPerson(
        displayName: 'Daniel Reyes',
        phoneNumber: '+14155550199',
        company: 'Reyes Import',
      );

      // Amara owes $240
      await payments.addPayment(
        contactId: amaraId,
        amount: 240,
        paymentStatus: 'owed_to_me',
        note: 'October fabric shipment',
        timestamp: _fixedNow.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      );

      // Priya owed $100 and paid $100 -> $0 net balance (must NOT show in Owes me)
      await payments.addPayment(
        contactId: priyaId,
        amount: 100,
        paymentStatus: 'owed_to_me',
        timestamp: _fixedNow.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
      );
      await payments.addPayment(
        contactId: priyaId,
        amount: 100,
        paymentStatus: 'received',
        timestamp: _fixedNow.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
      );

      // Daniel has an overdue follow-up (yesterday) and I owe him $50
      await followUps.createFollowUp(
        contactId: danielId,
        title: 'Send revised quote',
        dueDateMs: _fixedNow.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await payments.addPayment(
        contactId: danielId,
        amount: 50,
        paymentStatus: 'i_owe',
        timestamp: _fixedNow.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );

      await history.addCall(
        contactId: amaraId,
        directionType: 'call_outgoing',
        timestamp: _fixedNow.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
        durationSeconds: 240,
      );
    });

    await tester.pumpWidget(_wrapPeople(db));
    await _pumpStream(tester);

    expect(find.text('Amara Okafor'), findsOneWidget);
    expect(find.text('Priya Nair'), findsOneWidget);
    expect(find.text('Daniel Reyes'), findsOneWidget);

    // Overdue person shows danger meta
    final overdueFinder = find.text('Reyes Import · follow-up overdue');
    expect(overdueFinder, findsOneWidget);
    final overdueText = tester.widget<Text>(overdueFinder);
    expect(overdueText.style?.color, AppColors.light.statusDanger);

    // Tap "Owes me" chip -> ONLY Amara Okafor appears
    await tester.tap(find.text('Owes me'));
    await _pumpStream(tester);
    expect(find.text('Amara Okafor'), findsOneWidget);
    expect(find.text('Priya Nair'), findsNothing);
    expect(find.text('Daniel Reyes'), findsNothing);

    // Return to All and search by partial phone number ("543210") -> finds Priya Nair
    await tester.tap(find.text('All'));
    await _pumpStream(tester);
    await tester.enterText(find.byType(TextField), '543210');
    await tester.pump(const Duration(milliseconds: 200)); // debounce 150ms
    await _pumpStream(tester);

    expect(find.text('Priya Nair'), findsOneWidget);
    expect(find.text('Amara Okafor'), findsNothing);
    expect(find.text('Daniel Reyes'), findsNothing);

    await _disposeDb(tester, db);
  });

  testWidgets('People: 5,000 rows only builds visible items when rendered and scrolled',
      (tester) async {
    final db = AppDatabase.inMemory();
    await tester.runAsync(() async {
      final nowMs = _fixedNow.millisecondsSinceEpoch;
      await db.batch((b) {
        b.insertAll(
          db.contacts,
          List.generate(
            5000,
            (i) => ContactsCompanion.insert(
              displayName: 'Contact ${i.toString().padLeft(4, '0')}',
              phoneNumber: Value('+14155${i.toString().padLeft(6, '0')}'),
              company: Value('Company $i'),
              lastInteractionAt: Value(nowMs - i * 60000),
              createdAt: Value(nowMs - i * 60000),
            ),
          ),
        );
      });
    });

    int builtRows = 0;
    await tester.pumpWidget(_wrapPeople(db, onRowBuilt: () => builtRows++));
    await _pumpStream(tester);

    expect(find.text('5000 people'), findsOneWidget);
    expect(builtRows, greaterThan(0));
    expect(builtRows, lessThan(40));

    final initialBuilt = builtRows;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(builtRows, greaterThan(initialBuilt));
    expect(builtRows, lessThan(80));

    await _disposeDb(tester, db);
  });

  testWidgets('People: merge suggestion merges two people in one transaction', (tester) async {
    final db = AppDatabase.inMemory();
    final people = PeopleRepository(db);
    final history = HistoryRepository(db);
    final syncState = SyncStateRepository(db);

    late int idA;
    late int idB;
    await tester.runAsync(() async {
      idA = await people.createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
        company: 'Okafor Textiles',
      );
      idB = await people.createPerson(
        displayName: 'Amara Work',
        phoneNumber: '0803 123 4567',
      );
      await history.addNote(contactId: idA, note: 'Primary note');
      await history.addNote(contactId: idB, note: 'Secondary note');
      await syncState.set(
        'merge_suggestions',
        jsonEncode([
          {'contactIdA': idA, 'contactIdB': idB, 'e164': '+2348031234567'},
        ]),
      );
    });

    await tester.pumpWidget(_wrapPeople(db));
    await _pumpStream(tester);

    expect(find.text('Amara Okafor and Amara Work share a number'), findsOneWidget);
    await tester.tap(find.text('Merge'));
    await _pumpStream(tester);

    final remaining = await tester.runAsync(people.getAll);
    expect(remaining!.length, 1);
    final entries = await tester.runAsync(
      () => (db.select(db.timelineEntries)).get(),
    );
    expect(entries!.length, 2);
    expect(entries.every((e) => e.contactId == remaining.first.id), isTrue);

    await _disposeDb(tester, db);
  });
}
