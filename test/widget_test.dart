import 'package:flutter/material.dart';

import 'package:abaly/features/auth/data/auth_repository.dart';
import 'package:abaly/features/organization/data/organization_repository.dart';
import 'package:abaly/features/patients/data/patient_repository.dart';
import 'package:abaly/features/progress/data/progress_repository.dart';
import 'package:abaly/features/sessions/data/response_repository.dart';
import 'package:abaly/features/sessions/data/session_repository.dart';
import 'package:abaly/features/templates/data/template_repository.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:abaly/shared/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:abaly/main.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockResponseRepository extends Mock implements ResponseRepository {}

class MockPatientRepository extends Mock implements PatientRepository {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockOrganizationRepository extends Mock
    implements OrganizationRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSessionRepository mockSessionRepository;
  late MockResponseRepository mockResponseRepository;
  late MockPatientRepository mockPatientRepository;
  late MockTemplateRepository mockTemplateRepository;
  late MockOrganizationRepository mockOrganizationRepository;
  late MockProgressRepository mockProgressRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionRepository = MockSessionRepository();
    mockResponseRepository = MockResponseRepository();
    mockPatientRepository = MockPatientRepository();
    mockTemplateRepository = MockTemplateRepository();
    mockOrganizationRepository = MockOrganizationRepository();
    mockProgressRepository = MockProgressRepository();
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const AppUser(
              id: 'user-1',
              email: 'test@example.com',
              fullName: 'Test User',
              role: UserRole.therapist,
              organizationId: 'org-1',
            ));
    when(
      () => mockSessionRepository.getSessions(
        organizationId: any(named: 'organizationId'),
      ),
    ).thenAnswer((_) async => <Session>[]);
  });

  Widget buildApp() {
    return AbalyApp(
      authRepository: mockAuthRepository,
      sessionRepository: mockSessionRepository,
      responseRepository: mockResponseRepository,
      patientRepository: mockPatientRepository,
      templateRepository: mockTemplateRepository,
      organizationRepository: mockOrganizationRepository,
      progressRepository: mockProgressRepository,
    );
  }

  testWidgets('App renders login page when unauthenticated',
      (WidgetTester tester) async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => null);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('App renders home page when authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Sessions'), findsWidgets);
    expect(find.text('Patients'), findsWidgets);
  });
}
