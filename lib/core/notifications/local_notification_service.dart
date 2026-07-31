import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/notifications/notification_channels.dart';
import 'package:pnestaffapp/core/notifications/notification_router.dart';
import 'package:pnestaffapp/core/notifications/notification_service.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Handles taps delivered to a background isolate (app terminated). Must be a
/// top-level `vm:entry-point` function. The deep-link is resolved on the next
/// foreground via `getNotificationAppLaunchDetails`.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // No app state is available in this isolate; intentionally a no-op.
}

/// Local notifications: immediate display, timezone-aware scheduling, channels,
/// and tap → deep-link routing (via [NotificationRouter]).
@LazySingleton(as: NotificationService)
class LocalNotificationService implements NotificationService {
  LocalNotificationService(
    this._plugin,
    this._notificationRouter,
    this._logger,
  );

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationRouter _notificationRouter;
  final AppLogger _logger;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    await _configureLocalTimeZone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createChannels();
    await _captureLaunchRoute();

    _initialized = true;
    _logger.i('Local notifications initialized');
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final results = <bool?>[
      if (android != null) await android.requestNotificationsPermission(),
      if (ios != null)
        await ios.requestPermissions(alert: true, badge: true, sound: true),
    ];

    if (results.isEmpty) return true; // unsupported platform
    return results.every((granted) => granted ?? false);
  }

  @override
  Future<void> show(AppNotification notification) => _plugin.show(
    id: notification.id,
    title: notification.title,
    body: notification.body,
    notificationDetails: _details(notification.channel),
    payload: notification.route,
  );

  @override
  Future<void> schedule(AppNotification notification, DateTime dateTime) =>
      _plugin.zonedSchedule(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
        notificationDetails: _details(notification.channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: notification.route,
      );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  NotificationDetails _details(AppNotificationChannel channel) =>
      NotificationDetails(
        android: channel.toAndroidDetails(),
        iOS: const DarwinNotificationDetails(),
      );

  Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    for (final channel in AppNotificationChannel.values) {
      await android.createNotificationChannel(channel.toAndroidChannel());
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Object catch (e, s) {
      _logger.w('Falling back to UTC timezone', error: e, stackTrace: s);
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _captureLaunchRoute() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final route = details!.notificationResponse?.payload;
      if (route != null && route.isNotEmpty) {
        _notificationRouter.initialRoute = route;
      }
    }
  }

  void _onTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) {
      _notificationRouter.selectRoute(route);
    }
  }
}
