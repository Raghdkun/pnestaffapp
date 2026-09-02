/// App-wide, flavor-independent constants.
abstract final class AppConstants {
  static const String appName = 'PNE Staff';

  // Network timeouts.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  // Motion.
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 250);
  static const Duration longAnimation = Duration(milliseconds: 400);
}

/// Keys used for secure/preferences storage. Centralized to avoid typos.
abstract final class StorageKeys {
  static const String accessToken = 'auth.access_token';
  static const String refreshToken = 'auth.refresh_token';
  static const String cachedUser = 'auth.cached_user';
  static const String themeState = 'settings.theme';
  static const String locale = 'settings.locale';
  static const String fcmToken = 'notifications.fcm_token';
  static const String deviceId = 'device.id';
  static const String onboardingComplete = 'app.onboarding_complete';
  static const String tenantActiveDomain = 'tenant.active_domain';
  static const String tenantAllowlistCache = 'tenant.allowlist_cache';
  static const String tenantAllowlistCachedAt = 'tenant.allowlist_cached_at';
}

/// Hive box names.
abstract final class HiveBoxes {
  static const String cache = 'cache_box';
  static const String hydrated = 'hydrated_box';
}
