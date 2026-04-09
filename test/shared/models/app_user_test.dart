import 'package:abaly/shared/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test('fromJson parses admin string', () {
      expect(UserRole.fromJson('admin'), UserRole.admin);
    });

    test('fromJson parses therapist string', () {
      expect(UserRole.fromJson('therapist'), UserRole.therapist);
    });

    test('toJson serializes admin to string', () {
      expect(UserRole.admin.toJson(), 'admin');
    });

    test('toJson serializes therapist to string', () {
      expect(UserRole.therapist.toJson(), 'therapist');
    });
  });

  group('AppUser', () {
    final json = {
      'id': 'user-uuid-1',
      'email': 'therapist@example.com',
      'full_name': 'Jane Smith',
      'role': 'therapist',
      'organization_id': 'org-uuid-1',
    };

    test('fromJson creates correct instance', () {
      final user = AppUser.fromJson(json);

      expect(user.id, 'user-uuid-1');
      expect(user.email, 'therapist@example.com');
      expect(user.fullName, 'Jane Smith');
      expect(user.role, UserRole.therapist);
      expect(user.organizationId, 'org-uuid-1');
    });

    test('fromJson parses admin role', () {
      final adminJson = {...json, 'role': 'admin'};
      final user = AppUser.fromJson(adminJson);

      expect(user.role, UserRole.admin);
    });

    test('toJson produces correct map', () {
      final user = AppUser.fromJson(json);
      final result = user.toJson();

      expect(result['id'], 'user-uuid-1');
      expect(result['email'], 'therapist@example.com');
      expect(result['full_name'], 'Jane Smith');
      expect(result['role'], 'therapist');
      expect(result['organization_id'], 'org-uuid-1');
    });

    test('fromJson/toJson round-trip preserves equality', () {
      final user = AppUser.fromJson(json);
      final roundTripped = AppUser.fromJson(user.toJson());

      expect(roundTripped, user);
    });

    test('instances with same values are equal', () {
      final userA = AppUser.fromJson(json);
      final userB = AppUser.fromJson(json);

      expect(userA, equals(userB));
    });

    test('instances with different ids are not equal', () {
      final userA = AppUser.fromJson(json);
      final userB = AppUser.fromJson({...json, 'id': 'user-uuid-2'});

      expect(userA, isNot(equals(userB)));
    });

    test('instances with different roles are not equal', () {
      final userA = AppUser.fromJson(json);
      final userB = AppUser.fromJson({...json, 'role': 'admin'});

      expect(userA, isNot(equals(userB)));
    });
  });
}
