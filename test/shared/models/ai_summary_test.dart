import 'package:abaly/shared/models/ai_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiSummary', () {
    final json = {
      'id': 'summary-1',
      'session_id': 'session-1',
      'summary': 'Patient showed improvement in engagement and mood.',
      'created_at': '2026-03-01T12:00:00.000Z',
    };

    test('fromJson creates correct instance', () {
      final summary = AiSummary.fromJson(json);

      expect(summary.id, 'summary-1');
      expect(summary.sessionId, 'session-1');
      expect(summary.summary,
          'Patient showed improvement in engagement and mood.');
      expect(summary.createdAt, DateTime.utc(2026, 3, 1, 12));
    });

    test('round-trip serialization preserves equality', () {
      final summary = AiSummary.fromJson(json);
      final roundTripped = AiSummary.fromJson(summary.toJson());

      expect(roundTripped, summary);
    });

    test('supports value equality', () {
      final a = AiSummary.fromJson(json);
      final b = AiSummary.fromJson(json);

      expect(a, b);
    });
  });
}
