import 'package:flutter/material.dart';
import 'package:pnestaffapp/core/responsive/breakpoints.dart';
import 'package:pnestaffapp/core/responsive/responsive_builder.dart';

/// One navigation destination, rendered as a bottom-bar item on phones and a
/// rail item on tablets/desktop.
class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Adaptive navigation shell: a [NavigationBar] on compact widths, a
/// [NavigationRail] on medium/expanded, and an extended rail on large widths.
/// Wrap a `StatefulShellRoute` body with this to get one nav model everywhere.
class AdaptiveNavShell extends StatelessWidget {
  const AdaptiveNavShell({
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.floatingActionButton,
    super.key,
  });

  final List<AdaptiveDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, bp) {
        if (bp.isPhone) {
          return Scaffold(
            body: SafeArea(bottom: false, child: body),
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        final extended = bp.isLarge;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  extended: extended,
                  minExtendedWidth: 200,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: extended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  leading: floatingActionButton == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: floatingActionButton,
                        ),
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Two-pane master/detail layout: side-by-side on [minBreakpoint]+, otherwise
/// just the primary pane (push the detail as a route on phones).
class AdaptiveTwoPane extends StatelessWidget {
  const AdaptiveTwoPane({
    required this.primary,
    required this.secondary,
    this.primaryFlex = 2,
    this.secondaryFlex = 3,
    this.minBreakpoint = Breakpoint.expanded,
    super.key,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final Breakpoint minBreakpoint;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, bp) {
        if (bp.index < minBreakpoint.index) return primary;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: primaryFlex, child: primary),
            const VerticalDivider(width: 1),
            Expanded(flex: secondaryFlex, child: secondary),
          ],
        );
      },
    );
  }
}
