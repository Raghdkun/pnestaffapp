import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/network/session_expired_notifier.dart';
import 'package:pnestaffapp/core/storage/token_storage.dart';
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';

/// Attaches the bearer token and transparently recovers from a 401 by rotating
/// the token (`/auth/refresh-token`) once and retrying the original request.
/// Concurrent 401s share a single refresh (single-flight). If refresh fails the
/// session is cleared and [SessionExpiredNotifier] fires so the app signs out.
@lazySingleton
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._tokenStorage,
    this._sessionExpired,
    this._tenantEndpoints,
    this._logger,
  ) {
    // Built in the constructor body (not a `late final` field initializer)
    // so it can be seeded from `_tenantEndpoints` and then kept in sync via
    // the subscription below — an inline initializer can't do both.
    _bareDio = Dio(
      BaseOptions(
        baseUrl: _tenantEndpoints.authBaseUrl.toString(),
        headers: const {'Accept': 'application/json'},
      ),
    );
    _tenantEndpoints.onDomainChanged.listen(
      (_) => _bareDio.options.baseUrl = _tenantEndpoints.authBaseUrl.toString(),
    );
  }

  final TokenStorage _tokenStorage;
  final SessionExpiredNotifier _sessionExpired;
  final TenantEndpoints _tenantEndpoints;
  final AppLogger _logger;

  static const String _authHeader = 'Authorization';

  /// Interceptor-free client used for refresh + retry (avoids recursion).
  late final Dio _bareDio;

  /// Single in-flight refresh shared by all requests that 401 together.
  Future<String?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey(_authHeader)) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[_authHeader] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    final is401 = err.response?.statusCode == 401;

    // Not a recoverable auth failure, or a failed login → propagate as-is.
    if (!is401 || path.contains('/auth/login')) {
      return handler.next(err);
    }
    // The refresh call itself was rejected → the session is truly gone.
    if (path.contains('/auth/refresh-token')) {
      await _endSession();
      return handler.next(err);
    }

    try {
      final newToken = await _refresh();
      if (newToken == null) {
        await _endSession();
        return handler.next(err);
      }
      final options = err.requestOptions
        ..headers[_authHeader] = 'Bearer $newToken';
      final response = await _bareDio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on Object catch (e, s) {
      _logger.w('Token refresh/retry failed', error: e, stackTrace: s);
      await _endSession();
      return handler.next(err);
    }
  }

  Future<String?> _refresh() =>
      _refreshing ??= _performRefresh().whenComplete(() => _refreshing = null);

  Future<String?> _performRefresh() async {
    final current = await _tokenStorage.readAccessToken();
    if (current == null || current.isEmpty) return null;
    final response = await _bareDio.post<Map<String, dynamic>>(
      '/auth/refresh-token',
      options: Options(headers: {_authHeader: 'Bearer $current'}),
    );
    final data = response.data?['data'];
    final token = (data is Map ? data['token'] : null)?.toString();
    if (token == null || token.isEmpty) return null;
    await _tokenStorage.saveTokens(accessToken: token);
    return token;
  }

  Future<void> _endSession() async {
    await _tokenStorage.clear();
    _sessionExpired.notify();
  }
}
