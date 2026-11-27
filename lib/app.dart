import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/providers.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// PocketCRM v2 application shell (`MaterialApp.router`, Riverpod, Inter theme, l10n).
class PocketCrmV2App extends ConsumerWidget {
  const PocketCrmV2App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final localeOverride = ref.watch(localeOverrideProvider).value;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'PocketCRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: localeOverride,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
