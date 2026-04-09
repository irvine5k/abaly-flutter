import 'package:abaly/shared/models/response.dart';
import 'package:abaly/shared/models/template_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionResponse', () {
    final json = {
      'id': 'resp-1',
      'session_id': 'session-1',
      'field_label': 'Mood',
      'field_type': 'scale',
      'value': '4',
      'updated_at': '2026-03-01T10:30:00.000Z',
    };

    test('fromJson creates correct instance', () {
      final response = SessionResponse.fromJson(json);

      expect(response.id, 'resp-1');
      expect(response.sessionId, 'session-1');
      expect(response.fieldLabel, 'Mood');
      expect(response.fieldType, FieldType.scale);
      expect(response.value, '4');
    });

    test('round-trip serialization preserves equality', () {
      final response = SessionResponse.fromJson(json);
      final roundTripped = SessionResponse.fromJson(response.toJson());

      expect(roundTripped, response);
    });

    test('handles boolean field type', () {
      final boolJson = {
        ...json,
        'field_label': 'Engaged',
        'field_type': 'boolean',
        'value': 'true',
      };
      final response = SessionResponse.fromJson(boolJson);

      expect(response.fieldType, FieldType.boolean);
      expect(response.value, 'true');
    });

    test('handles text field type', () {
      final textJson = {
        ...json,
        'field_label': 'Notes',
        'field_type': 'text',
        'value': 'Patient was cooperative today.',
      };
      final response = SessionResponse.fromJson(textJson);

      expect(response.fieldType, FieldType.text);
      expect(response.value, 'Patient was cooperative today.');
    });
  });
}
