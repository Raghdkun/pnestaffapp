import 'package:flutter/widgets.dart';
import 'package:pnestaffapp/core/responsive/breakpoints.dart';
import 'package:pnestaffapp/core/responsive/responsive_value.dart';

/// Width/orientation helpers on [BuildContext].
extension ResponsiveContextX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  Breakpoint get breakpoint => Breakpoints.of(MediaQuery.sizeOf(this).width);
  bool get isPhone => breakpoint.isPhone;
  bool get isTablet => breakpoint.isTablet;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Resolve a [ResponsiveValue] against the current width.
  T responsive<T>(ResponsiveValue<T> value) => value.resolve(breakpoint);
}

/// Rebuilds its subtree against the local [Breakpoint] (from LayoutBuilder
/// constraints, so it works inside split panes, not just full-screen).
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, Breakpoint breakpoint) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, Breakpoints.of(constraints.maxWidth)),
    );
  }
}

/// Picks a whole widget by breakpoint; larger breakpoints fall back down.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    super.key,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, bp) {
        final chosen = switch (bp) {
          Breakpoint.large => large ?? expanded ?? medium ?? compact,
          Breakpoint.expanded => expanded ?? medium ?? compact,
          Breakpoint.medium => medium ?? compact,
          Breakpoint.compact => compact,
        };
        return chosen(context);
      },
    );
  }
}
