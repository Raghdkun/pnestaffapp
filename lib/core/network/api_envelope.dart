import 'package:pnestaffapp/core/error/exceptions.dart';

/// Helpers for the LC Portal API response envelope: `{ success, message, data }`.
/// Data sources unwrap the payload with these before parsing models, so the
/// envelope shape lives in exactly one place.
abstract final class ApiEnvelope {
  /// The `data` node as a JSON object. Throws [ServerException] if it's missing
  /// or not an object (a contract violation the repository maps to a failure).
  static Map<String, dynamic> dataMap(Object? body) {
    final data = dataOf(body);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ServerException('Unexpected response format');
  }

  /// The raw `data` node (may be a Map, List, or null).
  static Object? dataOf(Object? body) {
    if (body is Map) return body['data'];
    return null;
  }

  /// The human-readable `message`, if present.
  static String? messageOf(Object? body) {
    if (body is Map && body['message'] is String) {
      return body['message'] as String;
    }
    return null;
  }

  /// Whether the envelope reports success (defaults to true when absent).
  static bool isSuccess(Object? body) {
    if (body is Map && body['success'] is bool) return body['success'] as bool;
    return true;
  }
}
