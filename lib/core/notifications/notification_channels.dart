import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android notification channels (ignored on iOS). The [general] channel id is
/// also referenced by the FCM `default_notification_channel_id` manifest meta,
/// so keep the id in sync with `AndroidManifest.xml`.
enum AppNotificationChannel {
  general(
    id: 'general',
    name: 'General',
    description: 'General app notifications',
    importance: Importance.defaultImportance,
  ),
  alerts(
    id: 'alerts',
    name: 'Alerts',
    description: 'Important, time-sensitive alerts',
    importance: Importance.high,
  ),
  reminders(
    id: 'reminders',
    name: 'Reminders',
    description: 'Scheduled reminders',
    importance: Importance.high,
  );

  const AppNotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
  });

  final String id;
  final String name;
  final String description;
  final Importance importance;

  AndroidNotificationChannel toAndroidChannel() => AndroidNotificationChannel(
    id,
    name,
    description: description,
    importance: importance,
  );

  AndroidNotificationDetails toAndroidDetails() => AndroidNotificationDetails(
    id,
    name,
    channelDescription: description,
    importance: importance,
    priority: Priority.high,
  );
}
