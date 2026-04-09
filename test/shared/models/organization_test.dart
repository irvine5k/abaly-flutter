import 'package:abaly/shared/models/organization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Organization', () {
    final json = {
      'id': 'org-1',
      'name': 'Test Clinic',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson creates correct instance', () {
      final org = Organization.fromJson(json);

      expect(org.id, 'org-1');
      expect(org.name, 'Test Clinic');
      expect(org.createdAt, DateTime.utc(2026));
    });

    test('toJson produces correct map', () {
      final org = Organization.fromJson(json);
      final result = org.toJson();

      expect(result['id'], 'org-1');
      expect(result['name'], 'Test Clinic');
      expect(result['created_at'], '2026-01-01T00:00:00.000Z');
    });

    test('round-trip serialization preserves equality', () {
      final org = Organization.fromJson(json);
      final roundTripped = Organization.fromJson(org.toJson());

      expect(roundTripped, org);
    });

    test('supports value equality', () {
      final a = Organization.fromJson(json);
      final b = Organization.fromJson(json);

      expect(a, b);
    });
  });
}
