import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pnestaffapp/core/di/injection.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

/// Global bloc diagnostics. Uncaught bloc errors are logged centrally (and can
/// be forwarded to Crashlytics from here).
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    getIt<AppLogger>().e(
      '${bloc.runtimeType} error',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
