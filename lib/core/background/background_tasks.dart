/// Identifiers for background work. The iOS identifiers must *exactly* match the
/// `BGTaskSchedulerPermittedIdentifiers` array in `ios/Runner/Info.plist` and the
/// registrations in `AppDelegate.swift`.
abstract final class BackgroundTasks {
  /// Reverse-DNS prefix so iOS BGTaskScheduler identifiers are globally unique.
  static const String _prefix = 'com.pneunited.pnestaffapp';

  /// Periodic data sync (Android: WorkManager periodic; iOS: BGAppRefreshTask).
  static const String periodicSync = 'periodic_sync';
  static const String periodicSyncUnique = '$_prefix.$periodicSync';

  /// Longer, one-off processing (Android: WorkManager one-off; iOS: BGProcessingTask).
  static const String processing = 'processing';
  static const String processingUnique = '$_prefix.$processing';
}
