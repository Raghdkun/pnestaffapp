import 'package:flutter/material.dart';

/// A subtle entrance: fades in while sliding up a few px. Wrap screen content
/// or list items to give the app a calm, professional sense of motion.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.offset = 14,
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final double offset;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offset),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
