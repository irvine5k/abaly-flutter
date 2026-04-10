import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/template_repository.dart';
import 'template_list_state.dart';

class TemplateListCubit extends Cubit<TemplateListState> {
  TemplateListCubit({required TemplateRepository templateRepository})
      : _templateRepository = templateRepository,
        super(const TemplateListInitial());

  final TemplateRepository _templateRepository;

  Future<void> loadTemplates(String organizationId) async {
    emit(const TemplateListLoading());
    try {
      final templates = await _templateRepository.getTemplates(
        organizationId: organizationId,
      );
      emit(TemplateListLoaded(templates));
    } catch (e) {
      emit(TemplateListError(e.toString()));
    }
  }
}
