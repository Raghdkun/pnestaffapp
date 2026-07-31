import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/network/api_client.dart';
import 'package:pnestaffapp/core/network/api_envelope.dart';
import 'package:pnestaffapp/features/auth/data/models/employee_model.dart';

/// A successful employee login: the bearer token + the authenticated employee.
class LoginResult {
  const LoginResult({required this.token, required this.employee});

  final String token;
  final EmployeeModel employee;
}

/// LC Portal **employee** auth endpoints. Responses use the
/// `{success,message,data}` envelope; we unwrap `data` via [ApiEnvelope].
abstract interface class AuthRemoteDataSource {
  Future<LoginResult> login({
    required int employeeId,
    required String password,
    Map<String, dynamic>? device,
    String? fcmToken,
  });

  Future<void> logout();

  Future<EmployeeModel> me();

  Future<String> refreshToken();

  Future<void> forgotPassword({required String email});

  Future<void> verifyResetOtp({required String email, required String otp});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<LoginResult> login({
    required int employeeId,
    required String password,
    Map<String, dynamic>? device,
    String? fcmToken,
  }) async {
    final body = await _api.post<Map<String, dynamic>>(
      '/auth/employee/login',
      data: {
        'employee_id': employeeId,
        'password': password,
        'client_type': 'mobile',
        'device': ?device,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
      },
    );
    final data = ApiEnvelope.dataMap(body);
    return LoginResult(
      token: '${data['token']}',
      employee: EmployeeModel.fromJson(
        data['employee'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<void> logout() => _api.post<dynamic>('/auth/employee/logout');

  @override
  Future<EmployeeModel> me() async {
    final body = await _api.get<Map<String, dynamic>>('/auth/employee/me');
    return EmployeeModel.fromJson(
      ApiEnvelope.dataMap(body)['employee'] as Map<String, dynamic>,
    );
  }

  @override
  Future<String> refreshToken() async {
    final body = await _api.post<Map<String, dynamic>>('/auth/refresh-token');
    return '${ApiEnvelope.dataMap(body)['token']}';
  }

  @override
  Future<void> forgotPassword({required String email}) =>
      _api.post<dynamic>('/auth/forgot-password', data: {'email': email});

  @override
  Future<void> verifyResetOtp({required String email, required String otp}) =>
      _api.post<dynamic>(
        '/auth/reset-otp-verify',
        data: {'email': email, 'otp': otp},
      );

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) => _api.post<dynamic>(
    '/auth/reset-password',
    data: {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    },
  );
}
