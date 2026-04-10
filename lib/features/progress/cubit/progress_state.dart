import 'package:equatable/equatable.dart';

import '../../../shared/models/progress_data_point.dart';
import '../../../shared/models/template_field.dart';

enum ProgressStatus { initial, loading, loaded, error }

enum SessionFilter { last7, last30, all }

class ProgressState extends Equatable {
  const ProgressState({
    this.status = ProgressStatus.initial,
    this.chartableFields = const [],
    this.selectedField,
    this.sessionFilter = SessionFilter.last7,
    this.dataPoints = const [],
    this.error,
  });

  final ProgressStatus status;
  final List<TemplateField> chartableFields;
  final TemplateField? selectedField;
  final SessionFilter sessionFilter;
  final List<ProgressDataPoint> dataPoints;
  final String? error;

  ProgressState copyWith({
    ProgressStatus? status,
    List<TemplateField>? chartableFields,
    TemplateField? selectedField,
    SessionFilter? sessionFilter,
    List<ProgressDataPoint>? dataPoints,
    String? error,
  }) {
    return ProgressState(
      status: status ?? this.status,
      chartableFields: chartableFields ?? this.chartableFields,
      selectedField: selectedField ?? this.selectedField,
      sessionFilter: sessionFilter ?? this.sessionFilter,
      dataPoints: dataPoints ?? this.dataPoints,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chartableFields,
        selectedField,
        sessionFilter,
        dataPoints,
        error,
      ];
}
