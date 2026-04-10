import '../../../shared/models/app_user.dart';
import '../../../shared/models/invitation.dart';
import '../../../shared/models/organization.dart';

abstract class OrganizationRepository {
  Future<Organization> getOrganization({required String id});
  Future<List<AppUser>> getMembers({required String organizationId});
  Future<Invitation> sendInvitation({
    required String organizationId,
    required String email,
    required String invitedBy,
  });
  Future<List<Invitation>> getInvitations({required String organizationId});
}
