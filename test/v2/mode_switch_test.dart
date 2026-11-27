import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/config.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/database_helper.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!kV2) {
      GoogleFonts.inter();
      GoogleFonts.inter(fontWeight: FontWeight.w500);
      GoogleFonts.inter(fontWeight: FontWeight.w600);
      await GoogleFonts.pendingFonts();
    }
  });

  testWidgets('PocketCRMApp boots cleanly in active kV2=$kV2 mode', (tester) async {
    final db = AppDatabase.inMemory();
    DatabaseHelper.testAppDatabase = db;

    await tester.runAsync(() async {
      await PeopleRepository(db).createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+14155550101',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PocketCRMApp(),
      ),
    );

    if (kV2) {
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsAtLeastNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    } else {
      expect(find.text('PocketCRM'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }

    DatabaseHelper.testAppDatabase = null;
    await tester.runAsync(() => db.close());
  });
}
