/// Low-level errors thrown by data sources / infrastructure. The repository
/// layer catches these and maps them to [Failure]s via `error_mapper.dart`, so
/// the domain/presentation layers never see raw exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  // Subtype name is a useful prefix when logging exceptions.
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType: $message';
}

/// A non-2xx HTTP response.
class ServerException extends AppException {
  const ServerException(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
}

/// No connectivity / connection refused.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// A connect/receive/send timeout.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.message = 'The request timed out']);
}

/// Local storage / cache access failed.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

/// 401/403 — token missing, expired, or insufficient.
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

/// 422 or client-side validation failure, with optional per-field messages.
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.errors,
    super.cause,
    super.stackTrace,
  });

  final Map<String, List<String>>? errors;
}

/// Anything not otherwise classified.
class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause, super.stackTrace});
}
