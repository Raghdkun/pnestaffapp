import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';

/// Friendly empty state (no data yet). Keep copy short and action-oriented.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.colorScheme.onSurfaceVariant),
            const Gap(AppSpacing.md),
            Text(title, style: context.textTheme.titleMedium),
            if (subtitle != null) ...[
              const Gap(AppSpacing.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              const Gap(AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
