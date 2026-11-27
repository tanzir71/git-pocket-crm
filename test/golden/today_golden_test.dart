import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
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

import '../today/cadence_and_notifications_test.dart';

final _fixedNow = DateTime(2026, 11, 26, 11, 0);

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

Future<void> _seedTodaySample(AppDatabase db) async {
  final people = PeopleRepository(db);
  final followUps = FollowUpsRepository(db);
  final history = HistoryRepository(db);

  final amaraId = await people.createPerson(
    displayName: 'Amara Okafor',
    phoneNumber: '+2348031234567',
    company: 'Okafor Textiles',
  );
  await db.into(db.timelineEntries).insert(
        TimelineEntriesCompanion.insert(
          contactId: Value(amaraId),
          type: 'call_outgoing',
          timestamp: DateTime(2026, 11, 26, 10, 12).millisecondsSinceEpoch,
          durationSeconds: const Value(240),
          source: const Value('device'),
        ),
      );
  await followUps.createFollowUp(
    contactId: amaraId,
    title: 'Send revised pricing sheet',
    dueDateMs: DateTime(2026, 11, 26, 15, 0).millisecondsSinceEpoch,
  );

  final danielId = await people.createPerson(
    displayName: 'Daniel Reyes',
    phoneNumber: '+14155550199',
    company: 'Reyes Import',
  );
  await followUps.createFollowUp(
    contactId: danielId,
    title: 'Confirm customs clearance',
    dueDateMs: DateTime(2026, 11, 25, 10, 0).millisecondsSinceEpoch,
  );

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

  final tanvirId = await people.createPerson(
    displayName: 'Tanvir Hasan',
    phoneNumber: '+8801712345678',
    company: 'Padma Trading',
  );
  await people.setCadence(tanvirId, 14);
  await history.addCall(
    contactId: tanvirId,
    directionType: 'call_incoming',
    timestamp: _fixedNow.subtract(const Duration(days: 19)).millisecondsSinceEpoch,
    durationSeconds: 180,
  );

  await people.createPerson(
    displayName: 'Priya Nair',
    phoneNumber: '+919876543210',
    company: 'Nair Logistics',
    birthday: '1991-11-28',
  );
}

void main() {
  setUpAll(() async {
    await _loadBundledInter();
  });

  for (final (mode, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    testWidgets('golden: today_$mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 917));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final db = AppDatabase.inMemory();
      await tester.runAsync(() => _seedTodaySample(db));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => _fixedNow),
            notificationsBackendProvider.overrideWithValue(FakeNotificationsBackend()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TodayScreen(),
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_$mode.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });
  }
}
