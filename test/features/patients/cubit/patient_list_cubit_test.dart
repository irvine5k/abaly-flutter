import 'package:abaly/features/patients/cubit/patient_list_cubit.dart';
import 'package:abaly/features/patients/cubit/patient_list_state.dart';
import 'package:abaly/features/patients/data/patient_repository.dart';
import 'package:abaly/shared/models/patient.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late MockPatientRepository mockPatientRepository;

  final testPatient = Patient(
    id: 'patient-1',
    fullName: 'John Doe',
    organizationId: 'org-1',
    createdBy: 'user-1',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  setUp(() {
    mockPatientRepository = MockPatientRepository();
  });

  group('PatientListCubit', () {
    test('initial state is PatientListInitial', () {
      final cubit = PatientListCubit(
        patientRepository: mockPatientRepository,
      );
      expect(cubit.state, const PatientListInitial());
      cubit.close();
    });

    group('loadPatients', () {
      blocTest<PatientListCubit, PatientListState>(
        'emits [Loading, Loaded(patients)] on success',
        build: () {
          when(
            () => mockPatientRepository.getPatients(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenAnswer((_) async => [testPatient]);
          return PatientListCubit(patientRepository: mockPatientRepository);
        },
        act: (cubit) => cubit.loadPatients('org-1'),
        expect: () => [
          const PatientListLoading(),
          PatientListLoaded([testPatient]),
        ],
      );

      blocTest<PatientListCubit, PatientListState>(
        'emits [Loading, Error(message)] on failure',
        build: () {
          when(
            () => mockPatientRepository.getPatients(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenThrow(Exception('Network error'));
          return PatientListCubit(patientRepository: mockPatientRepository);
        },
        act: (cubit) => cubit.loadPatients('org-1'),
        expect: () => [
          const PatientListLoading(),
          isA<PatientListError>(),
        ],
      );
    });
  });
}
