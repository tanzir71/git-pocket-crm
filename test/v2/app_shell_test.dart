import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/app.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/features/people/data/people_repository.dart';

void main() {
  testWidgets('v2 shell switches between Today, People, and Messages with no spinner',
      (tester) async {
    final db = AppDatabase.inMemory();

    await tester.runAsync(() async {
      await PeopleRepository(db).createPerson(
        displayName: 'Amara Okafor',
        phoneNumber: '+14155550101',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const PocketCrmV2App(),
      ),
    );
    await tester.pumpAndSettle();

    // Starts on Today
    expect(find.text('Today'), findsAtLeastNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Tap People destination
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    expect(find.text('People will be built in spec 06.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Tap Messages destination
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Messages will be built in spec 10.'), findsOneWidget);

    // Tap Today destination
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Today will be built in spec 08.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => db.close());
  });

  testWidgets('empty database redirects v2 shell to /setup, Do this later goes to Today',
      (tester) async {
    final db = AppDatabase.inMemory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const PocketCrmV2App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Finish setup'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Do this later'));
    await tester.pumpAndSettle();

    expect(find.text('Today will be built in spec 08.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => db.close());
  });
}
