import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/result/result.dart';
import 'package:pnestaffapp/features/auth/domain/repositories/auth_repository.dart';

@injectable
class VerifyResetOtp {
  const VerifyResetOtp(this._repository);

  final AuthRepository _repository;

  FutureResult<void> call({required String email, required String otp}) =>
      _repository.verifyResetOtp(email: email.trim(), otp: otp.trim());
}
