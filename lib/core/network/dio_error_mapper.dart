import 'package:dio/dio.dart';
import 'package:pnestaffapp/core/error/exceptions.dart';

/// Normalizes a [DioException] into one of our [AppException]s, which the
/// repository layer then maps to a user-facing `Failure` via `guardAsync`.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const RequestTimeoutException();
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badCertificate:
      return const NetworkException('Invalid server certificate');
    case DioExceptionType.cancel:
      return const UnknownException('Request cancelled');
    case DioExceptionType.badResponse:
      return _mapBadResponse(e);
    case DioExceptionType.unknown:
      return UnknownException(
        e.message ?? 'Unexpected network error',
        cause: e.error,
        stackTrace: e.stackTrace,
      );
  }
}

AppException _mapBadResponse(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;
  final message = _extractMessage(data);

  if (status == 401 || status == 403) {
    return UnauthorizedException(message ?? 'Unauthorized');
  }
  if (status == 422) {
    return ValidationException(
      message ?? 'Validation failed',
      errors: _extractFieldErrors(data),
    );
  }
  return ServerException(
    message ?? 'Server error ($status)',
    statusCode: status,
    cause: e,
  );
}

/// Best-effort extraction of a human message from common API error shapes
/// (`{"message": ...}` / `{"error": ...}`).
String? _extractMessage(Object? data) {
  if (data is Map) {
    final value = data['message'] ?? data['error'] ?? data['detail'];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

/// Extracts `{"errors": {"field": ["msg", ...]}}` style validation payloads.
Map<String, List<String>>? _extractFieldErrors(Object? data) {
  if (data is Map && data['errors'] is Map) {
    final errors = <String, List<String>>{};
    (data['errors'] as Map).forEach((key, value) {
      if (value is List) {
        errors['$key'] = value.map((e) => '$e').toList();
      } else {
        errors['$key'] = ['$value'];
      }
    });
    return errors.isEmpty ? null : errors;
  }
  return null;
}
