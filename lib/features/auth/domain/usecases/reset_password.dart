import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/result/result.dart';
import 'package:pnestaffapp/features/auth/domain/repositories/auth_repository.dart';

@injectable
class ResetPassword {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  FutureResult<void> call({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) => _repository.resetPassword(
    email: email.trim(),
    otp: otp.trim(),
    password: password,
    passwordConfirmation: passwordConfirmation,
  );
}
