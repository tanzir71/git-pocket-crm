import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n_ext.dart';
import '../theme/app_colors.dart';

/// Top-level three-tab shell (Today, People, Messages).
/// Back from People or Messages returns to Today; back on Today leaves the app.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final onTodayTab = navigationShell.currentIndex == 0;

    return PopScope(
      canPop: onTodayTab,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !onTodayTab) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        backgroundColor: c.bgCanvas,
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.borderHairline, width: 1)),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.wb_sunny_outlined),
                label: l10n.navToday,
              ),
              NavigationDestination(
                icon: const Icon(Icons.people_outline),
                label: l10n.navPeople,
              ),
              NavigationDestination(
                icon: const Icon(Icons.send_outlined),
                label: l10n.navMessages,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
