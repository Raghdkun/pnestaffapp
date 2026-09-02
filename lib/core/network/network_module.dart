import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/config/flavor.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/network/interceptors/auth_interceptor.dart';
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Builds the app's single configured [Dio] instance for the active tenant.
/// Interceptor order matters: auth → retry → logging (logging last so it sees
/// the final, retried request/response). `baseUrl` is re-applied whenever
/// [TenantEndpoints] reports a tenant switch, mutating this same long-lived
/// `Dio` in place — see [TenantEndpoints] for why that's the safe approach.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    FlavorConfig config,
    AuthInterceptor authInterceptor,
    TenantEndpoints tenantEndpoints,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: tenantEndpoints.authBaseUrl.toString(),
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        contentType: Headers.jsonContentType,
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 2,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
        ],
      ),
    );

    if (config.enableNetworkLogs) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          maxWidth: 100,
        ),
      );
    }

    tenantEndpoints.onDomainChanged.listen(
      (_) => dio.options.baseUrl = tenantEndpoints.authBaseUrl.toString(),
    );

    return dio;
  }

  /// Fixed at the first-party host, regardless of the active tenant — used
  /// only by [TenantAllowlistService] to fetch `/known-domains.json` before
  /// a tenant switch is trusted. Never reads [TenantEndpoints] (that would be
  /// circular) and carries no [AuthInterceptor] (must stay unauthenticated).
  @Named('allowlist')
  @lazySingleton
  Dio allowlistDio(FlavorConfig config) => Dio(
    BaseOptions(
      baseUrl: (config.isDev || config.isStaging)
          ? 'https://authtesting.$defaultTenantDomain'
          : 'https://auth.$defaultTenantDomain',
      headers: const {'Accept': 'application/json'},
    ),
  );
}
