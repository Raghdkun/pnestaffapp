import 'package:flutter/material.dart';

/// Full-width primary action button with a built-in loading state and a subtle
/// scale-on-press micro-interaction. Styling comes from `filledButtonTheme`.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  final WidgetStatesController _statesController = WidgetStatesController();
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _statesController.addListener(_onStateChange);
  }

  void _onStateChange() {
    final pressed = _statesController.value.contains(WidgetState.pressed);
    if (pressed != _pressed) setState(() => _pressed = pressed);
  }

  @override
  void dispose() {
    _statesController
      ..removeListener(_onStateChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: FilledButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        statesController: _statesController,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: widget.isLoading
              ? const SizedBox.square(
                  key: ValueKey('loading'),
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(widget.label),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Full-width secondary (outlined) action button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }
}
