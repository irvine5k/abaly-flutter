import 'package:abaly/features/sessions/cubit/session_list_cubit.dart';
import 'package:abaly/features/sessions/cubit/session_list_state.dart';
import 'package:abaly/features/sessions/data/session_repository.dart';
import 'package:abaly/shared/models/session.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late MockSessionRepository mockSessionRepository;

  final testSession = Session(
    id: 'session-1',
    patientId: 'patient-1',
    templateId: 'template-1',
    therapistId: 'therapist-1',
    organizationId: 'org-1',
    status: SessionStatus.pending,
    createdBy: 'user-1',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  setUp(() {
    mockSessionRepository = MockSessionRepository();
  });

  group('SessionListCubit', () {
    test('initial state is SessionListInitial', () {
      final cubit = SessionListCubit(
        sessionRepository: mockSessionRepository,
      );
      expect(cubit.state, const SessionListInitial());
      cubit.close();
    });

    group('loadSessions', () {
      blocTest<SessionListCubit, SessionListState>(
        'emits [Loading, Loaded(sessions)] on success',
        build: () {
          when(
            () => mockSessionRepository.getSessions(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenAnswer((_) async => [testSession]);
          return SessionListCubit(sessionRepository: mockSessionRepository);
        },
        act: (cubit) => cubit.loadSessions('org-1'),
        expect: () => [
          const SessionListLoading(),
          SessionListLoaded([testSession]),
        ],
      );

      blocTest<SessionListCubit, SessionListState>(
        'emits [Loading, Error(message)] on failure',
        build: () {
          when(
            () => mockSessionRepository.getSessions(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenThrow(Exception('Network error'));
          return SessionListCubit(sessionRepository: mockSessionRepository);
        },
        act: (cubit) => cubit.loadSessions('org-1'),
        expect: () => [
          const SessionListLoading(),
          isA<SessionListError>(),
        ],
      );
    });
  });
}

