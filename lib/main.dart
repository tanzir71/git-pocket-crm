import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.registerFontLicenses();
  runApp(
    const ProviderScope(
      child: PocketCRMApp(),
    ),
  );
}

class PocketCRMApp extends StatelessWidget {
  const PocketCRMApp({super.key, this.enableBackgroundSync = true});

  final bool enableBackgroundSync;

  @override
  Widget build(BuildContext context) {
    return PocketCrmV2App(enableBackgroundSync: enableBackgroundSync);
  }
}
