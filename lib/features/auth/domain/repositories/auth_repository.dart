import 'package:pnestaffapp/core/result/result.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';

/// Domain contract for employee authentication (LC Portal API).
abstract interface class AuthRepository {
  /// Logs in with an employee id + password (sends device info + fcm token) and
  /// persists the session. Returns the authenticated [Employee].
  FutureResult<Employee> login({
    required int employeeId,
    required String password,
  });

  FutureResult<void> logout();

  /// The cached employee for instant startup (no network). Null if no session.
  FutureResult<Employee?> currentUser();

  /// Fetches the fresh employee (`GET /auth/employee/me`) and refreshes cache.
  FutureResult<Employee> getProfile();

  /// Rotates the bearer token (`POST /auth/refresh-token`); returns the new one.
  FutureResult<String> refreshToken();

  /// Sends a password-reset OTP to [email] (`POST /auth/forgot-password`).
  FutureResult<void> forgotPassword({required String email});

  FutureResult<void> verifyResetOtp({
    required String email,
    required String otp,
  });

  FutureResult<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
}
