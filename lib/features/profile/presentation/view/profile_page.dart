import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/theme/extensions/app_colors_x.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';
import 'package:pnestaffapp/core/widgets/app_skeleton.dart';
import 'package:pnestaffapp/core/widgets/fade_slide_in.dart';
import 'package:pnestaffapp/core/widgets/primary_button.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';

/// Read-only employee profile (the API has no employee self-update endpoint).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _refresh(BuildContext context) async {
    context.read<AuthBloc>().add(const AuthRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final employee = state.employee;
          if (employee == null) return const _ProfileSkeleton();
          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: FadeSlideIn(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Center(child: _Avatar(name: employee.fullName)),
                  const Gap(AppSpacing.md),
                  Center(
                    child: Text(
                      employee.fullName,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.xxs),
                  Center(
                    child: Text(
                      '${l10n.employeeIdLabel}: ${employee.id}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Center(child: _StatusChip(active: employee.active)),
                  if (employee.roles.isNotEmpty) ...[
                    const Gap(AppSpacing.lg),
                    Text(l10n.rolesLabel, style: context.textTheme.labelLarge),
                    const Gap(AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final role in employee.roles)
                          Chip(label: Text(role)),
                      ],
                    ),
                  ],
                  const Gap(AppSpacing.lg),
                  Text(l10n.storesLabel, style: context.textTheme.labelLarge),
                  const Gap(AppSpacing.sm),
                  if (employee.stores.isEmpty)
                    Text(
                      l10n.noStores,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (final store in employee.stores)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _StoreTile(store: store),
                      ),
                  const Gap(AppSpacing.lg),
                  PrimaryButton(
                    label: l10n.logoutButton,
                    icon: Icons.logout_rounded,
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthLogoutRequested(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        Gap(AppSpacing.md),
        Center(child: AppSkeleton(height: 96, circle: true)),
        Gap(AppSpacing.md),
        Center(child: AppSkeleton(width: 180, height: 22)),
        Gap(AppSpacing.sm),
        Center(child: AppSkeleton(width: 130)),
        Gap(AppSpacing.xl),
        AppSkeleton(width: 90, height: 16),
        Gap(AppSpacing.sm),
        AppSkeleton(height: 64, radius: 16),
        Gap(AppSpacing.sm),
        AppSkeleton(height: 64, radius: 16),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = active ? context.colors.success : context.colorScheme.error;
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        active ? Icons.check_circle_outline : Icons.cancel_outlined,
        size: 18,
        color: color,
      ),
      label: Text(active ? l10n.activeLabel : l10n.inactiveLabel),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.store});

  final EmployeeStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.store_mall_directory_outlined,
          color: context.colorScheme.primary,
        ),
        title: Text(store.storeNumber),
        subtitle: store.status == null ? null : Text(store.status!),
        trailing: Icon(
          store.active ? Icons.check_circle : Icons.remove_circle_outline,
          color: store.active
              ? context.colors.success
              : context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: context.colorScheme.primaryContainer,
      foregroundColor: context.colorScheme.onPrimaryContainer,
      child: Text(_initials(name), style: context.textTheme.headlineMedium),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
