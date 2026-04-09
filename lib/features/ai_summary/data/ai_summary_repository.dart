import '../../../shared/models/ai_summary.dart';

abstract class AiSummaryRepository {
  Future<AiSummary?> getSummary({required String sessionId});
  Future<AiSummary> requestSummary({required String sessionId});
}
