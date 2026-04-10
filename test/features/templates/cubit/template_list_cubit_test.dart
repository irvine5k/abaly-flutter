import 'package:abaly/features/templates/cubit/template_list_cubit.dart';
import 'package:abaly/features/templates/cubit/template_list_state.dart';
import 'package:abaly/features/templates/data/template_repository.dart';
import 'package:abaly/shared/models/template.dart';
import 'package:abaly/shared/models/template_field.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  late MockTemplateRepository mockTemplateRepository;

  final testTemplate = Template(
    id: 'template-1',
    name: 'Test Template',
    organizationId: 'org-1',
    fields: const [TemplateField(label: 'Attention', type: FieldType.scale)],
    createdBy: 'user-1',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  setUp(() {
    mockTemplateRepository = MockTemplateRepository();
  });

  group('TemplateListCubit', () {
    test('initial state is TemplateListInitial', () {
      final cubit = TemplateListCubit(
        templateRepository: mockTemplateRepository,
      );
      expect(cubit.state, const TemplateListInitial());
      cubit.close();
    });

    group('loadTemplates', () {
      blocTest<TemplateListCubit, TemplateListState>(
        'emits [Loading, Loaded(templates)] on success',
        build: () {
          when(
            () => mockTemplateRepository.getTemplates(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenAnswer((_) async => [testTemplate]);
          return TemplateListCubit(templateRepository: mockTemplateRepository);
        },
        act: (cubit) => cubit.loadTemplates('org-1'),
        expect: () => [
          const TemplateListLoading(),
          TemplateListLoaded([testTemplate]),
        ],
      );

      blocTest<TemplateListCubit, TemplateListState>(
        'emits [Loading, Error(message)] on failure',
        build: () {
          when(
            () => mockTemplateRepository.getTemplates(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenThrow(Exception('Network error'));
          return TemplateListCubit(templateRepository: mockTemplateRepository);
        },
        act: (cubit) => cubit.loadTemplates('org-1'),
        expect: () => [
          const TemplateListLoading(),
          isA<TemplateListError>(),
        ],
      );
    });
  });
}
