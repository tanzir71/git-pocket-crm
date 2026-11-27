import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/files/file_store.dart';
import 'package:pocket_crm/core/native/device_api.g.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/core/widgets/widgets.dart';
import 'package:pocket_crm/features/capture/data/capture_service.dart';
import 'package:pocket_crm/features/capture/ui/add_sheet.dart';
import 'package:pocket_crm/features/capture/ui/after_call_sheet.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/features/people/ui/person_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

final _fixedNow = DateTime(2026, 11, 26, 14, 0);

class _FakeCaptureAdapter implements CapturePlatformAdapter {
  _FakeCaptureAdapter({
    this.imageQueue = const [],
  });

  final List<String> imageQueue;
  int _imgIndex = 0;
  String? lastAfterCallMode;

  @override
  Future<String?> pickImage({required bool fromCamera}) async {
    if (_imgIndex >= imageQueue.length) return null;
    return imageQueue[_imgIndex++];
  }

  @override
  Future<String?> pickFile() async => null;

  @override
  Future<LocationPoint?> currentLocation() async => null;

  @override
  Future<void> setAfterCallMode(String mode) async {
    lastAfterCallMode = mode;
  }
}

Future<void> _disposeDb(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.runAsync(db.close);
}

void main() {
  testWidgets(
      'Add visit with note, 2 photos, and follow-up in 3 days saves atomically and updates last_interaction_at',
      (tester) async {
    final db = AppDatabase.inMemory();
    final tmpDir = Directory.systemTemp.createTempSync('pcrm_spec07_');
    addTearDown(() {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    });
    final photo1 = File(p.join(tmpDir.path, 'roll1.jpg'))..writeAsBytesSync([1, 2, 3]);
    final photo2 = File(p.join(tmpDir.path, 'roll2.jpg'))..writeAsBytesSync([4, 5, 6]);

    final fileStore = FileStore(baseDirProvider: () async => tmpDir);
    final adapter = _FakeCaptureAdapter(imageQueue: [photo1.path, photo2.path]);

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

    CaptureUndoToken? savedToken;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => _fixedNow),
          fileStoreProvider.overrideWithValue(fileStore),
          capturePlatformAdapterProvider.overrideWithValue(adapter),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  savedToken = await showAddSheet(
                    ctx,
                    fixedPerson: amara,
                    initialType: AddEntryType.visit,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Place prefilled with "Okafor Textiles, Lagos"
    expect(find.text('Okafor Textiles, Lagos'), findsOneWidget);

    // Enter note
    await tester.enterText(
      find.widgetWithText(TextField, 'Write a note'),
      'Checked winter indigo dye quality.',
    );
    await tester.pump();

    // Add 2 photos via Gallery button
    await tester.ensureVisible(find.text('Gallery'));
    await tester.tap(find.text('Gallery'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    await tester.tap(find.text('Gallery'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    expect(find.text('2 photos'), findsOneWidget);

    // Pick follow-up "In 3 days"
    await tester.ensureVisible(find.text('In 3 days'));
    await tester.tap(find.text('In 3 days'));
    await tester.pump();

    // Save visit
    expect(find.text('Save visit'), findsOneWidget);
    final saveBtn = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Save visit'));
    expect(saveBtn.onPressed, isNotNull);
    await tester.tap(find.text('Save visit'));
    // Flush multi-hop dart:io (File.exists/create/copy for 2 photos) + Drift txn
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
      if (savedToken != null) break;
    }
    await tester.pumpAndSettle();

    expect(savedToken, isNotNull);

    // Assert DB state
    final visits = await tester.runAsync(
      () => (db.select(db.timelineEntries)..where((t) => t.type.equals('visit'))).get(),
    );
    expect(visits!.length, 1);
    expect(visits.first.placeName, 'Okafor Textiles, Lagos');
    expect(visits.first.note, 'Checked winter indigo dye quality.');

    final attachments = await tester.runAsync(() => db.select(db.timelineAttachments).get());
    expect(attachments!.length, 2);
    expect(attachments.every((a) => a.timelineId == visits.first.id), isTrue);

    final tasks = await tester.runAsync(() => db.select(db.tasks).get());
    expect(tasks!.length, 1);
    expect(tasks.first.sourceTimelineId, visits.first.id);
    expect(
      tasks.first.dueDate,
      DateTime(2026, 11, 29, 9, 0).millisecondsSinceEpoch,
    );

    final updatedContact = await tester.runAsync(
      () => PeopleRepository(db).getById(amara.id),
    );
    expect(updatedContact!.lastInteractionAt, _fixedNow.millisecondsSinceEpoch);

    // Undo reverses the entire transaction cleanly
    await tester.runAsync(() async {
      await CaptureService(db: db, fileStore: fileStore, clock: () => _fixedNow)
          .undo(savedToken!);
    });

    final visitsAfter = await tester.runAsync(() => db.select(db.timelineEntries).get());
    final attachmentsAfter = await tester.runAsync(() => db.select(db.timelineAttachments).get());
    final tasksAfter = await tester.runAsync(() => db.select(db.tasks).get());
    final contactAfter = await tester.runAsync(() => PeopleRepository(db).getById(amara.id));
    expect(visitsAfter, isEmpty);
    expect(attachmentsAfter, isEmpty);
    expect(tasksAfter, isEmpty);
    expect(contactAfter!.lastInteractionAt, isNull);

    await _disposeDb(tester, db);
  });

  testWidgets(
      'After-call sheet with No answer updates call row in place and creates tomorrow callback task',
      (tester) async {
    final db = AppDatabase.inMemory();
    late Contact amara;
    late TimelineEntry callEntry;

    await tester.runAsync(() async {
      final id = await PeopleRepository(db).createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );
      amara = (await PeopleRepository(db).getById(id))!;
      final callId = await db.into(db.timelineEntries).insert(
            TimelineEntriesCompanion.insert(
              contactId: Value(id),
              type: 'call_outgoing',
              timestamp: _fixedNow.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch,
              durationSeconds: const Value(30),
              source: const Value('device'),
            ),
          );
      callEntry = (await (db.select(db.timelineEntries)..where((t) => t.id.equals(callId)))
          .getSingle());
    });

    await tester.pumpWidget(
      ProviderScope(
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
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => showAfterCallSheet(
                  ctx,
                  contact: amara,
                  callEntry: callEntry,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Tap "No answer" -> preselects Tomorrow & "Call Amara back"
    await tester.tap(find.text('No answer'));
    await tester.pump();
    expect(find.text('Call Amara back'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // Verify zero duplicate timeline rows, existing call updated with outcome = no_answer
    final allTimeline = await tester.runAsync(() => db.select(db.timelineEntries).get());
    expect(allTimeline!.length, 1);
    expect(allTimeline.first.id, callEntry.id);
    expect(allTimeline.first.outcome, 'no_answer');
    expect(allTimeline.first.reviewedAt, isNotNull);

    final tasks = await tester.runAsync(() => db.select(db.tasks).get());
    expect(tasks!.length, 1);
    expect(tasks.first.title, 'Call Amara back');
    expect(tasks.first.dueDate, DateTime(2026, 11, 27, 9, 0).millisecondsSinceEpoch);

    await _disposeDb(tester, db);
  });

  testWidgets('3-interaction note capture from Person screen: open, type, save', (tester) async {
    final db = AppDatabase.inMemory();
    late int contactId;
    await tester.runAsync(() async {
      contactId = await PeopleRepository(db).createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
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
          home: PersonScreen(contactId: contactId, onLaunchUri: (_) async => true),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
    await tester.pumpAndSettle();

    // Interaction 1: tap floating button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Interaction 2: type a one-line note (Note is default & autofocused)
    await tester.enterText(find.widgetWithText(TextField, 'Write a note'), 'Prefers WhatsApp.');
    await tester.pump();

    // Interaction 3: tap Save note
    await tester.tap(find.text('Save note'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
    await tester.pumpAndSettle();

    expect(find.text('Prefers WhatsApp.'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await _disposeDb(tester, db);
  });
}
