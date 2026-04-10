import '../../../shared/models/progress_data_point.dart';
import '../../../shared/models/template_field.dart';

abstract class ProgressRepository {
  /// Returns chartable fields (frequency/percentage) available for a patient
  /// based on their completed sessions' templates.
  Future<List<TemplateField>> getChartableFields({
    required String patientId,
  });

  /// Returns data points for a specific patient + field label,
  /// ordered chronologically. [sessionLimit] caps the number of most recent
  /// sessions returned; null means all.
  Future<List<ProgressDataPoint>> getProgressData({
    required String patientId,
    required String fieldLabel,
    required FieldType fieldType,
    int? sessionLimit,
  });
}
