import 'package:pnestaffapp/core/notifications/notification_channels.dart';

/// A displayable notification. `route` (when set) is stored as the payload and
/// used to deep-link when the user taps the notification.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.route,
    this.channel = AppNotificationChannel.general,
  });

  final int id;
  final String title;
  final String body;
  final String? route;
  final AppNotificationChannel channel;
}

/// Contract for showing/scheduling notifications. Implemented by
/// [LocalNotificationService]; push (FCM) delegates display to it.
abstract interface class NotificationService {
  Future<void> initialize();

  /// Requests OS notification permission (Android 13+, iOS). Returns granted.
  Future<bool> requestPermission();

  Future<void> show(AppNotification notification);

  /// Schedules [notification] to fire at [dateTime] (device-local time).
  Future<void> schedule(AppNotification notification, DateTime dateTime);

  Future<void> cancel(int id);

  Future<void> cancelAll();
}
