import 'package:pnestaffapp/core/background/background_tasks.dart';
import 'package:workmanager/workmanager.dart';

/// The background isolate entry point. Registered with `Workmanager().initialize`.
///
/// IMPORTANT: this runs in a *separate isolate* with no access to the app's
/// `getIt` graph, widgets, or in-memory state. Anything it needs (storage, Dio,
/// Firebase) must be re-initialized here. Keep the work short and idempotent;
/// return `false`/throw to let WorkManager retry with backoff.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case BackgroundTasks.periodicSync:
      case Workmanager.iOSBackgroundTask:
        // TODO(sync): open storage, refresh remote data, update caches.
        return true;

      case BackgroundTasks.processing:
        // TODO(processing): long-running one-off work (uploads, cleanup).
        return true;

      default:
        return true;
    }
  });
}
