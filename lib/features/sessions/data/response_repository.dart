import '../../../shared/models/response.dart';

abstract class ResponseRepository {
  Future<List<SessionResponse>> getResponses({required String sessionId});
  Future<SessionResponse> upsertResponse({required SessionResponse response});
  Future<List<SessionResponse>> upsertResponses({
    required List<SessionResponse> responses,
  });
}
