import 'package:pnestaffapp/core/responsive/breakpoints.dart';

/// A value that varies by [Breakpoint]. Only [compact] is required; larger
/// breakpoints fall back to the nearest smaller value that is set.
///
/// ```dart
/// final columns = const ResponsiveValue(compact: 1, medium: 2, expanded: 3)
///     .resolve(context.breakpoint);
/// ```
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
  });

  final T compact;
  final T? medium;
  final T? expanded;
  final T? large;

  T resolve(Breakpoint bp) {
    return switch (bp) {
      Breakpoint.large => large ?? expanded ?? medium ?? compact,
      Breakpoint.expanded => expanded ?? medium ?? compact,
      Breakpoint.medium => medium ?? compact,
      Breakpoint.compact => compact,
    };
  }
}
