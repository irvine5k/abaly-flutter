import 'package:equatable/equatable.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/invitation.dart';
import '../../../shared/models/organization.dart';

// Sentinel value used in copyWith to distinguish "not provided" from explicit null.
const Object _sentinel = Object();

enum OrganizationStatus {
  initial,
  loading,
  loaded,
  error,
  invitationSent,
  invitationError,
}

class OrganizationState extends Equatable {
  const OrganizationState({
    this.organization,
    this.members = const [],
    this.pendingInvitations = const [],
    this.status = OrganizationStatus.initial,
    this.error,
  });

  final Organization? organization;
  final List<AppUser> members;
  final List<Invitation> pendingInvitations;
  final OrganizationStatus status;
  final String? error;

  OrganizationState copyWith({
    Organization? organization,
    List<AppUser>? members,
    List<Invitation>? pendingInvitations,
    OrganizationStatus? status,
    Object? error = _sentinel,
  }) {
    return OrganizationState(
      organization: organization ?? this.organization,
      members: members ?? this.members,
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      status: status ?? this.status,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        organization,
        members,
        pendingInvitations,
        status,
        error,
      ];
}
