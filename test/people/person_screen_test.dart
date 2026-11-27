import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/history/data/history_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/people/ui/person_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

final _fixedNow = DateTime(2026, 11, 26, 14, 0);

Widget _wrapPerson(AppDatabase db, int contactId) {
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
      home: PersonScreen(
        contactId: contactId,
        onLaunchUri: (_) async => true,
      ),
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
  testWidgets(
      'Person: call note, visit place & photos, and confirming suggested payment updates balance',
      (tester) async {
    final db = AppDatabase.inMemory();
    final people = PeopleRepository(db);
    final history = HistoryRepository(db);

    late int contactId;
    await tester.runAsync(() async {
      contactId = await people.createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
        company: 'Okafor Textiles',
        city: 'Lagos',
        isMobile: true,
      );

      // Call with a note
      await history.addCall(
        contactId: contactId,
        directionType: 'call_outgoing',
        timestamp: DateTime(2026, 11, 26, 10, 12).millisecondsSinceEpoch,
        durationSeconds: 240,
        note: 'Agreed on revised cotton pricing for December.',
      );

      // Visit with place and 2 photos
      await history.addVisit(
        contactId: contactId,
        placeName: 'Okafor Textiles warehouse',
        timestamp: DateTime(2026, 11, 24, 15, 30).millisecondsSinceEpoch,
        note: 'Reviewed sample rolls.',
        attachmentPaths: const ['/tmp/photo1.jpg', '/tmp/photo2.jpg'],
      );

      // Incoming SMS with suggested amount = 500
      await db.into(db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(contactId),
              type: 'sms_incoming',
              timestamp: DateTime(2026, 11, 25, 11, 0).millisecondsSinceEpoch,
              content: const Value('I will pay \$500 on Friday'),
              suggestedAmount: const Value(500.0),
              suggestionState: const Value('open'),
              source: const Value('device'),
            ),
          );
    });

    await tester.pumpWidget(_wrapPerson(db, contactId));
    await _pumpStream(tester);

    // Identity & actions (WhatsApp visible because mobile)
    expect(find.text('Amara Okafor'), findsOneWidget);
    expect(find.text('Okafor Textiles · Lagos'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);

    // Call with note
    expect(find.text('Outgoing call · 4 min'), findsOneWidget);
    expect(find.text('Agreed on revised cotton pricing for December.'), findsOneWidget);

    // Visit with place & photo count
    expect(find.text('Visit · Okafor Textiles warehouse'), findsOneWidget);
    expect(find.textContaining('2 photos'), findsOneWidget);

    // Suggested payment row visible, balance row NOT yet shown
    expect(find.text('Looks like a payment · \$500'), findsOneWidget);
    expect(find.text('Owes you \$500'), findsNothing);

    // Confirm suggested payment as "Owes me"
    await tester.ensureVisible(find.text('Confirm'));
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm payment'), findsOneWidget);
    await tester.tap(find.text('Owes me'));
    await tester.pumpAndSettle();
    await _pumpStream(tester);

    // Balance row appears and payment entry created
    expect(find.text('Owes you \$500'), findsOneWidget);
    expect(find.text('Looks like a payment · \$500'), findsNothing);

    final paymentRows = await tester.runAsync(
      () => (db.select(db.timelineEntries)..where((t) => t.type.equals('payment'))).get(),
    );
    expect(paymentRows!.length, 1);
    expect(paymentRows.first.paymentStatus, 'owed_to_me');
    expect(paymentRows.first.amount, 500.0);

    await _disposeDb(tester, db);
  });

  testWidgets('Person: non-mobile primary number hides WhatsApp action tile', (tester) async {
    final db = AppDatabase.inMemory();
    final people = PeopleRepository(db);

    late int contactId;
    await tester.runAsync(() async {
      contactId = await people.createPerson(
        displayName: 'London Office',
        phoneNumber: '+442079460123',
        isMobile: false,
      );
    });

    await tester.pumpWidget(_wrapPerson(db, contactId));
    await _pumpStream(tester);

    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('WhatsApp'), findsNothing);

    await _disposeDb(tester, db);
  });
}
