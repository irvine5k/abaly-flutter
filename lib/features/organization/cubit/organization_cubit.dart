import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/organization_repository.dart';
import 'organization_state.dart';

class OrganizationCubit extends Cubit<OrganizationState> {
  OrganizationCubit({required OrganizationRepository organizationRepository})
      : _organizationRepository = organizationRepository,
        super(const OrganizationState());

  final OrganizationRepository _organizationRepository;

  Future<void> loadOrganization(String organizationId) async {
    emit(state.copyWith(status: OrganizationStatus.loading));
    try {
      final org = await _organizationRepository.getOrganization(
        id: organizationId,
      );
      final members = await _organizationRepository.getMembers(
        organizationId: organizationId,
      );
      final invitations = await _organizationRepository.getInvitations(
        organizationId: organizationId,
      );

      emit(state.copyWith(
        organization: org,
        members: members,
        pendingInvitations: invitations,
        status: OrganizationStatus.loaded,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrganizationStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> sendInvitation({
    required String email,
    required String organizationId,
    required String invitedBy,
  }) async {
    emit(state.copyWith(status: OrganizationStatus.loading));
    try {
      await _organizationRepository.sendInvitation(
        organizationId: organizationId,
        email: email,
        invitedBy: invitedBy,
      );
      final invitations = await _organizationRepository.getInvitations(
        organizationId: organizationId,
      );
      emit(state.copyWith(
        pendingInvitations: invitations,
        status: OrganizationStatus.invitationSent,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrganizationStatus.invitationError,
        error: e.toString(),
      ));
    }
  }
}
