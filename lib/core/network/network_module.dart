import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/config/flavor.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/network/interceptors/auth_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Builds the app's single configured [Dio] instance from the active flavor.
/// Interceptor order matters: auth → retry → logging (logging last so it sees
/// the final, retried request/response).
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(FlavorConfig config, AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
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

    return dio;
  }
}
