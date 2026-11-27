import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';
import 'package:pocket_crm/main.dart';

void main() {
  testWidgets('PocketCRMApp defaults to v2 Today screen when contacts exist',
      (WidgetTester tester) async {
    final db = AppDatabase.inMemory();
    await tester.runAsync(() async {
      await PeopleRepository(db).createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+2348031234567',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const PocketCRMApp(enableBackgroundSync: false),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Starts on Today with no --dart-define flag
    expect(find.text('Today'), findsWidgets);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(db.close);
  });
}
