import 'package:abaly/features/patients/data/patient_repository.dart';
import 'package:abaly/features/sessions/cubit/session_execution_cubit.dart';
import 'package:abaly/features/sessions/cubit/session_execution_state.dart';
import 'package:abaly/features/sessions/data/response_repository.dart';
import 'package:abaly/features/sessions/data/session_repository.dart';
import 'package:abaly/features/templates/data/template_repository.dart';
import 'package:abaly/shared/models/patient.dart';
import 'package:abaly/shared/models/response.dart';
import 'package:abaly/shared/models/session.dart';
import 'package:abaly/shared/models/template.dart';
import 'package:abaly/shared/models/template_field.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

class MockResponseRepository extends Mock implements ResponseRepository {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockPatientRepository extends Mock implements PatientRepository {}

// Mocktail fallback values
class FakeSessionResponse extends Fake implements SessionResponse {}

final _epoch = DateTime.utc(2024, 1, 1);

final _testTemplate = Template(
  id: 'template-1',
  name: 'ABA Template',
  organizationId: 'org-1',
  fields: [
    const TemplateField(label: 'Goal 1', type: FieldType.boolean),
    const TemplateField(label: 'Score', type: FieldType.scale),
    const TemplateField(label: 'Notes', type: FieldType.text),
  ],
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _testTemplateEmpty = Template(
  id: 'template-1',
  name: 'ABA Template',
  organizationId: 'org-1',
  fields: const [],
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _pendingSession = Session(
  id: 'session-1',
  patientId: 'patient-1',
  templateId: 'template-1',
  therapistId: 'therapist-1',
  organizationId: 'org-1',
  status: SessionStatus.pending,
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _inProgressSession = Session(
  id: 'session-1',
  patientId: 'patient-1',
  templateId: 'template-1',
  therapistId: 'therapist-1',
  organizationId: 'org-1',
  status: SessionStatus.inProgress,
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

final _existingResponse = SessionResponse(
  id: 'resp-1',
  sessionId: 'session-1',
  fieldLabel: 'Goal 1',
  fieldType: FieldType.boolean,
  value: 'true',
  updatedAt: _epoch,
);

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSessionResponse());
    registerFallbackValue(SessionStatus.completed);
  });

  late MockSessionRepository mockSessionRepository;
  late MockResponseRepository mockResponseRepository;
  late MockTemplateRepository mockTemplateRepository;
  late MockPatientRepository mockPatientRepository;

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    mockResponseRepository = MockResponseRepository();
    mockTemplateRepository = MockTemplateRepository();
    mockPatientRepository = MockPatientRepository();
  });

  SessionExecutionCubit buildCubit() => SessionExecutionCubit(
        sessionRepository: mockSessionRepository,
        responseRepository: mockResponseRepository,
        templateRepository: mockTemplateRepository,
        patientRepository: mockPatientRepository,
      );

  group('SessionExecutionCubit', () {
    test('initial state has status initial', () {
      expect(buildCubit().state.status, SessionExecutionStatus.initial);
    });

    group('loadSession', () {
      blocTest<SessionExecutionCubit, SessionExecutionState>(
        'emits [loading, loaded] with session, template, patient, responses',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _inProgressSession);
          when(() => mockPatientRepository.getPatient(id: 'patient-1'))
              .thenAnswer((_) async => _testPatient);
          when(() => mockTemplateRepository.getTemplate(id: 'template-1'))
              .thenAnswer((_) async => _testTemplate);
          when(
            () => mockResponseRepository.getResponses(sessionId: 'session-1'),
          ).thenAnswer((_) async => [_existingResponse]);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadSession('session-1'),
        expect: () => [
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loading),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loaded)
              .having((s) => s.session, 'session', _inProgressSession)
              .having((s) => s.patient, 'patient', _testPatient)
              .having((s) => s.template, 'template', _testTemplate)
              .having(
                (s) => s.responses['Goal 1']?.value,
                'response value',
                'true',
              ),
        ],
      );

      blocTest<SessionExecutionCubit, SessionExecutionState>(
        'auto-transitions pending session to in_progress on load',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _pendingSession);
          when(
            () => mockSessionRepository.updateSessionStatus(
              id: 'session-1',
              status: SessionStatus.inProgress,
              completedAt: any(named: 'completedAt'),
            ),
          ).thenAnswer((_) async => _inProgressSession);
          when(() => mockPatientRepository.getPatient(id: 'patient-1'))
              .thenAnswer((_) async => _testPatient);
          when(() => mockTemplateRepository.getTemplate(id: 'template-1'))
              .thenAnswer((_) async => _testTemplate);
          when(
            () => mockResponseRepository.getResponses(sessionId: 'session-1'),
          ).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadSession('session-1'),
        verify: (_) {
          verify(
            () => mockSessionRepository.updateSessionStatus(
              id: 'session-1',
              status: SessionStatus.inProgress,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);
        },
        expect: () => [
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loading),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loaded)
              .having(
                (s) => s.session?.status,
                'session status',
                SessionStatus.inProgress,
              ),
        ],
      );

      blocTest<SessionExecutionCubit, SessionExecutionState>(
        'emits [loading, error] when getSession throws',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: any(named: 'id')))
              .thenThrow(Exception('Network error'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadSession('session-1'),
        expect: () => [
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loading),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.error),
        ],
      );
    });

    group('updateResponse', () {
      blocTest<SessionExecutionCubit, SessionExecutionState>(
        'updates local response map when template is loaded',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _inProgressSession);
          when(() => mockPatientRepository.getPatient(id: 'patient-1'))
              .thenAnswer((_) async => _testPatient);
          when(() => mockTemplateRepository.getTemplate(id: 'template-1'))
              .thenAnswer((_) async => _testTemplate);
          when(
            () => mockResponseRepository.getResponses(sessionId: 'session-1'),
          ).thenAnswer((_) async => []);
          when(
            () => mockResponseRepository.upsertResponses(
              responses: any(named: 'responses'),
            ),
          ).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadSession('session-1');
          cubit.updateResponse('Notes', 'Test note');
        },
        expect: () => [
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loading),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loaded),
          // State emitted after updateResponse — responses map updated.
          isA<SessionExecutionState>()
              .having(
                (s) => s.responses['Notes']?.value,
                'notes value',
                'Test note',
              ),
        ],
      );
    });

    group('saveResponses', () {
      blocTest<SessionExecutionCubit, SessionExecutionState>(
        'emits [saving, saved] and calls upsertResponses',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _inProgressSession);
          when(() => mockPatientRepository.getPatient(id: 'patient-1'))
              .thenAnswer((_) async => _testPatient);
          when(() => mockTemplateRepository.getTemplate(id: 'template-1'))
              .thenAnswer((_) async => _testTemplate);
          when(
            () => mockResponseRepository.getResponses(sessionId: 'session-1'),
          ).thenAnswer((_) async => [_existingResponse]);
          when(
            () => mockResponseRepository.upsertResponses(
              responses: any(named: 'responses'),
            ),
          ).thenAnswer((_) async => [_existingResponse]);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadSession('session-1');
          await cubit.saveResponses();
        },
        expect: () => [
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loading),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loaded),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.saving),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.saved),
        ],
        verify: (_) {
          verify(
            () => mockResponseRepository.upsertResponses(
              responses: any(named: 'responses'),
            ),
          ).called(1);
        },
      );
    });

    group('completeSession', () {
      blocTest<SessionExecutionCubit, SessionExecutionState>(
        'emits [completing, completed] after saving and updating status',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _inProgressSession);
          when(() => mockPatientRepository.getPatient(id: 'patient-1'))
              .thenAnswer((_) async => _testPatient);
          when(() => mockTemplateRepository.getTemplate(id: 'template-1'))
              .thenAnswer((_) async => _testTemplateEmpty);
          when(
            () => mockResponseRepository.getResponses(sessionId: 'session-1'),
          ).thenAnswer((_) async => []);
          when(
            () => mockResponseRepository.upsertResponses(
              responses: any(named: 'responses'),
            ),
          ).thenAnswer((_) async => []);
          when(
            () => mockSessionRepository.updateSessionStatus(
              id: 'session-1',
              status: SessionStatus.completed,
              completedAt: any(named: 'completedAt'),
            ),
          ).thenAnswer((_) async => _inProgressSession.copyWith(
                status: SessionStatus.completed,
              ));
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadSession('session-1');
          await cubit.completeSession();
        },
        expect: () => [
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loading),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loaded),
          isA<SessionExecutionState>()
              .having(
                (s) => s.status,
                'status',
                SessionExecutionStatus.completing,
              ),
          isA<SessionExecutionState>()
              .having(
                (s) => s.status,
                'status',
                SessionExecutionStatus.completed,
              ),
        ],
      );

      blocTest<SessionExecutionCubit, SessionExecutionState>(
        'emits error when template fields are not all filled',
        setUp: () {
          when(() => mockSessionRepository.getSession(id: 'session-1'))
              .thenAnswer((_) async => _inProgressSession);
          when(() => mockPatientRepository.getPatient(id: 'patient-1'))
              .thenAnswer((_) async => _testPatient);
          // Template with fields but no responses provided.
          when(() => mockTemplateRepository.getTemplate(id: 'template-1'))
              .thenAnswer((_) async => _testTemplate);
          when(
            () => mockResponseRepository.getResponses(sessionId: 'session-1'),
          ).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadSession('session-1');
          await cubit.completeSession();
        },
        expect: () => [
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loading),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.loaded),
          isA<SessionExecutionState>()
              .having((s) => s.status, 'status', SessionExecutionStatus.error)
              .having((s) => s.error, 'error', isNotNull),
        ],
      );
    });
  });
}

extension on Session {
  Session copyWith({SessionStatus? status}) {
    return Session(
      id: id,
      patientId: patientId,
      templateId: templateId,
      therapistId: therapistId,
      organizationId: organizationId,
      status: status ?? this.status,
      scheduledAt: scheduledAt,
      completedAt: completedAt,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
