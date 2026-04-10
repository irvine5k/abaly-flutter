import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../shared/models/app_user.dart';
import '../../../shared/models/invitation.dart';
import '../../../shared/models/organization.dart';
import 'organization_repository.dart';

class SupabaseOrganizationRepository implements OrganizationRepository {
  SupabaseOrganizationRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<Organization> getOrganization({required String id}) async {
    final response = await _client
        .from('organizations')
        .select()
        .eq('id', id)
        .single();

    return Organization.fromJson(response);
  }

  @override
  Future<List<AppUser>> getMembers({required String organizationId}) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('organization_id', organizationId)
        .order('full_name', ascending: true);

    return response.map((json) => AppUser.fromJson(json)).toList();
  }

  @override
  Future<Invitation> sendInvitation({
    required String organizationId,
    required String email,
    required String invitedBy,
  }) async {
    final response = await _client
        .from('invitations')
        .insert({
          'organization_id': organizationId,
          'email': email,
          'invited_by': invitedBy,
          'role': 'therapist',
          'status': 'pending',
        })
        .select()
        .single();

    return Invitation.fromJson(response);
  }

  @override
  Future<List<Invitation>> getInvitations({
    required String organizationId,
  }) async {
    final response = await _client
        .from('invitations')
        .select()
        .eq('organization_id', organizationId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return response.map((json) => Invitation.fromJson(json)).toList();
  }
}
