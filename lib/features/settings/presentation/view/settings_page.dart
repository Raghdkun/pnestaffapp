import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pnestaffapp/core/background/background_task_service.dart';
import 'package:pnestaffapp/core/di/injection.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/permissions/permission_service.dart';
import 'package:pnestaffapp/core/router/app_routes.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _requestNotifications(BuildContext context) async {
    final granted = await getIt<PermissionService>().request(
      AppPermission.notifications,
    );
    if (context.mounted) {
      context.showSnack(
        granted ? 'Notifications enabled' : 'Notifications denied',
      );
    }
  }

  Future<void> _enableBackgroundSync(BuildContext context) async {
    await getIt<BackgroundTaskService>().registerPeriodicSync();
    if (context.mounted) {
      context.showSnack('Background sync scheduled (every 60 min)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: Text(l10n.profileTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.appearanceTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go(AppRoutes.appearance),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.notificationsTitle),
            subtitle: const Text('Grant OS notification permission'),
            onTap: () => _requestNotifications(context),
          ),
          ListTile(
            leading: const Icon(Icons.sync_rounded),
            title: const Text('Background sync'),
            subtitle: const Text('Register a periodic WorkManager task'),
            onTap: () => _enableBackgroundSync(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: context.colorScheme.error,
            ),
            title: Text(
              l10n.logoutButton,
              style: TextStyle(color: context.colorScheme.error),
            ),
            onTap: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}
