import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/providers.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// PocketCRM v2 application shell (`MaterialApp.router`, Riverpod, Inter theme, l10n).
class PocketCrmV2App extends ConsumerStatefulWidget {
  const PocketCrmV2App({super.key, this.enableBackgroundSync = true});

  final bool enableBackgroundSync;

  @override
  ConsumerState<PocketCrmV2App> createState() => _PocketCrmV2AppState();
}

class _PocketCrmV2AppState extends ConsumerState<PocketCrmV2App>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enableBackgroundSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final sync = ref.read(syncServiceProvider);
        unawaited(
          sync.startObserving((_) {
            unawaited(sync.syncAll(syncContacts: false));
          }),
        );
        unawaited(sync.syncIfStale());
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableBackgroundSync) return;
    final sync = ref.read(syncServiceProvider);
    if (state == AppLifecycleState.resumed) {
      unawaited(sync.syncIfStale());
      unawaited(
        sync.startObserving((_) {
          unawaited(sync.syncAll(syncContacts: false));
        }),
      );
    } else if (state == AppLifecycleState.detached) {
      unawaited(sync.stopObserving());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
