/// Centralized route paths + names. Notification deep-link payloads use these
/// exact path strings (e.g. a push with `data.route = "/notifications"`).
abstract final class AppRoutes {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String enterDomain = '/enter-domain';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String appearance = '/settings/appearance';
  static const String profile = '/profile';

  // Named routes (for `context.goNamed` / type-safe navigation).
  static const String loginName = 'login';
  static const String forgotPasswordName = 'forgot-password';
  static const String enterDomainName = 'enter-domain';
  static const String homeName = 'home';
  static const String notificationsName = 'notifications';
  static const String settingsName = 'settings';
  static const String appearanceName = 'appearance';
  static const String profileName = 'profile';
}
