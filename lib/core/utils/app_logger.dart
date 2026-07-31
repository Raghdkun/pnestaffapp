import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Thin logging abstraction so call sites don't depend on a concrete logger and
/// so prod builds can be silenced (or forwarded to Crashlytics) in one place.
abstract interface class AppLogger {
  void d(Object? message);
  void i(Object? message);
  void w(Object? message, {Object? error, StackTrace? stackTrace});
  void e(Object? message, {Object? error, StackTrace? stackTrace});
}

@LazySingleton(as: AppLogger)
class AppLoggerImpl implements AppLogger {
  /// Verbose in debug/profile; warnings-and-above in release builds.
  AppLoggerImpl()
    : _logger = Logger(
        level: kReleaseMode ? Level.warning : Level.debug,
        printer: PrettyPrinter(
          methodCount: 0,
          lineLength: 100,
        ),
      );

  final Logger _logger;

  @override
  void d(Object? message) => _logger.d(message);

  @override
  void i(Object? message) => _logger.i(message);

  @override
  void w(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  @override
  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
