import 'package:abaly/features/patients/data/patient_repository.dart';
import 'package:abaly/features/sessions/cubit/create_session_cubit.dart';
import 'package:abaly/features/sessions/cubit/create_session_state.dart';
import 'package:abaly/features/sessions/data/session_repository.dart';
import 'package:abaly/features/templates/data/template_repository.dart';
import 'package:abaly/shared/models/patient.dart';
import 'package:abaly/shared/models/session.dart';
import 'package:abaly/shared/models/template.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

class MockPatientRepository extends Mock implements PatientRepository {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

class FakeSession extends Fake implements Session {}

final _fixedDate = DateTime(2026, 4, 9);

const _organizationId = 'org-1';
const _therapistId = 'therapist-1';

final _testPatients = [
  Patient(
    id: 'patient-1',
    fullName: 'Alice Smith',
    organizationId: _organizationId,
    createdBy: _therapistId,
    createdAt: _fixedDate,
  ),
];

final _testTemplates = [
  Template(
    id: 'template-1',
    name: 'ABA Basic',
    organizationId: _organizationId,
    fields: const [],
    createdBy: _therapistId,
    createdAt: _fixedDate,
  ),
];

final _testSession = Session(
  id: 'session-1',
  patientId: 'patient-1',
  templateId: 'template-1',
  therapistId: _therapistId,
  organizationId: _organizationId,
  status: SessionStatus.pending,
  createdBy: _therapistId,
  createdAt: _fixedDate,
);

void main() {
  late MockSessionRepository mockSessionRepository;
  late MockPatientRepository mockPatientRepository;
  late MockTemplateRepository mockTemplateRepository;

  setUpAll(() {
    registerFallbackValue(FakeSession());
  });

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    mockPatientRepository = MockPatientRepository();
    mockTemplateRepository = MockTemplateRepository();
  });

  CreateSessionCubit buildCubit() => CreateSessionCubit(
        sessionRepository: mockSessionRepository,
        patientRepository: mockPatientRepository,
        templateRepository: mockTemplateRepository,
      );

  group('CreateSessionCubit', () {
    test('initial state is CreateSessionInitial', () {
      expect(buildCubit().state, const CreateSessionInitial());
    });

    group('loadFormData', () {
      blocTest<CreateSessionCubit, CreateSessionState>(
        'emits [Loading, FormLoaded] on success',
        build: () {
          when(() => mockPatientRepository.getPatients(
                organizationId: any(named: 'organizationId'),
              )).thenAnswer((_) async => _testPatients);
          when(() => mockTemplateRepository.getTemplates(
                organizationId: any(named: 'organizationId'),
              )).thenAnswer((_) async => _testTemplates);
          return buildCubit();
        },
        act: (cubit) => cubit.loadFormData(_organizationId),
        expect: () => [
          const CreateSessionLoading(),
          CreateSessionFormLoaded(
            patients: _testPatients,
            templates: _testTemplates,
          ),
        ],
      );

      blocTest<CreateSessionCubit, CreateSessionState>(
        'emits [Loading, Error] when patients fetch fails',
        build: () {
          when(() => mockPatientRepository.getPatients(
                organizationId: any(named: 'organizationId'),
              )).thenThrow(Exception('Network error'));
          return buildCubit();
        },
        act: (cubit) => cubit.loadFormData(_organizationId),
        expect: () => [
          const CreateSessionLoading(),
          isA<CreateSessionError>(),
        ],
      );
    });

    group('createSession', () {
      blocTest<CreateSessionCubit, CreateSessionState>(
        'emits [Loading, Success] on successful creation',
        build: () {
          when(() => mockSessionRepository.createSession(
                session: any(named: 'session'),
              )).thenAnswer((_) async => _testSession);
          return buildCubit();
        },
        act: (cubit) => cubit.createSession(
          patientId: 'patient-1',
          templateId: 'template-1',
          therapistId: _therapistId,
          organizationId: _organizationId,
          createdBy: _therapistId,
        ),
        expect: () => [
          const CreateSessionLoading(),
          CreateSessionSuccess(_testSession),
        ],
      );

      blocTest<CreateSessionCubit, CreateSessionState>(
        'emits [Loading, Error] on repository failure',
        build: () {
          when(() => mockSessionRepository.createSession(
                session: any(named: 'session'),
              )).thenThrow(Exception('Server error'));
          return buildCubit();
        },
        act: (cubit) => cubit.createSession(
          patientId: 'patient-1',
          templateId: 'template-1',
          therapistId: _therapistId,
          organizationId: _organizationId,
          createdBy: _therapistId,
        ),
        expect: () => [
          const CreateSessionLoading(),
          isA<CreateSessionError>(),
        ],
      );

      blocTest<CreateSessionCubit, CreateSessionState>(
        'emits [Loading, Success] with scheduledAt when provided',
        build: () {
          when(() => mockSessionRepository.createSession(
                session: any(named: 'session'),
              )).thenAnswer((_) async => _testSession);
          return buildCubit();
        },
        act: (cubit) => cubit.createSession(
          patientId: 'patient-1',
          templateId: 'template-1',
          therapistId: _therapistId,
          organizationId: _organizationId,
          createdBy: _therapistId,
          scheduledAt: _fixedDate,
        ),
        expect: () => [
          const CreateSessionLoading(),
          CreateSessionSuccess(_testSession),
        ],
      );
    });
  });
}
