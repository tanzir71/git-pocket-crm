import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/db/app_database.dart';
import 'package:pocket_crm/core/providers.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/features/setup/data/setup_controller.dart';
import 'package:pocket_crm/features/setup/ui/setup_screen.dart';
import 'package:pocket_crm/l10n/app_localizations.dart';

Future<void> _loadInterFont() async {
  final loader = FontLoader('Inter');
  for (final path in const [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
  ]) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

class _GoldenSetupBridge implements SetupPlatformBridge {
  @override
  Future<SetupCapabilityState> readState() async => const SetupCapabilityState(
        contactsGranted: true,
        callsAndMessagesGranted: true,
        exactAlarmsGranted: false,
        batteryGranted: false,
        notificationsGranted: false,
      );

  @override
  Future<bool> requestContacts() async => true;
  @override
  Future<CallsSmsRequestResult> requestCallsAndMessages() async =>
      const CallsSmsRequestResult(granted: true, elapsed: Duration.zero);
  @override
  Future<void> openExactAlarmSettings() async {}
  @override
  Future<void> requestIgnoreBatteryOptimisations() async {}
  @override
  Future<bool> requestNotifications() async => true;
  @override
  Future<void> openAppDetailsSettings() async {}
}

void main() {
  setUpAll(_loadInterFont);

  for (final (mode, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    testWidgets('golden: Setup ($mode)', (tester) async {
      final db = AppDatabase.inMemory();
      tester.view.physicalSize = const Size(412, 917);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            setupPlatformBridgeProvider.overrideWithValue(_GoldenSetupBridge()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/setup_$mode.png'));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    });
  }
}
