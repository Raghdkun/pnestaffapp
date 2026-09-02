import 'package:equatable/equatable.dart';

enum TenantStatus { idle, validating, success, rejected, unverifiable }

class TenantState extends Equatable {
  const TenantState({
    this.status = TenantStatus.idle,
    this.activeDomain = 'lcportal.cloud',
  });

  final TenantStatus status;
  final String activeDomain;

  bool get isSubmitting => status == TenantStatus.validating;

  TenantState copyWith({TenantStatus? status, String? activeDomain}) {
    return TenantState(
      status: status ?? this.status,
      activeDomain: activeDomain ?? this.activeDomain,
    );
  }

  @override
  List<Object?> get props => [status, activeDomain];
}
