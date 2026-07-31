import 'package:equatable/equatable.dart';

/// One store the employee belongs to (replicated from the hiring system).
class EmployeeStore extends Equatable {
  const EmployeeStore({
    required this.storeNumber,
    this.status,
    this.active = false,
    this.effectiveDate,
  });

  final String storeNumber;

  /// Raw hiring status: hired / rehired / OJE / resigned / terminated.
  final String? status;
  final bool active;
  final DateTime? effectiveDate;

  @override
  List<Object?> get props => [storeNumber, status, active, effectiveDate];
}

/// Domain employee (maps the LC Portal `FullEmployee`). Roles/permissions are
/// flattened to name lists for lightweight permission gating.
class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.middleName,
    this.active = false,
    this.roles = const [],
    this.permissions = const [],
    this.stores = const [],
  });

  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String fullName;

  /// True iff an active member of at least one store (hiring-derived).
  final bool active;
  final List<String> roles;
  final List<String> permissions;
  final List<EmployeeStore> stores;

  bool hasRole(String role) => roles.contains(role);

  bool hasPermission(String permission) => permissions.contains(permission);

  @override
  List<Object?> get props => [
    id,
    firstName,
    middleName,
    lastName,
    fullName,
    active,
    roles,
    permissions,
    stores,
  ];
}
