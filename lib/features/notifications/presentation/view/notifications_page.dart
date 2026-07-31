import 'package:flutter/material.dart';
import 'package:pnestaffapp/core/di/injection.dart';
import 'package:pnestaffapp/core/extensions/context_extensions.dart';
import 'package:pnestaffapp/core/notifications/notification_channels.dart';
import 'package:pnestaffapp/core/notifications/notification_service.dart';
import 'package:pnestaffapp/core/router/app_routes.dart';
import 'package:pnestaffapp/core/theme/tokens/app_spacing.dart';
import 'package:pnestaffapp/core/widgets/empty_view.dart';
import 'package:pnestaffapp/core/widgets/primary_button.dart';

/// Demonstrates the notification system end-to-end. In a real feature these
/// actions would be dispatched through a bloc; kept inline here for clarity.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<void> _sendTest(BuildContext context) async {
    // Capture context-dependent values before the async gap.
    final appName = context.l10n.appName;
    final messenger = ScaffoldMessenger.of(context);
    final service = getIt<NotificationService>();

    if (!await service.requestPermission()) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Notification permission was denied')),
        );
      return;
    }
    await service.show(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: appName,
        body: 'This is a test notification 🎉',
        route: AppRoutes.notifications,
        channel: AppNotificationChannel.alerts,
      ),
    );
  }

  Future<void> _scheduleTest(BuildContext context) async {
    final appName = context.l10n.appName;
    final messenger = ScaffoldMessenger.of(context);
    final service = getIt<NotificationService>();

    if (!await service.requestPermission()) return;
    await service.schedule(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: appName,
        body: 'Scheduled reminder (fires ~5s later)',
        route: AppRoutes.notifications,
        channel: AppNotificationChannel.reminders,
      ),
      DateTime.now().add(const Duration(seconds: 5)),
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Reminder scheduled')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: Column(
        children: [
          Expanded(
            child: EmptyView(
              title: l10n.emptyNotifications,
              icon: Icons.notifications_none_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                PrimaryButton(
                  label: l10n.sendTestNotification,
                  icon: Icons.send_rounded,
                  onPressed: () => _sendTest(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: 'Schedule in 5 seconds',
                  icon: Icons.schedule_rounded,
                  onPressed: () => _scheduleTest(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
