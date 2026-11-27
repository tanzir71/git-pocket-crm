import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/theme/app_theme.dart';
import 'dev/gallery_screen.dart';
import 'legacy/home_screen.dart';

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
  const PocketCRMApp({super.key, this.useV2 = kV2});

  final bool useV2;

  @override
  Widget build(BuildContext context) {
    if (useV2) {
      return const PocketCrmV2App();
    }

    const primaryColor = Color(0xFF3525CD);

    return MaterialApp(
      title: 'PocketCRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppTheme.fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: const Color(0xFF4F46E5),
          surface: const Color(0xFFF9FAFB),
        ),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      routes: {
        if (kDebugMode) '/dev/gallery': (_) => const GalleryScreen(),
      },
      home: const HomeScreen(),
    );
  }
}
