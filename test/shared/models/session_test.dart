import 'package:abaly/shared/models/session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionStatus', () {
    test('fromString maps snake_case correctly', () {
      expect(SessionStatus.fromString('pending'), SessionStatus.pending);
      expect(SessionStatus.fromString('in_progress'), SessionStatus.inProgress);
      expect(SessionStatus.fromString('completed'), SessionStatus.completed);
    });

    test('toJsonString produces snake_case', () {
      expect(SessionStatus.pending.toJsonString(), 'pending');
      expect(SessionStatus.inProgress.toJsonString(), 'in_progress');
      expect(SessionStatus.completed.toJsonString(), 'completed');
    });
  });

  group('Session', () {
    final json = {
      'id': 'session-1',
      'patient_id': 'patient-1',
      'template_id': 'template-1',
      'therapist_id': 'user-1',
      'organization_id': 'org-1',
      'status': 'in_progress',
      'scheduled_at': '2026-03-01T10:00:00.000Z',
      'completed_at': null,
      'created_by': 'user-1',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson creates correct instance with in_progress status', () {
      final session = Session.fromJson(json);

      expect(session.id, 'session-1');
      expect(session.status, SessionStatus.inProgress);
      expect(session.scheduledAt, DateTime.utc(2026, 3, 1, 10));
      expect(session.completedAt, isNull);
    });

    test('round-trip serialization preserves equality', () {
      final session = Session.fromJson(json);
      final roundTripped = Session.fromJson(session.toJson());

      expect(roundTripped, session);
    });

    test('toJson maps status to snake_case', () {
      final session = Session.fromJson(json);
      final result = session.toJson();

      expect(result['status'], 'in_progress');
    });

    test('handles completed session with completedAt', () {
      final completedJson = {
        ...json,
        'status': 'completed',
        'completed_at': '2026-03-01T11:00:00.000Z',
      };
      final session = Session.fromJson(completedJson);

      expect(session.status, SessionStatus.completed);
      expect(session.completedAt, isNotNull);
    });
  });
}
