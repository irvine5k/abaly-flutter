import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../shared/models/session.dart';
import 'session_repository.dart';

class SupabaseSessionRepository implements SessionRepository {
  SupabaseSessionRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<Session>> getSessions({required String organizationId}) async {
    final response = await _client
        .from('sessions')
        .select()
        .eq('organization_id', organizationId)
        .order('created_at', ascending: false);

    return response.map((json) => Session.fromJson(json)).toList();
  }

  @override
  Future<Session> getSession({required String id}) async {
    final response =
        await _client.from('sessions').select().eq('id', id).single();

    return Session.fromJson(response);
  }

  @override
  Future<Session> createSession({required Session session}) async {
    final response = await _client
        .from('sessions')
        .insert(session.toJson()..remove('id'))
        .select()
        .single();

    return Session.fromJson(response);
  }

  @override
  Future<Session> updateSessionStatus({
    required String id,
    required SessionStatus status,
    DateTime? completedAt,
  }) async {
    final updates = <String, dynamic>{
      'status': status.toJsonString(),
    };
    if (completedAt != null) {
      updates['completed_at'] = completedAt.toIso8601String();
    }

    final response = await _client
        .from('sessions')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return Session.fromJson(response);
  }
}
