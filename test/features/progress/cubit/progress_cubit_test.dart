import 'package:abaly/features/progress/cubit/progress_cubit.dart';
import 'package:abaly/features/progress/cubit/progress_state.dart';
import 'package:abaly/features/progress/data/progress_repository.dart';
import 'package:abaly/shared/models/progress_data_point.dart';
import 'package:abaly/shared/models/template_field.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockProgressRepository;

  const frequencyField = TemplateField(
    label: 'Tantrums',
    type: FieldType.frequency,
  );
  const percentageField = TemplateField(
    label: 'Eye Contact',
    type: FieldType.percentage,
  );

  final testDataPoints = [
    ProgressDataPoint(
      sessionDate: DateTime.utc(2024, 6, 1),
      value: 3,
    ),
    ProgressDataPoint(
      sessionDate: DateTime.utc(2024, 6, 8),
      value: 5,
    ),
  ];

  setUp(() {
    mockProgressRepository = MockProgressRepository();
  });

  group('ProgressCubit', () {
    group('loadChartableFields', () {
      blocTest<ProgressCubit, ProgressState>(
        'emits [loading, loaded] with chartable fields on success',
        build: () {
          when(
            () => mockProgressRepository.getChartableFields(
              patientId: 'patient-1',
            ),
          ).thenAnswer((_) async => [frequencyField, percentageField]);
          return ProgressCubit(progressRepository: mockProgressRepository);
        },
        act: (cubit) => cubit.loadChartableFields('patient-1'),
        expect: () => [
          const ProgressState(status: ProgressStatus.loading),
          const ProgressState(
            status: ProgressStatus.loaded,
            chartableFields: [frequencyField, percentageField],
          ),
        ],
      );

      blocTest<ProgressCubit, ProgressState>(
        'emits [loading, error] on failure',
        build: () {
          when(
            () => mockProgressRepository.getChartableFields(
              patientId: 'patient-1',
            ),
          ).thenThrow(Exception('Network error'));
          return ProgressCubit(progressRepository: mockProgressRepository);
        },
        act: (cubit) => cubit.loadChartableFields('patient-1'),
        expect: () => [
          const ProgressState(status: ProgressStatus.loading),
          isA<ProgressState>()
              .having((s) => s.status, 'status', ProgressStatus.error)
              .having((s) => s.error, 'error', isNotNull),
        ],
      );
    });

    group('selectField', () {
      blocTest<ProgressCubit, ProgressState>(
        'fetches data when a field is selected',
        build: () {
          when(
            () => mockProgressRepository.getChartableFields(
              patientId: 'patient-1',
            ),
          ).thenAnswer((_) async => [frequencyField]);
          when(
            () => mockProgressRepository.getProgressData(
              patientId: 'patient-1',
              fieldLabel: 'Tantrums',
              fieldType: FieldType.frequency,
              sessionLimit: 7,
            ),
          ).thenAnswer((_) async => testDataPoints);
          return ProgressCubit(progressRepository: mockProgressRepository);
        },
        act: (cubit) async {
          await cubit.loadChartableFields('patient-1');
          await cubit.selectField(frequencyField);
        },
        expect: () => [
          // loadChartableFields
          const ProgressState(status: ProgressStatus.loading),
          const ProgressState(
            status: ProgressStatus.loaded,
            chartableFields: [frequencyField],
          ),
          // selectField -> emits selectedField
          const ProgressState(
            status: ProgressStatus.loaded,
            chartableFields: [frequencyField],
            selectedField: frequencyField,
          ),
          // _fetchData loading
          const ProgressState(
            status: ProgressStatus.loading,
            chartableFields: [frequencyField],
            selectedField: frequencyField,
          ),
          // _fetchData loaded
          ProgressState(
            status: ProgressStatus.loaded,
            chartableFields: const [frequencyField],
            selectedField: frequencyField,
            dataPoints: testDataPoints,
          ),
        ],
      );
    });

    group('setSessionFilter', () {
      blocTest<ProgressCubit, ProgressState>(
        'changes filter and re-fetches data',
        build: () {
          when(
            () => mockProgressRepository.getChartableFields(
              patientId: 'patient-1',
            ),
          ).thenAnswer((_) async => [frequencyField]);
          when(
            () => mockProgressRepository.getProgressData(
              patientId: 'patient-1',
              fieldLabel: 'Tantrums',
              fieldType: FieldType.frequency,
              sessionLimit: any(named: 'sessionLimit'),
            ),
          ).thenAnswer((_) async => testDataPoints);
          return ProgressCubit(progressRepository: mockProgressRepository);
        },
        act: (cubit) async {
          await cubit.loadChartableFields('patient-1');
          await cubit.selectField(frequencyField);
          await cubit.setSessionFilter(SessionFilter.all);
        },
        verify: (_) {
          verify(
            () => mockProgressRepository.getProgressData(
              patientId: 'patient-1',
              fieldLabel: 'Tantrums',
              fieldType: FieldType.frequency,
              sessionLimit: null,
            ),
          ).called(1);
        },
      );
    });

    group('empty states', () {
      blocTest<ProgressCubit, ProgressState>(
        'loaded with empty fields when patient has no chartable data',
        build: () {
          when(
            () => mockProgressRepository.getChartableFields(
              patientId: 'patient-1',
            ),
          ).thenAnswer((_) async => []);
          return ProgressCubit(progressRepository: mockProgressRepository);
        },
        act: (cubit) => cubit.loadChartableFields('patient-1'),
        expect: () => [
          const ProgressState(status: ProgressStatus.loading),
          const ProgressState(
            status: ProgressStatus.loaded,
            chartableFields: [],
          ),
        ],
      );
    });
  });
}
