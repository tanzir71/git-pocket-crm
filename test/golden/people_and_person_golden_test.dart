import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/followups/data/followups_repository.dart';
import 'package:pocket_crm/features/history/data/history_repository.dart';
import 'package:pocket_crm/features/payments/data/payments_repository.dart';
import 'package:pocket_crm/features/people/data/lists_repository.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/people/ui/people_screen.dart';
import 'package:pocket_crm/features/people/ui/person_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

final _fixedNow = DateTime(2026, 11, 26, 14, 0);

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

Future<int> _seedFigmaSampleData(AppDatabase db) async {
  final people = PeopleRepository(db);
  final lists = ListsRepository(db);
  final history = HistoryRepository(db);
  final payments = PaymentsRepository(db);
  final followUps = FollowUpsRepository(db);

  final customersId = await lists.createList('Customers', cadenceDays: 14);
  final suppliersId = await lists.createList('Suppliers');
  final friendsId = await lists.createList('Friends');

  final amaraId = await people.createPerson(
    displayName: 'Amara Okafor',
    phoneNumber: '+2348031234567',
    company: 'Okafor Textiles',
    city: 'Lagos',
    isMobile: true,
  );
  await people.setCadence(amaraId, 14);
  await people.toggleStar(amaraId);
  await lists.addMember(customersId, amaraId);

  await followUps.createFollowUp(
    contactId: amaraId,
    title: 'Send revised pricing sheet',
    dueDateMs: DateTime(2026, 11, 26, 15, 0).millisecondsSinceEpoch,
  );
  await payments.addPayment(
    contactId: amaraId,
    amount: 240,
    paymentStatus: 'owed_to_me',
    note: 'October fabric shipment',
    timestamp: DateTime(2026, 11, 20, 11, 0).millisecondsSinceEpoch,
  );
  await history.addCall(
    contactId: amaraId,
    directionType: 'call_outgoing',
    timestamp: DateTime(2026, 11, 26, 10, 12).millisecondsSinceEpoch,
    durationSeconds: 240,
    note: 'Confirmed 40 rolls for next Tuesday. Send updated invoice.',
  );
  await history.addVisit(
    contactId: amaraId,
    placeName: 'Okafor Textiles warehouse',
    timestamp: DateTime(2026, 11, 22, 15, 0).millisecondsSinceEpoch,
    note: 'Checked quality of the autumn indigo weave.',
    attachmentPaths: const ['/tmp/sample_1.jpg', '/tmp/sample_2.jpg'],
  );
  await history.addCall(
    contactId: amaraId,
    directionType: 'call_incoming',
    timestamp: DateTime(2026, 10, 18, 11, 20).millisecondsSinceEpoch,
    durationSeconds: 120,
    note: 'Asked about bulk winter discount.',
  );

  final priyaId = await people.createPerson(
    displayName: 'Priya Nair',
    phoneNumber: '+919876543210',
    company: 'Nair Logistics',
    city: 'Mumbai',
  );
  await lists.addMember(suppliersId, priyaId);
  await history.addCall(
    contactId: priyaId,
    directionType: 'call_incoming',
    timestamp: DateTime(2026, 11, 25, 16, 0).millisecondsSinceEpoch,
    durationSeconds: 180,
  );

  final danielId = await people.createPerson(
    displayName: 'Daniel Reyes',
    phoneNumber: '+14155550199',
    company: 'Reyes Import',
    city: 'Austin',
  );
  await lists.addMember(customersId, danielId);
  await followUps.createFollowUp(
    contactId: danielId,
    title: 'Confirm customs clearance',
    dueDateMs: DateTime(2026, 11, 25, 10, 0).millisecondsSinceEpoch,
  );
  await history.addVisit(
    contactId: danielId,
    placeName: 'Reyes depot',
    timestamp: DateTime(2026, 11, 23, 12, 0).millisecondsSinceEpoch,
  );

  final tanvirId = await people.createPerson(
    displayName: 'Tanvir Hasan',
    phoneNumber: '+8801712345678',
    company: 'Padma Trading',
    city: 'Dhaka',
  );
  await lists.addMember(customersId, tanvirId);
  await history.addCall(
    contactId: tanvirId,
    directionType: 'call_outgoing',
    timestamp: DateTime(2026, 11, 14, 9, 30).millisecondsSinceEpoch,
    durationSeconds: 300,
  );

  final laylaId = await people.createPerson(
    displayName: 'Layla Haddad',
    phoneNumber: '+447400123456',
    company: 'Cedar Studio',
    city: 'London',
  );
  await lists.addMember(friendsId, laylaId);
  await history.addCall(
    contactId: laylaId,
    directionType: 'call_outgoing',
    timestamp: DateTime(2026, 10, 15, 18, 0).millisecondsSinceEpoch,
    durationSeconds: 600,
  );

  return amaraId;
}

Widget _wrapForGolden({
  required AppDatabase db,
  required ThemeData theme,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => _fixedNow),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    await _loadBundledInter();
  });

  for (final (mode, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    testWidgets('golden: people_$mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 917));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final db = AppDatabase.inMemory();
      await tester.runAsync(() => _seedFigmaSampleData(db));

      await tester.pumpWidget(
        _wrapForGolden(db: db, theme: theme, child: const PeopleScreen()),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/people_$mode.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });

    testWidgets('golden: person_$mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 917));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final db = AppDatabase.inMemory();
      final amaraId = (await tester.runAsync(() => _seedFigmaSampleData(db)))!;

      await tester.pumpWidget(
        _wrapForGolden(
          db: db,
          theme: theme,
          child: PersonScreen(contactId: amaraId, onLaunchUri: (_) async => true),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/person_$mode.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });
  }
}
