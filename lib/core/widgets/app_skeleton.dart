import 'package:flutter/material.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:shimmer/shimmer.dart';

/// A single shimmering placeholder block. Compose several to build a loading
/// skeleton that mirrors the real content's layout.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    this.width,
    this.height = 14,
    this.radius = 8,
    this.circle = false,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final base = context.colorScheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      context.colorScheme.surface.withValues(alpha: 0.6),
      base,
    );
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: circle ? height : width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
