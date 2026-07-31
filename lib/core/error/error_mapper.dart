import 'package:pnestaffapp/core/error/exceptions.dart';
import 'package:pnestaffapp/core/error/failures.dart';

/// Maps any error thrown in the data layer to a user-facing [Failure].
Failure mapExceptionToFailure(Object error, [StackTrace? stackTrace]) {
  return switch (error) {
    NetworkException() => NetworkFailure(error.message),
    RequestTimeoutException() => NetworkFailure(error.message),
    UnauthorizedException() => AuthFailure(error.message),
    ValidationException(:final message, :final errors) => ValidationFailure(
      message,
      fieldErrors: errors,
    ),
    ServerException(:final message, :final statusCode) => ServerFailure(
      message,
      statusCode: statusCode,
      cause: error.cause,
    ),
    CacheException() => CacheFailure(error.message),
    AppException() => UnknownFailure(error.message),
    _ => const UnknownFailure(),
  };
}
