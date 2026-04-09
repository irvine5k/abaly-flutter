import 'package:abaly/shared/models/patient.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Patient', () {
    final json = {
      'id': 'patient-1',
      'full_name': 'John Doe',
      'date_of_birth': '1990-05-15T00:00:00.000Z',
      'organization_id': 'org-1',
      'created_by': 'user-1',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson creates correct instance', () {
      final patient = Patient.fromJson(json);

      expect(patient.id, 'patient-1');
      expect(patient.fullName, 'John Doe');
      expect(patient.dateOfBirth, DateTime.utc(1990, 5, 15));
      expect(patient.organizationId, 'org-1');
      expect(patient.createdBy, 'user-1');
    });

    test('fromJson handles null dateOfBirth', () {
      final jsonNoDob = {...json, 'date_of_birth': null};
      final patient = Patient.fromJson(jsonNoDob);

      expect(patient.dateOfBirth, isNull);
    });

    test('round-trip serialization preserves equality', () {
      final patient = Patient.fromJson(json);
      final roundTripped = Patient.fromJson(patient.toJson());

      expect(roundTripped, patient);
    });

    test('toJson includes null dateOfBirth', () {
      final jsonNoDob = {...json, 'date_of_birth': null};
      final patient = Patient.fromJson(jsonNoDob);
      final result = patient.toJson();

      expect(result['date_of_birth'], isNull);
    });
  });
}
