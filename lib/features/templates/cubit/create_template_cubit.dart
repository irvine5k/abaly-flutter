import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/template.dart';
import '../../../shared/models/template_field.dart';
import '../data/template_repository.dart';
import 'create_template_state.dart';

class CreateTemplateCubit extends Cubit<CreateTemplateState> {
  CreateTemplateCubit({required TemplateRepository templateRepository})
      : _templateRepository = templateRepository,
        super(const CreateTemplateState());

  final TemplateRepository _templateRepository;

  void addField(TemplateField field) {
    emit(state.copyWith(fields: [...state.fields, field]));
  }

  void removeField(int index) {
    final updated = List<TemplateField>.from(state.fields)..removeAt(index);
    emit(state.copyWith(fields: updated));
  }

  Future<void> createTemplate({
    required String name,
    required String organizationId,
    required String createdBy,
  }) async {
    if (name.trim().isEmpty) {
      emit(state.copyWith(
        status: CreateTemplateStatus.error,
        error: 'Template name cannot be empty',
      ));
      return;
    }

    if (state.fields.isEmpty) {
      emit(state.copyWith(
        status: CreateTemplateStatus.error,
        error: 'At least one field is required',
      ));
      return;
    }

    emit(state.copyWith(status: CreateTemplateStatus.loading));
    try {
      final template = Template(
        id: '',
        name: name.trim(),
        organizationId: organizationId,
        fields: state.fields,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      await _templateRepository.createTemplate(template: template);
      emit(state.copyWith(status: CreateTemplateStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: CreateTemplateStatus.error,
        error: e.toString(),
      ));
    }
  }
}
