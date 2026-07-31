import 'package:equatable/equatable.dart';

/// The user-facing, layer-agnostic error type carried by [Result]. Blocs pattern
/// match on the concrete subtype (Dart 3 `switch`) to render the right message.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode, super.cause});

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors});

  final Map<String, List<String>>? fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
