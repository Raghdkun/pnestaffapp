import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pnestaffapp/app/app.dart';
import 'package:pnestaffapp/app/observer.dart';
import 'package:pnestaffapp/core/background/background_task_service.dart';
import 'package:pnestaffapp/core/config/flavor.dart';
import 'package:pnestaffapp/core/di/injection.dart';
import 'package:pnestaffapp/core/notifications/notification_service.dart';
import 'package:pnestaffapp/core/notifications/push_notification_service.dart';
import 'package:pnestaffapp/core/tenant/deep_link_service.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:pnestaffapp/firebase_options.dart';

/// Single startup path for every flavor. Order matters: storage → DI → error
/// handlers → platform services → session resolution → runApp.
Future<void> bootstrap(FlavorConfig config) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Persisted bloc/cubit state (ThemeCubit and friends).
      final documentsDir = await getApplicationDocumentsDirectory();
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(documentsDir.path),
      );

      // Dependency injection (flavor registered first — the Dio client and
      // flavor-scoped data sources read it).
      getIt.registerSingleton<FlavorConfig>(config);
      await configureDependencies(config.environment);

      final logger = getIt<AppLogger>();
      Bloc.observer = const AppBlocObserver();

      // Framework + isolate error handling (ready to forward to Crashlytics).
      FlutterError.onError = (details) {
        logger.e(
          'FlutterError',
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
        logger.e('Uncaught platform error', error: error, stackTrace: stack);
        return true;
      };

      // Local notifications always; push only once Firebase is configured.
      await getIt<NotificationService>().initialize();
      if (await _initializeFirebase(logger)) {
        logger.i('Firebase initialized');
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        // Non-blocking: the permission prompt + token fetch run over the UI so
        // they never delay the first frame.
        unawaited(getIt<PushNotificationService>().initialize());
      }

      // Background task engine.
      await getIt<BackgroundTaskService>().initialize();

      // Resolve a cold-start deep link before anything touches the network
      // layer: NetworkModule.dio / AuthInterceptor read TenantEndpoints at
      // construction, and AuthCheckRequested below is what first constructs
      // them, so the tenant must already be resolved by this point.
      await getIt<DeepLinkService>().handleInitialLink();

      // Resolve the persisted session before the first frame (no auth flash).
      final authBloc = getIt<AuthBloc>()..add(const AuthCheckRequested());
      await authBloc.stream.firstWhere(
        (state) => state.status != AuthStatus.unknown,
      );

      runApp(const PneStaffApp());
    },
    (error, stack) {
      if (getIt.isRegistered<AppLogger>()) {
        getIt<AppLogger>().e(
          'Uncaught zone error',
          error: error,
          stackTrace: stack,
        );
      } else {
        debugPrint('Uncaught zone error: $error\n$stack');
      }
    },
  );
}

/// Attempts Firebase init. Returns `false` (push disabled) until the developer
/// runs `flutterfire configure` to generate real options.
Future<bool> _initializeFirebase(AppLogger logger) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } on Object catch (e, s) {
    logger.w(
      'Firebase not configured — push disabled. '
      'Run `flutterfire configure` to enable it.',
      error: e,
      stackTrace: s,
    );
    return false;
  }
}
