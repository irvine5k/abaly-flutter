import '../../../shared/models/session.dart';

abstract class SessionRepository {
  Future<List<Session>> getSessions({required String organizationId});
  Future<Session> getSession({required String id});
  Future<Session> createSession({required Session session});
  Future<Session> updateSessionStatus({
    required String id,
    required SessionStatus status,
    DateTime? completedAt,
  });
}
