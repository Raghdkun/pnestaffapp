import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/background/background_tasks.dart';
import 'package:pnestaffapp/core/background/workmanager_callback.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';
import 'package:workmanager/workmanager.dart';

/// Initializes WorkManager and schedules the app's background jobs. Registered
/// in DI; called from `bootstrap` and from settings/feature code.
@lazySingleton
class BackgroundTaskService {
  BackgroundTaskService(this._logger);

  final AppLogger _logger;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await Workmanager().initialize(callbackDispatcher);
    _initialized = true;
    _logger.i('WorkManager initialized');
  }

  /// Periodic sync. Android enforces a 15-minute minimum frequency; on iOS the
  /// OS decides when (opportunistically) to run it.
  Future<void> registerPeriodicSync({
    Duration frequency = const Duration(hours: 1),
  }) async {
    await Workmanager().registerPeriodicTask(
      BackgroundTasks.periodicSyncUnique,
      BackgroundTasks.periodicSync,
      frequency: frequency,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
    _logger.i('Registered periodic sync every ${frequency.inMinutes}m');
  }

  /// One-off processing job with an optional payload and delay.
  Future<void> registerOneOffProcessing({
    Map<String, dynamic>? inputData,
    Duration initialDelay = Duration.zero,
  }) async {
    await Workmanager().registerOneOffTask(
      '${BackgroundTasks.processingUnique}.${DateTime.now().microsecondsSinceEpoch}',
      BackgroundTasks.processing,
      inputData: inputData,
      initialDelay: initialDelay,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
    );
    _logger.i('Registered one-off processing task');
  }

  Future<void> cancelAll() => Workmanager().cancelAll();
}
