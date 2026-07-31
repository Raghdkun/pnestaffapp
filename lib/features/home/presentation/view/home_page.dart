import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/responsive/responsive_builder.dart';
import 'package:pnestaffapp/core/responsive/responsive_value.dart';
import 'package:pnestaffapp/core/router/app_routes.dart';
import 'package:pnestaffapp/core/theme/tokens/app_radii.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';
import 'package:pnestaffapp/core/widgets/fade_slide_in.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final employee = context.select<AuthBloc, Employee?>(
      (bloc) => bloc.state.employee,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: l10n.profileTitle,
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: FadeSlideIn(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              employee == null
                  ? l10n.homeTitle
                  : l10n.greeting(employee.fullName),
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (employee != null && employee.roles.isNotEmpty) ...[
              const Gap(AppSpacing.xxs),
              Text(
                employee.roles.first,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const Gap(AppSpacing.lg),
            const _QuickActionsGrid(),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  static const _actions = <_QuickAction>[
    _QuickAction(Icons.access_time_rounded, 'Attendance'),
    _QuickAction(Icons.request_page_outlined, 'Requests'),
    _QuickAction(Icons.receipt_long_outlined, 'Payslips'),
    _QuickAction(Icons.groups_outlined, 'Directory'),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        final columns = context.responsive(
          const ResponsiveValue(compact: 2, medium: 3, expanded: 4),
        );
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.1,
          children: [
            for (final action in _actions) _QuickActionCard(action: action),
          ],
        );
      },
    );
  }
}

class _QuickAction {
  const _QuickAction(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: AppRadii.brLg,
        onTap: () => context.showSnack('${action.label} — coming soon'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(
                  action.icon,
                  size: 26,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(AppSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: context.textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
