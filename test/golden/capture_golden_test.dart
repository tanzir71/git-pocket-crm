import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_colors.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/core/theme/tokens.dart';
import 'package:pocket_crm/features/capture/data/capture_service.dart';
import 'package:pocket_crm/features/capture/ui/add_sheet.dart';
import 'package:pocket_crm/features/capture/ui/after_call_sheet.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
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

Widget _wrapSheetSurface({
  required AppDatabase db,
  required ThemeData theme,
  required Widget sheetBody,
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
      home: Builder(
        builder: (context) {
          final c = context.colors;
          return Scaffold(
            backgroundColor: c.scrim,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: c.bgSurface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTokens.radiusSheetTop),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppTokens.space12, bottom: AppTokens.space4),
                      child: Container(
                        width: AppTokens.sheetHandleWidth,
                        height: AppTokens.sheetHandleHeight,
                        decoration: BoxDecoration(
                          color: c.borderStrong,
                          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                        ),
                      ),
                    ),
                    sheetBody,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await _loadBundledInter();
  });

  for (final (mode, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    testWidgets('golden: add_visit_$mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 917));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final db = AppDatabase.inMemory();
      late Contact amara;
      await tester.runAsync(() async {
        final id = await PeopleRepository(db).createPerson(
          displayName: 'Amara Okafor',
          phoneNumber: '+2348031234567',
          company: 'Okafor Textiles',
          city: 'Lagos',
        );
        amara = (await PeopleRepository(db).getById(id))!;
      });

      await tester.pumpWidget(
        _wrapSheetSurface(
          db: db,
          theme: theme,
          sheetBody: AddSheetBody(
            fixedPerson: amara,
            initialType: AddEntryType.visit,
            initialPhotos: const ['/tmp/p1.jpg', '/tmp/p2.jpg'],
            initialFollowUpPreset: 3,
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/add_visit_$mode.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });

    testWidgets('golden: after_call_$mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 917));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final db = AppDatabase.inMemory();
      late Contact amara;
      late TimelineEntry callEntry;
      await tester.runAsync(() async {
        final id = await PeopleRepository(db).createPerson(
          displayName: 'Amara Okafor',
          phoneNumber: '+2348031234567',
          company: 'Okafor Textiles',
          city: 'Lagos',
        );
        amara = (await PeopleRepository(db).getById(id))!;
        final callId = await db.into(db.timelineEntries).insert(
              TimelineEntriesCompanion.insert(
                contactId: Value(id),
                type: 'call_outgoing',
                timestamp: _fixedNow.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
                durationSeconds: const Value(240),
                source: const Value('device'),
              ),
            );
        callEntry = await (db.select(db.timelineEntries)..where((t) => t.id.equals(callId)))
            .getSingle();
      });

      await tester.pumpWidget(
        _wrapSheetSurface(
          db: db,
          theme: theme,
          sheetBody: AfterCallSheetBody(
            contact: amara,
            callEntry: callEntry,
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/after_call_$mode.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });
  }
}
