import 'package:pnestaffapp/features/auth/domain/entities/employee.dart';

/// Parses the LC Portal `FullEmployee`. Hand-written (not json_serializable)
/// because we flatten nested `global_roles[]` / `all_permissions[]` to name
/// lists and shape `stores[]` into [EmployeeStore].
class EmployeeModel {
  const EmployeeModel({
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

  /// From the API `FullEmployee` payload.
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: _asInt(json['id']),
      firstName: (json['first_name'] ?? '') as String,
      middleName: json['middle_name'] as String?,
      lastName: (json['last_name'] ?? '') as String,
      fullName: (json['full_name'] as String?) ?? _compose(json),
      active: (json['active'] as bool?) ?? false,
      roles: _names(json['global_roles']),
      permissions: _names(
        json['all_permissions'] ?? json['global_permissions'],
      ),
      stores: _stores(json['stores']),
    );
  }

  /// From the flat cache shape produced by [toCacheJson].
  factory EmployeeModel.fromCacheJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: _asInt(json['id']),
      firstName: (json['first_name'] ?? '') as String,
      middleName: json['middle_name'] as String?,
      lastName: (json['last_name'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
      active: (json['active'] as bool?) ?? false,
      roles: _stringList(json['roles']),
      permissions: _stringList(json['permissions']),
      stores:
          (json['stores'] as List?)
              ?.map((e) => _storeFrom(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String fullName;
  final bool active;
  final List<String> roles;
  final List<String> permissions;
  final List<EmployeeStore> stores;

  Map<String, dynamic> toCacheJson() => {
    'id': id,
    'first_name': firstName,
    'middle_name': middleName,
    'last_name': lastName,
    'full_name': fullName,
    'active': active,
    'roles': roles,
    'permissions': permissions,
    'stores': stores
        .map(
          (s) => {
            'store_number': s.storeNumber,
            'status': s.status,
            'active': s.active,
            'effective_date': s.effectiveDate?.toIso8601String(),
          },
        )
        .toList(),
  };

  Employee toEntity() => Employee(
    id: id,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    fullName: fullName,
    active: active,
    roles: roles,
    permissions: permissions,
    stores: stores,
  );

  static int _asInt(Object? v) =>
      v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

  static DateTime? _asDate(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

  static String _compose(Map<String, dynamic> json) => [
    json['first_name'],
    json['middle_name'],
    json['last_name'],
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  static List<String> _stringList(Object? v) =>
      v is List ? v.map((e) => '$e').toList() : const [];

  static List<String> _names(Object? v) {
    if (v is! List) return const [];
    final names = <String>[];
    for (final item in v) {
      if (item is Map && item['name'] is String) {
        names.add(item['name'] as String);
      } else if (item is String) {
        names.add(item);
      }
    }
    return names;
  }

  static List<EmployeeStore> _stores(Object? v) {
    if (v is! List) return const [];
    return v
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => _storeFrom(Map<String, dynamic>.from(e)))
        .toList();
  }

  static EmployeeStore _storeFrom(Map<String, dynamic> json) => EmployeeStore(
    storeNumber: (json['store_number'] ?? '') as String,
    status: json['status'] as String?,
    active: (json['active'] as bool?) ?? false,
    effectiveDate: _asDate(json['effective_date']),
  );
}
