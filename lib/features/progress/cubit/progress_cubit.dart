import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/template_field.dart';
import '../data/progress_repository.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository,
        super(const ProgressState());

  final ProgressRepository _progressRepository;

  String? _patientId;

  Future<void> loadChartableFields(String patientId) async {
    _patientId = patientId;
    emit(state.copyWith(status: ProgressStatus.loading));
    try {
      final fields = await _progressRepository.getChartableFields(
        patientId: patientId,
      );
      emit(state.copyWith(
        status: ProgressStatus.loaded,
        chartableFields: fields,
        dataPoints: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProgressStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> selectField(TemplateField field) async {
    emit(state.copyWith(selectedField: field));
    await _fetchData();
  }

  Future<void> setSessionFilter(SessionFilter filter) async {
    emit(state.copyWith(sessionFilter: filter));
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final field = state.selectedField;
    if (field == null || _patientId == null) return;

    emit(state.copyWith(status: ProgressStatus.loading));
    try {
      final sessionLimit = switch (state.sessionFilter) {
        SessionFilter.last7 => 7,
        SessionFilter.last30 => 30,
        SessionFilter.all => null,
      };

      final dataPoints = await _progressRepository.getProgressData(
        patientId: _patientId!,
        fieldLabel: field.label,
        fieldType: field.type,
        sessionLimit: sessionLimit,
      );

      emit(state.copyWith(
        status: ProgressStatus.loaded,
        dataPoints: dataPoints,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProgressStatus.error,
        error: e.toString(),
      ));
    }
  }
}
