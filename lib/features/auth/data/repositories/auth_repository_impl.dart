import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/device/device_info_service.dart';
import 'package:pnestaffapp/core/result/result.dart';
import 'package:pnestaffapp/core/storage/key_value_storage.dart';
import 'package:pnestaffapp/core/storage/token_storage.dart';
import 'package:pnestaffapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pnestaffapp/features/auth/data/models/employee_model.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';
import 'package:pnestaffapp/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remote,
    this._tokenStorage,
    this._storage,
    this._deviceInfo,
  );

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final KeyValueStorage _storage;
  final DeviceInfoService _deviceInfo;

  @override
  FutureResult<Employee> login({
    required int employeeId,
    required String password,
  }) => guardAsync(() async {
    final device = (await _deviceInfo.metadata()).toJson();
    final result = await _remote.login(
      employeeId: employeeId,
      password: password,
      device: device,
      fcmToken: _storage.getString(StorageKeys.fcmToken),
    );
    await _tokenStorage.saveTokens(accessToken: result.token);
    await _cache(result.employee);
    return result.employee.toEntity();
  });

  @override
  FutureResult<void> logout() => guardAsync(() async {
    try {
      await _remote.logout();
    } finally {
      await _tokenStorage.clear();
      await _storage.remove(StorageKeys.cachedUser);
    }
  });

  @override
  FutureResult<Employee?> currentUser() => guardAsync(() async {
    if (!await _tokenStorage.hasSession()) return null;
    final cached = _storage.getString(StorageKeys.cachedUser);
    if (cached == null) return null;
    return EmployeeModel.fromCacheJson(
      jsonDecode(cached) as Map<String, dynamic>,
    ).toEntity();
  });

  @override
  FutureResult<Employee> getProfile() => guardAsync(() async {
    final employee = await _remote.me();
    await _cache(employee);
    return employee.toEntity();
  });

  @override
  FutureResult<String> refreshToken() => guardAsync(() async {
    final token = await _remote.refreshToken();
    await _tokenStorage.saveTokens(accessToken: token);
    return token;
  });

  @override
  FutureResult<void> forgotPassword({required String email}) =>
      guardAsync(() => _remote.forgotPassword(email: email));

  @override
  FutureResult<void> verifyResetOtp({
    required String email,
    required String otp,
  }) => guardAsync(() => _remote.verifyResetOtp(email: email, otp: otp));

  @override
  FutureResult<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) => guardAsync(
    () => _remote.resetPassword(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    ),
  );

  Future<void> _cache(EmployeeModel employee) => _storage.setString(
    StorageKeys.cachedUser,
    jsonEncode(employee.toCacheJson()),
  );
}
