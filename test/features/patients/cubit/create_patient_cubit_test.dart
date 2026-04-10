import 'package:abaly/features/patients/cubit/create_patient_cubit.dart';
import 'package:abaly/features/patients/cubit/create_patient_state.dart';
import 'package:abaly/features/patients/data/patient_repository.dart';
import 'package:abaly/shared/models/patient.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

class FakePatient extends Fake implements Patient {}

void main() {
  late MockPatientRepository mockPatientRepository;

  final createdPatient = Patient(
    id: 'patient-1',
    fullName: 'Jane Smith',
    organizationId: 'org-1',
    createdBy: 'user-1',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakePatient());
  });

  setUp(() {
    mockPatientRepository = MockPatientRepository();
  });

  group('CreatePatientCubit', () {
    group('createPatient', () {
      blocTest<CreatePatientCubit, CreatePatientState>(
        'emits [Loading, Success] on success',
        build: () {
          when(
            () => mockPatientRepository.createPatient(
              patient: any(named: 'patient'),
            ),
          ).thenAnswer((_) async => createdPatient);
          return CreatePatientCubit(patientRepository: mockPatientRepository);
        },
        act: (cubit) => cubit.createPatient(
          fullName: 'Jane Smith',
          organizationId: 'org-1',
          createdBy: 'user-1',
        ),
        expect: () => [
          const CreatePatientLoading(),
          CreatePatientSuccess(createdPatient),
        ],
      );

      blocTest<CreatePatientCubit, CreatePatientState>(
        'emits [Loading, Error] on failure',
        build: () {
          when(
            () => mockPatientRepository.createPatient(
              patient: any(named: 'patient'),
            ),
          ).thenThrow(Exception('Server error'));
          return CreatePatientCubit(patientRepository: mockPatientRepository);
        },
        act: (cubit) => cubit.createPatient(
          fullName: 'Jane Smith',
          organizationId: 'org-1',
          createdBy: 'user-1',
        ),
        expect: () => [
          const CreatePatientLoading(),
          isA<CreatePatientError>(),
        ],
      );

      blocTest<CreatePatientCubit, CreatePatientState>(
        'emits [Error] without calling repo when name is empty',
        build: () => CreatePatientCubit(patientRepository: mockPatientRepository),
        act: (cubit) => cubit.createPatient(
          fullName: '   ',
          organizationId: 'org-1',
          createdBy: 'user-1',
        ),
        expect: () => [isA<CreatePatientError>()],
        verify: (_) {
          verifyNever(
            () => mockPatientRepository.createPatient(
              patient: any(named: 'patient'),
            ),
          );
        },
      );
    });
  });
}
