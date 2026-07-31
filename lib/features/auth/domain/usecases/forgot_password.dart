import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/result/result.dart';
import 'package:pnestaffapp/features/auth/domain/repositories/auth_repository.dart';

@injectable
class ForgotPassword {
  const ForgotPassword(this._repository);

  final AuthRepository _repository;

  FutureResult<void> call({required String email}) =>
      _repository.forgotPassword(email: email.trim());
}
