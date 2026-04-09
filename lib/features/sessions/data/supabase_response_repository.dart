import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/response.dart';
import 'response_repository.dart';

class SupabaseResponseRepository implements ResponseRepository {
  SupabaseResponseRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<SessionResponse>> getResponses({
    required String sessionId,
  }) async {
    final response = await _client
        .from('responses')
        .select()
        .eq('session_id', sessionId)
        .order('updated_at', ascending: false);

    return response.map((json) => SessionResponse.fromJson(json)).toList();
  }

  @override
  Future<SessionResponse> upsertResponse({
    required SessionResponse response,
  }) async {
    final result = await _client
        .from('responses')
        .upsert(response.toJson())
        .select()
        .single();

    return SessionResponse.fromJson(result);
  }

  @override
  Future<List<SessionResponse>> upsertResponses({
    required List<SessionResponse> responses,
  }) async {
    final data = responses.map((r) => r.toJson()).toList();
    final result =
        await _client.from('responses').upsert(data).select();

    return result.map((json) => SessionResponse.fromJson(json)).toList();
  }
}
