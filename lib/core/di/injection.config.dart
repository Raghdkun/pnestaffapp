// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pnestaffapp/core/background/background_task_service.dart'
    as _i58;
import 'package:pnestaffapp/core/config/flavor.dart' as _i175;
import 'package:pnestaffapp/core/device/device_info_service.dart' as _i341;
import 'package:pnestaffapp/core/di/register_module.dart' as _i781;
import 'package:pnestaffapp/core/network/api_client.dart' as _i428;
import 'package:pnestaffapp/core/network/interceptors/auth_interceptor.dart'
    as _i330;
import 'package:pnestaffapp/core/network/network_info.dart' as _i36;
import 'package:pnestaffapp/core/network/network_module.dart' as _i906;
import 'package:pnestaffapp/core/network/session_expired_notifier.dart'
    as _i433;
import 'package:pnestaffapp/core/notifications/local_notification_service.dart'
    as _i947;
import 'package:pnestaffapp/core/notifications/notification_router.dart'
    as _i718;
import 'package:pnestaffapp/core/notifications/notification_service.dart'
    as _i564;
import 'package:pnestaffapp/core/notifications/push_notification_service.dart'
    as _i984;
import 'package:pnestaffapp/core/permissions/permission_service.dart' as _i163;
import 'package:pnestaffapp/core/router/app_router.dart' as _i660;
import 'package:pnestaffapp/core/storage/key_value_storage.dart' as _i878;
import 'package:pnestaffapp/core/storage/preferences_service.dart' as _i318;
import 'package:pnestaffapp/core/storage/secure_storage_service.dart' as _i123;
import 'package:pnestaffapp/core/storage/token_storage.dart' as _i840;
import 'package:pnestaffapp/core/tenant/deep_link_service.dart' as _i665;
import 'package:pnestaffapp/core/tenant/tenant_allowlist_service.dart' as _i162;
import 'package:pnestaffapp/core/tenant/tenant_domain_resolver.dart' as _i640;
import 'package:pnestaffapp/core/tenant/tenant_endpoints.dart' as _i899;
import 'package:pnestaffapp/core/tenant/tenant_storage.dart' as _i131;
import 'package:pnestaffapp/core/theme/cubit/theme_cubit.dart' as _i17;
import 'package:pnestaffapp/core/updates/shorebird_update_service.dart' as _i20;
import 'package:pnestaffapp/core/utils/app_logger.dart' as _i705;
import 'package:pnestaffapp/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i733;
import 'package:pnestaffapp/features/auth/data/repositories/auth_repository_impl.dart'
    as _i664;
import 'package:pnestaffapp/features/auth/domain/repositories/auth_repository.dart'
    as _i589;
import 'package:pnestaffapp/features/auth/domain/usecases/forgot_password.dart'
    as _i530;
import 'package:pnestaffapp/features/auth/domain/usecases/get_current_user.dart'
    as _i530;
import 'package:pnestaffapp/features/auth/domain/usecases/get_profile.dart'
    as _i273;
import 'package:pnestaffapp/features/auth/domain/usecases/login.dart' as _i534;
import 'package:pnestaffapp/features/auth/domain/usecases/logout.dart' as _i143;
import 'package:pnestaffapp/features/auth/domain/usecases/reset_password.dart'
    as _i158;
import 'package:pnestaffapp/features/auth/domain/usecases/verify_reset_otp.dart'
    as _i346;
import 'package:pnestaffapp/features/auth/presentation/bloc/auth_bloc.dart'
    as _i353;
import 'package:pnestaffapp/features/auth/presentation/forgot_password/forgot_password_cubit.dart'
    as _i774;
import 'package:pnestaffapp/features/tenant/presentation/cubit/tenant_cubit.dart'
    as _i181;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => registerModule.localNotifications,
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => registerModule.firebaseMessaging,
    );
    gh.lazySingleton<_i433.SessionExpiredNotifier>(
      () => _i433.SessionExpiredNotifier(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i718.NotificationRouter>(
      () => _i718.NotificationRouter(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i163.PermissionService>(() => _i163.PermissionService());
    gh.lazySingleton<_i17.ThemeCubit>(() => _i17.ThemeCubit());
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.allowlistDio(gh<_i175.FlavorConfig>()),
      instanceName: 'allowlist',
    );
    gh.lazySingleton<_i123.SecureStorageService>(
      () => _i123.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i705.AppLogger>(() => _i705.AppLoggerImpl());
    gh.lazySingleton<_i58.BackgroundTaskService>(
      () => _i58.BackgroundTaskService(gh<_i705.AppLogger>()),
    );
    gh.lazySingleton<_i20.ShorebirdUpdateService>(
      () => _i20.ShorebirdUpdateService(gh<_i705.AppLogger>()),
    );
    gh.lazySingleton<_i36.NetworkInfo>(
      () => _i36.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i564.NotificationService>(
      () => _i947.LocalNotificationService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
        gh<_i718.NotificationRouter>(),
        gh<_i705.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i878.KeyValueStorage>(
      () => _i318.PreferencesService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i341.DeviceInfoService>(
      () => _i341.DeviceInfoService(gh<_i123.SecureStorageService>()),
    );
    gh.lazySingleton<_i840.TokenStorage>(
      () => _i840.TokenStorage(gh<_i123.SecureStorageService>()),
    );
    gh.lazySingleton<_i131.TenantStorage>(
      () => _i131.TenantStorage(gh<_i878.KeyValueStorage>()),
    );
    gh.lazySingleton<_i162.TenantAllowlistService>(
      () => _i162.TenantAllowlistService(
        gh<_i361.Dio>(instanceName: 'allowlist'),
        gh<_i131.TenantStorage>(),
        gh<_i705.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i984.PushNotificationService>(
      () => _i984.PushNotificationService(
        gh<_i892.FirebaseMessaging>(),
        gh<_i564.NotificationService>(),
        gh<_i878.KeyValueStorage>(),
        gh<_i718.NotificationRouter>(),
        gh<_i705.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i899.TenantEndpoints>(
      () => _i899.TenantEndpoints(
        gh<_i175.FlavorConfig>(),
        gh<_i131.TenantStorage>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i640.TenantDomainResolver>(
      () => _i640.TenantDomainResolver(
        gh<_i899.TenantEndpoints>(),
        gh<_i162.TenantAllowlistService>(),
        gh<_i840.TokenStorage>(),
        gh<_i878.KeyValueStorage>(),
        gh<_i705.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i330.AuthInterceptor>(
      () => _i330.AuthInterceptor(
        gh<_i840.TokenStorage>(),
        gh<_i433.SessionExpiredNotifier>(),
        gh<_i899.TenantEndpoints>(),
        gh<_i705.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i175.FlavorConfig>(),
        gh<_i330.AuthInterceptor>(),
        gh<_i899.TenantEndpoints>(),
      ),
    );
    gh.lazySingleton<_i428.ApiClient>(() => _i428.ApiClient(gh<_i361.Dio>()));
    gh.lazySingleton<_i665.DeepLinkService>(
      () => _i665.DeepLinkService(
        gh<_i640.TenantDomainResolver>(),
        gh<_i705.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i733.AuthRemoteDataSource>(
      () => _i733.AuthRemoteDataSourceImpl(gh<_i428.ApiClient>()),
    );
    gh.lazySingleton<_i589.AuthRepository>(
      () => _i664.AuthRepositoryImpl(
        gh<_i733.AuthRemoteDataSource>(),
        gh<_i840.TokenStorage>(),
        gh<_i878.KeyValueStorage>(),
        gh<_i341.DeviceInfoService>(),
      ),
    );
    gh.factory<_i530.ForgotPassword>(
      () => _i530.ForgotPassword(gh<_i589.AuthRepository>()),
    );
    gh.factory<_i530.GetCurrentUser>(
      () => _i530.GetCurrentUser(gh<_i589.AuthRepository>()),
    );
    gh.factory<_i273.GetProfile>(
      () => _i273.GetProfile(gh<_i589.AuthRepository>()),
    );
    gh.factory<_i534.Login>(() => _i534.Login(gh<_i589.AuthRepository>()));
    gh.factory<_i143.Logout>(() => _i143.Logout(gh<_i589.AuthRepository>()));
    gh.factory<_i158.ResetPassword>(
      () => _i158.ResetPassword(gh<_i589.AuthRepository>()),
    );
    gh.factory<_i346.VerifyResetOtp>(
      () => _i346.VerifyResetOtp(gh<_i589.AuthRepository>()),
    );
    gh.factory<_i774.ForgotPasswordCubit>(
      () => _i774.ForgotPasswordCubit(
        gh<_i530.ForgotPassword>(),
        gh<_i346.VerifyResetOtp>(),
        gh<_i158.ResetPassword>(),
      ),
    );
    gh.lazySingleton<_i353.AuthBloc>(
      () => _i353.AuthBloc(
        gh<_i534.Login>(),
        gh<_i143.Logout>(),
        gh<_i530.GetCurrentUser>(),
        gh<_i273.GetProfile>(),
        gh<_i433.SessionExpiredNotifier>(),
      ),
    );
    gh.lazySingleton<_i660.AppRouter>(
      () => _i660.AppRouter(gh<_i353.AuthBloc>()),
    );
    gh.lazySingleton<_i181.TenantCubit>(
      () => _i181.TenantCubit(
        gh<_i640.TenantDomainResolver>(),
        gh<_i353.AuthBloc>(),
        gh<_i899.TenantEndpoints>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i781.RegisterModule {}

class _$NetworkModule extends _i906.NetworkModule {}
