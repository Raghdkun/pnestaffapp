/// Material 3 window size classes, keyed off width.
enum Breakpoint { compact, medium, expanded, large }

abstract final class Breakpoints {
  /// Width thresholds (logical pixels).
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;

  static Breakpoint of(double width) {
    if (width >= large) return Breakpoint.large;
    if (width >= expanded) return Breakpoint.expanded;
    if (width >= medium) return Breakpoint.medium;
    return Breakpoint.compact;
  }
}

extension BreakpointX on Breakpoint {
  bool get isCompact => this == Breakpoint.compact;
  bool get isMedium => this == Breakpoint.medium;
  bool get isExpanded => this == Breakpoint.expanded;
  bool get isLarge => this == Breakpoint.large;

  /// Phone-sized (single-pane) UI.
  bool get isPhone => this == Breakpoint.compact;

  /// Tablet+ (rail / multi-pane) UI.
  bool get isTablet => index >= Breakpoint.medium.index;
}
