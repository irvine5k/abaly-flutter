import 'package:abaly/features/patients/data/patient_repository.dart';
import 'package:abaly/features/sessions/cubit/session_detail_cubit.dart';
import 'package:abaly/features/sessions/cubit/session_detail_state.dart';
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

// Top-level fixtures — DateTime is not const, so we use final.
final _epoch = DateTime.utc(2024, 1, 1);

final _testSession = Session(
  id: 'session-1',
  patientId: 'patient-1',
  templateId: 'template-1',
  therapistId: 'therapist-1',
  organizationId: 'org-1',
  status: SessionStatus.pending,
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _testPatient = Patient(
  id: 'patient-1',
  fullName: 'John Doe',
  organizationId: 'org-1',
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _testTemplate = Template(
  id: 'template-1',
  name: 'ABA Template',
  organizationId: 'org-1',
  fields: const [],
  createdBy: 'user-1',
  createdAt: _epoch,
);

void main() {
  late MockSessionRepository mockSessionRepository;
  late MockPatientRepository mockPatientRepository;
  late MockTemplateRepository mockTemplateRepository;

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    mockPatientRepository = MockPatientRepository();
    mockTemplateRepository = MockTemplateRepository();
  });

  SessionDetailCubit buildCubit() => SessionDetailCubit(
        sessionRepository: mockSessionRepository,
        patientRepository: mockPatientRepository,
        templateRepository: mockTemplateRepository,
      );

  group('SessionDetailCubit', () {
    test('initial state is SessionDetailInitial', () {
      expect(buildCubit().state, const SessionDetailInitial());
    });

    group('loadSession', () {
      blocTest<SessionDetailCubit, SessionDetailState>(
        'emits [Loading, Loaded] on success',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _testSession);
          when(() => mockPatientRepository.getPatient(id: 'patient-1'))
              .thenAnswer((_) async => _testPatient);
          when(() => mockTemplateRepository.getTemplate(id: 'template-1'))
              .thenAnswer((_) async => _testTemplate);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadSession('session-1'),
        expect: () => [
          const SessionDetailLoading(),
          SessionDetailLoaded(
            session: _testSession,
            patient: _testPatient,
            template: _testTemplate,
          ),
        ],
      );

      blocTest<SessionDetailCubit, SessionDetailState>(
        'emits [Loading, Error] when getSession throws',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: any(named: 'id')))
              .thenThrow(Exception('Network error'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadSession('session-1'),
        expect: () => [
          const SessionDetailLoading(),
          isA<SessionDetailError>(),
        ],
      );

      blocTest<SessionDetailCubit, SessionDetailState>(
        'emits [Loading, Error] when getPatient throws',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _testSession);
          when(() => mockPatientRepository.getPatient(id: any(named: 'id')))
              .thenThrow(Exception('Patient not found'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadSession('session-1'),
        expect: () => [
          const SessionDetailLoading(),
          isA<SessionDetailError>(),
        ],
      );
    });
  });
}
