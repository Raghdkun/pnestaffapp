import 'package:equatable/equatable.dart';

/// The three OTP steps plus a terminal success state.
enum ForgotStep { email, otp, password, done }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.step = ForgotStep.email,
    this.email = '',
    this.otp = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors,
  });

  final ForgotStep step;
  final String email;
  final String otp;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, List<String>>? fieldErrors;

  static const Object _unset = Object();

  ForgotPasswordState copyWith({
    ForgotStep? step,
    String? email,
    String? otp,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    Object? fieldErrors = _unset,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      fieldErrors: identical(fieldErrors, _unset)
          ? this.fieldErrors
          : fieldErrors as Map<String, List<String>>?,
    );
  }

  @override
  List<Object?> get props => [
    step,
    email,
    otp,
    isSubmitting,
    errorMessage,
    fieldErrors,
  ];
}
