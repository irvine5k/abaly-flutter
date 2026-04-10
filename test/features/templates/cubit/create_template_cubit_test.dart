import 'package:abaly/features/templates/cubit/create_template_cubit.dart';
import 'package:abaly/features/templates/cubit/create_template_state.dart';
import 'package:abaly/features/templates/data/template_repository.dart';
import 'package:abaly/shared/models/template.dart';
import 'package:abaly/shared/models/template_field.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

// Required by mocktail to register fallback values for named parameters
class FakeTemplate extends Fake implements Template {}

void main() {
  late MockTemplateRepository mockTemplateRepository;

  const testField = TemplateField(label: 'Attention', type: FieldType.scale);
  const anotherField = TemplateField(label: 'Notes', type: FieldType.text);

  setUpAll(() {
    registerFallbackValue(FakeTemplate());
  });

  setUp(() {
    mockTemplateRepository = MockTemplateRepository();
  });

  group('CreateTemplateCubit', () {
    group('addField', () {
      blocTest<CreateTemplateCubit, CreateTemplateState>(
        'adds field to state',
        build: () =>
            CreateTemplateCubit(templateRepository: mockTemplateRepository),
        act: (cubit) => cubit.addField(testField),
        expect: () => [
          const CreateTemplateState(fields: [testField]),
        ],
      );
    });

    group('removeField', () {
      blocTest<CreateTemplateCubit, CreateTemplateState>(
        'removes field at given index from state',
        build: () =>
            CreateTemplateCubit(templateRepository: mockTemplateRepository),
        seed: () =>
            const CreateTemplateState(fields: [testField, anotherField]),
        act: (cubit) => cubit.removeField(0),
        expect: () => [
          const CreateTemplateState(fields: [anotherField]),
        ],
      );
    });

    group('createTemplate', () {
      blocTest<CreateTemplateCubit, CreateTemplateState>(
        'emits loading then success on valid input',
        build: () {
          when(
            () => mockTemplateRepository.createTemplate(
              template: any(named: 'template'),
            ),
          ).thenAnswer((_) async => Template(
                id: 'template-1',
                name: 'My Template',
                organizationId: 'org-1',
                fields: const [testField],
                createdBy: 'user-1',
                createdAt: DateTime.utc(2024, 1, 1),
              ));
          return CreateTemplateCubit(templateRepository: mockTemplateRepository);
        },
        seed: () => const CreateTemplateState(fields: [testField]),
        act: (cubit) => cubit.createTemplate(
          name: 'My Template',
          organizationId: 'org-1',
          createdBy: 'user-1',
        ),
        expect: () => [
          const CreateTemplateState(
            fields: [testField],
            status: CreateTemplateStatus.loading,
          ),
          const CreateTemplateState(
            fields: [testField],
            status: CreateTemplateStatus.success,
          ),
        ],
      );

      blocTest<CreateTemplateCubit, CreateTemplateState>(
        'emits error when name is empty',
        build: () =>
            CreateTemplateCubit(templateRepository: mockTemplateRepository),
        seed: () => const CreateTemplateState(fields: [testField]),
        act: (cubit) => cubit.createTemplate(
          name: '',
          organizationId: 'org-1',
          createdBy: 'user-1',
        ),
        expect: () => [
          const CreateTemplateState(
            fields: [testField],
            status: CreateTemplateStatus.error,
            error: 'Template name cannot be empty',
          ),
        ],
      );

      blocTest<CreateTemplateCubit, CreateTemplateState>(
        'emits error when fields list is empty',
        build: () =>
            CreateTemplateCubit(templateRepository: mockTemplateRepository),
        act: (cubit) => cubit.createTemplate(
          name: 'My Template',
          organizationId: 'org-1',
          createdBy: 'user-1',
        ),
        expect: () => [
          const CreateTemplateState(
            status: CreateTemplateStatus.error,
            error: 'At least one field is required',
          ),
        ],
      );
    });
  });
}
