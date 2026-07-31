import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/result/result.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';
import 'package:pnestaffapp/features/auth/domain/repositories/auth_repository.dart';

@injectable
class GetProfile {
  const GetProfile(this._repository);

  final AuthRepository _repository;

  FutureResult<Employee> call() => _repository.getProfile();
}
