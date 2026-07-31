import 'package:fpdart/fpdart.dart';
import 'package:pnestaffapp/core/error/error_mapper.dart';
import 'package:pnestaffapp/core/error/exceptions.dart';
import 'package:pnestaffapp/core/error/failures.dart';

/// The canonical synchronous result: either a [Failure] or a value of `T`.
typedef Result<T> = Either<Failure, T>;

/// The canonical asynchronous result.
typedef FutureResult<T> = Future<Either<Failure, T>>;

/// Ergonomic accessors over [Result].
extension ResultX<T> on Result<T> {
  bool get isSuccess => isRight();
  bool get isFailure => isLeft();
  T? get valueOrNull => fold((_) => null, (r) => r);
  Failure? get failureOrNull => fold((l) => l, (_) => null);
}

/// Runs [task], converting any thrown [AppException] (or unknown error) into the
/// appropriate [Failure]. Repositories wrap their data-source calls with this so
/// they can stay a single expression.
FutureResult<T> guardAsync<T>(Future<T> Function() task) async {
  try {
    return Right(await task());
  } on AppException catch (e, s) {
    return Left(mapExceptionToFailure(e, s));
  } on Object catch (e, s) {
    return Left(mapExceptionToFailure(e, s));
  }
}
