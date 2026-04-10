import 'package:abaly/shared/models/template_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FieldType', () {
    test('fromString parses all values', () {
      expect(FieldType.fromString('boolean'), FieldType.boolean);
      expect(FieldType.fromString('scale'), FieldType.scale);
      expect(FieldType.fromString('text'), FieldType.text);
      expect(FieldType.fromString('singleChoice'), FieldType.singleChoice);
      expect(FieldType.fromString('frequency'), FieldType.frequency);
      expect(FieldType.fromString('percentage'), FieldType.percentage);
    });
  });

  group('TemplateField', () {
    test('fromJson/toJson round-trip without options', () {
      const field = TemplateField(label: 'Attention', type: FieldType.scale);
      final json = field.toJson();
      final restored = TemplateField.fromJson(json);

      expect(restored, equals(field));
      expect(json.containsKey('options'), isFalse);
    });

    test('fromJson/toJson round-trip with options', () {
      const field = TemplateField(
        label: 'Behavior',
        type: FieldType.singleChoice,
        options: ['Always', 'Sometimes', 'Never'],
      );
      final json = field.toJson();
      final restored = TemplateField.fromJson(json);

      expect(restored, equals(field));
      expect(json['options'], ['Always', 'Sometimes', 'Never']);
    });

    test('fromJson handles missing options key', () {
      final json = {'label': 'Count', 'type': 'frequency'};
      final field = TemplateField.fromJson(json);

      expect(field.label, 'Count');
      expect(field.type, FieldType.frequency);
      expect(field.options, isNull);
    });

    test('toJson omits options when null', () {
      const field = TemplateField(label: 'Notes', type: FieldType.text);
      final json = field.toJson();

      expect(json.containsKey('options'), isFalse);
    });

    test('equality considers options', () {
      const field1 = TemplateField(
        label: 'X',
        type: FieldType.singleChoice,
        options: ['A', 'B'],
      );
      const field2 = TemplateField(
        label: 'X',
        type: FieldType.singleChoice,
        options: ['A', 'B'],
      );
      const field3 = TemplateField(
        label: 'X',
        type: FieldType.singleChoice,
        options: ['A', 'C'],
      );

      expect(field1, equals(field2));
      expect(field1, isNot(equals(field3)));
    });
  });
}
