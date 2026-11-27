import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/database_helper.dart';
import 'package:pocket_crm/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PocketCRMApp smoke test', (WidgetTester tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(() async {
      DatabaseHelper.testAppDatabase = null;
      await db.close();
    });
    DatabaseHelper.testAppDatabase = db;

    await tester.pumpWidget(const PocketCRMApp());
    await tester.pump();

    expect(find.text('PocketCRM'), findsAtLeastNWidgets(1));
  });
}
