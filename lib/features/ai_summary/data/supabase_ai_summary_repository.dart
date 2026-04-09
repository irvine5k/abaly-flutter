import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/ai_summary.dart';
import 'ai_summary_repository.dart';

class SupabaseAiSummaryRepository implements AiSummaryRepository {
  SupabaseAiSummaryRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<AiSummary?> getSummary({required String sessionId}) async {
    final response = await _client
        .from('ai_summaries')
        .select()
        .eq('session_id', sessionId)
        .maybeSingle();

    if (response == null) return null;
    return AiSummary.fromJson(response);
  }

  @override
  Future<AiSummary> requestSummary({required String sessionId}) async {
    final response = await _client.functions.invoke(
      'generate-summary',
      body: {'session_id': sessionId},
    );

    return AiSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
