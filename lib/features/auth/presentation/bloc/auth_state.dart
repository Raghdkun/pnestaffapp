import 'package:equatable/equatable.dart';
import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';

/// `unknown` is the boot state the router treats as "still deciding"; it resolves
/// to authenticated/unauthenticated after the session check.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.employee,
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors,
  });

  final AuthStatus status;
  final Employee? employee;
  final bool isSubmitting;
  final String? errorMessage;

  /// Per-field server validation errors (422), keyed by field name.
  final Map<String, List<String>>? fieldErrors;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  static const Object _unset = Object();

  AuthState copyWith({
    AuthStatus? status,
    Object? employee = _unset,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    Object? fieldErrors = _unset,
  }) {
    return AuthState(
      status: status ?? this.status,
      employee: identical(employee, _unset)
          ? this.employee
          : employee as Employee?,
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
    status,
    employee,
    isSubmitting,
    errorMessage,
    fieldErrors,
  ];
}
