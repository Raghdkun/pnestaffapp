import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/responsive/adaptive_scaffold.dart';

/// Hosts the `StatefulShellRoute` branches inside the [AdaptiveNavShell] so the
/// app shows a bottom bar on phones and a navigation rail on tablets/desktop —
/// automatically, from the same destination list.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AdaptiveNavShell(
      currentIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        // Tapping the active tab resets it to its initial location.
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: [
        AdaptiveDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: l10n.homeTitle,
        ),
        AdaptiveDestination(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications_rounded,
          label: l10n.notificationsTitle,
        ),
        AdaptiveDestination(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
          label: l10n.settingsTitle,
        ),
      ],
      body: navigationShell,
    );
  }
}
