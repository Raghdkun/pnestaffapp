import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';

/// Centered progress indicator with an optional caption.
class AppLoader extends StatelessWidget {
  const AppLoader({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const Gap(AppSpacing.md),
            Text(message!, style: context.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
