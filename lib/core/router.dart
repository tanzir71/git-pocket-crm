import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../dev/gallery_screen.dart';
import '../features/messages/ui/messages_screen.dart';
import '../features/people/ui/people_screen.dart';
import '../features/people/ui/person_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import '../features/setup/ui/setup_screen.dart';
import '../features/today/ui/today_screen.dart';
import 'providers.dart';
import 'widgets/app_shell.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Provides the single [GoRouter] instance for the v2 shell.
/// Uses `refreshListenable` so the router is never recreated when stream state updates.
final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final refreshNotifier = _RouterRefreshNotifier();

  ref.listen<AsyncValue<bool>>(hasAnyContactsProvider, (_, _) {
    refreshNotifier.refresh();
  });
  ref.listen<bool>(setupDeferredProvider, (_, _) {
    refreshNotifier.refresh();
  });

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/today',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final uri = state.uri;

      // Normalize pocketcrm:// deep links
      if (uri.scheme == 'pocketcrm') {
        if (uri.host == 'person' && uri.pathSegments.isNotEmpty) {
          return '/people/${uri.pathSegments.first}';
        }
        if (uri.host == 'after-call') {
          final number = uri.queryParameters['number'];
          if (number != null && number.isNotEmpty) {
            return '/today?afterCallNumber=${Uri.encodeQueryComponent(number)}';
          }
          return '/today';
        }
        return '/today';
      }

      // First run: redirect to /setup when no contact exists yet (unless deferred)
      final hasContacts = ref.read(hasAnyContactsProvider).value;
      final setupDeferred = ref.read(setupDeferredProvider);
      final loc = state.matchedLocation;
      if (hasContacts == false &&
          !setupDeferred &&
          loc != '/setup' &&
          loc != '/dev/gallery') {
        return '/setup';
      }

      return null;
    },
    errorBuilder: (context, state) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/today');
        }
      });
      return const TodayScreen();
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/people',
                builder: (context, state) => PeopleScreen(
                  focusSearch: state.uri.queryParameters['focusSearch'] == '1',
                  initialSelectionForCadence:
                      state.uri.queryParameters['selectForCadence'] == '1',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/people/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PersonScreen(contactId: id);
        },
      ),
      GoRoute(
        path: '/messages/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NewMessageScreen(),
      ),
      GoRoute(
        path: '/messages/campaign/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CampaignScreen(campaignId: id);
        },
      ),
      GoRoute(
        path: '/messages/sent',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SentMessagesScreen(),
      ),
      GoRoute(
        path: '/messages/templates/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'new';
          return TemplateEditorScreen(templateId: id);
        },
      ),
      GoRoute(
        path: '/setup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BackupSettingsScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/dev/gallery',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const GalleryScreen(),
        ),
    ],
  );

  ref.onDispose(() {
    refreshNotifier.dispose();
    router.dispose();
  });

  return router;
});
