import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/database_helper.dart';
import 'package:pocket_crm/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Preload bundled Inter variants into google_fonts' cache so legacy
    // HomeScreen does not emit an async systemFonts notification after teardown.
    GoogleFonts.inter();
    GoogleFonts.inter(fontWeight: FontWeight.w500);
    GoogleFonts.inter(fontWeight: FontWeight.w600);
    await GoogleFonts.pendingFonts();
  });

  testWidgets('PocketCRMApp smoke test', (WidgetTester tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(() async {
      DatabaseHelper.testAppDatabase = null;
      await db.close();
    });
    DatabaseHelper.testAppDatabase = db;

    await tester.pumpWidget(const PocketCRMApp());
    expect(find.text('PocketCRM'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
