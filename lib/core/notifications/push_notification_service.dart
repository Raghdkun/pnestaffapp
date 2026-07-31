import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/notifications/notification_channels.dart';
import 'package:pnestaffapp/core/notifications/notification_router.dart';
import 'package:pnestaffapp/core/notifications/notification_service.dart';
import 'package:pnestaffapp/core/storage/key_value_storage.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

/// Background/terminated FCM handler. Must be top-level + `vm:entry-point`.
/// Registered from `bootstrap` via `FirebaseMessaging.onBackgroundMessage`.
/// For "notification" messages the OS renders the tray item; only data-only
/// messages need work here (re-init Firebase, then show a local notification).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Intentionally minimal — keep cold-start background work light.
}

/// Firebase Cloud Messaging: permission, token lifecycle, and the three message
/// delivery states (foreground, opened-from-background, terminated-launch).
/// Foreground messages are rendered through [NotificationService] so they look
/// identical to local notifications.
@lazySingleton
class PushNotificationService {
  PushNotificationService(
    this._messaging,
    this._local,
    this._storage,
    this._notificationRouter,
    this._logger,
  );

  final FirebaseMessaging _messaging;
  final NotificationService _local;
  final KeyValueStorage _storage;
  final NotificationRouter _notificationRouter;
  final AppLogger _logger;

  Future<void> initialize() async {
    // Push must never break app startup (e.g. getToken throws on an iOS
    // simulator without APNs), so the whole flow is guarded.
    try {
      await requestPermission();
      await _syncToken();

      _messaging.onTokenRefresh.listen(_saveToken);
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromBackground);

      // Cold start from a tapped push while terminated.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        final route = _routeOf(initial);
        if (route != null) _notificationRouter.initialRoute = route;
      }
    } on Object catch (e, s) {
      _logger.w('Push initialization skipped', error: e, stackTrace: s);
    }
  }

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    final status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> _syncToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    await _storage.setString(StorageKeys.fcmToken, token);
    _logger.d('FCM token synced');
    // TODO(api): send the token to the backend so it can target this device.
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    unawaited(
      _local.show(
        AppNotification(
          id:
              (message.messageId?.hashCode ?? notification.hashCode) &
              0x7fffffff,
          title: notification.title ?? '',
          body: notification.body ?? '',
          route: _routeOf(message),
          channel: AppNotificationChannel.alerts,
        ),
      ),
    );
  }

  void _onOpenedFromBackground(RemoteMessage message) {
    final route = _routeOf(message);
    if (route != null) _notificationRouter.selectRoute(route);
  }

  String? _routeOf(RemoteMessage message) {
    final route = message.data['route'];
    return (route is String && route.isNotEmpty) ? route : null;
  }
}
