import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/error/failures.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/forgot_password.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/reset_password.dart';
import 'package:pnestaffapp/features/auth/domain/usecases/verify_reset_otp.dart';
import 'package:pnestaffapp/features/auth/presentation/forgot_password/forgot_password_state.dart';

/// Drives the reset flow: request OTP → verify OTP → set new password → done.
@injectable
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(
    this._forgotPassword,
    this._verifyResetOtp,
    this._resetPassword,
  ) : super(const ForgotPasswordState());

  final ForgotPassword _forgotPassword;
  final VerifyResetOtp _verifyResetOtp;
  final ResetPassword _resetPassword;

  Future<void> requestOtp(String email) async {
    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: null),
    );
    final result = await _forgotPassword(email: email);
    result.fold(
      (f) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: f.message,
          fieldErrors: _fields(f),
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          email: email,
          step: ForgotStep.otp,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> verifyOtp(String otp) async {
    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: null),
    );
    final result = await _verifyResetOtp(email: state.email, otp: otp);
    result.fold(
      (f) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: f.message,
          fieldErrors: _fields(f),
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          otp: otp,
          step: ForgotStep.password,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> setNewPassword(String password, String confirmation) async {
    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: null),
    );
    final result = await _resetPassword(
      email: state.email,
      otp: state.otp,
      password: password,
      passwordConfirmation: confirmation,
    );
    result.fold(
      (f) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: f.message,
          fieldErrors: _fields(f),
        ),
      ),
      (_) => emit(state.copyWith(isSubmitting: false, step: ForgotStep.done)),
    );
  }

  /// Steps back one stage (no-op on the first/last step).
  void back() {
    switch (state.step) {
      case ForgotStep.otp:
        emit(state.copyWith(step: ForgotStep.email, errorMessage: null));
      case ForgotStep.password:
        emit(state.copyWith(step: ForgotStep.otp, errorMessage: null));
      case ForgotStep.email:
      case ForgotStep.done:
        break;
    }
  }

  Map<String, List<String>>? _fields(Failure f) =>
      f is ValidationFailure ? f.fieldErrors : null;
}
