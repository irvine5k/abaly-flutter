import 'package:abaly/shared/models/template.dart';
import 'package:abaly/shared/models/template_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemplateField', () {
    test('fromJson creates correct instance', () {
      final field = TemplateField.fromJson({
        'label': 'Mood',
        'type': 'scale',
      });

      expect(field.label, 'Mood');
      expect(field.type, FieldType.scale);
    });

    test('round-trip serialization preserves equality', () {
      const field = TemplateField(label: 'Active', type: FieldType.boolean);
      final roundTripped = TemplateField.fromJson(field.toJson());

      expect(roundTripped, field);
    });

    test('FieldType.fromString maps all values', () {
      expect(FieldType.fromString('boolean'), FieldType.boolean);
      expect(FieldType.fromString('scale'), FieldType.scale);
      expect(FieldType.fromString('text'), FieldType.text);
    });
  });

  group('Template', () {
    final json = {
      'id': 'template-1',
      'name': 'ABA Session',
      'organization_id': 'org-1',
      'fields': [
        {'label': 'Mood', 'type': 'scale'},
        {'label': 'Engaged', 'type': 'boolean'},
        {'label': 'Notes', 'type': 'text'},
      ],
      'created_by': 'user-1',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson parses fields JSONB correctly', () {
      final template = Template.fromJson(json);

      expect(template.id, 'template-1');
      expect(template.name, 'ABA Session');
      expect(template.fields, hasLength(3));
      expect(template.fields[0].label, 'Mood');
      expect(template.fields[0].type, FieldType.scale);
      expect(template.fields[1].type, FieldType.boolean);
      expect(template.fields[2].type, FieldType.text);
    });

    test('round-trip serialization preserves equality', () {
      final template = Template.fromJson(json);
      final roundTripped = Template.fromJson(template.toJson());

      expect(roundTripped, template);
    });

    test('toJson serializes fields back to list of maps', () {
      final template = Template.fromJson(json);
      final result = template.toJson();

      expect(result['fields'], isList);
      expect((result['fields'] as List).first, isA<Map<String, dynamic>>());
    });
  });
}
