import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../shared/models/progress_data_point.dart';
import '../../../shared/models/session.dart';
import '../../../shared/models/template.dart';
import '../../../shared/models/template_field.dart';
import 'progress_repository.dart';

class SupabaseProgressRepository implements ProgressRepository {
  SupabaseProgressRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<TemplateField>> getChartableFields({
    required String patientId,
  }) async {
    // Get completed sessions for this patient.
    final sessionsResponse = await _client
        .from('sessions')
        .select('template_id')
        .eq('patient_id', patientId)
        .eq('status', 'completed');

    final templateIds = sessionsResponse
        .map((row) => row['template_id'] as String)
        .toSet()
        .toList();

    if (templateIds.isEmpty) return [];

    // Fetch templates.
    final templatesResponse = await _client
        .from('templates')
        .select()
        .inFilter('id', templateIds);

    final templates =
        templatesResponse.map((json) => Template.fromJson(json)).toList();

    // Extract frequency/percentage fields, deduplicating by label.
    final seen = <String>{};
    final chartableFields = <TemplateField>[];

    for (final template in templates) {
      for (final field in template.fields) {
        if ((field.type == FieldType.frequency ||
                field.type == FieldType.percentage) &&
            seen.add(field.label)) {
          chartableFields.add(field);
        }
      }
    }

    return chartableFields;
  }

  @override
  Future<List<ProgressDataPoint>> getProgressData({
    required String patientId,
    required String fieldLabel,
    required FieldType fieldType,
    int? sessionLimit,
  }) async {
    // Get completed sessions ordered by completion date (most recent first
    // for limiting, then we reverse for chronological chart order).
    var query = _client
        .from('sessions')
        .select()
        .eq('patient_id', patientId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false);

    if (sessionLimit != null) {
      query = query.limit(sessionLimit);
    }

    final sessionsResponse = await query;
    final sessions =
        sessionsResponse.map((json) => Session.fromJson(json)).toList();

    if (sessions.isEmpty) return [];

    // Fetch responses for these sessions matching the field label.
    final sessionIds = sessions.map((s) => s.id).toList();
    final responsesResponse = await _client
        .from('responses')
        .select()
        .inFilter('session_id', sessionIds)
        .eq('field_label', fieldLabel);

    // Build a map of session_id -> value.
    final responseMap = <String, String>{};
    for (final row in responsesResponse) {
      responseMap[row['session_id'] as String] = row['value'] as String;
    }

    // Build data points in chronological order.
    final dataPoints = <ProgressDataPoint>[];
    for (final session in sessions.reversed) {
      final value = responseMap[session.id];
      if (value == null) continue;

      final date = session.completedAt ?? session.createdAt;
      final numericValue = _parseValue(value, fieldType);
      if (numericValue != null) {
        dataPoints.add(
          ProgressDataPoint(sessionDate: date, value: numericValue),
        );
      }
    }

    return dataPoints;
  }

  double? _parseValue(String value, FieldType fieldType) {
    switch (fieldType) {
      case FieldType.frequency:
        return double.tryParse(value);
      case FieldType.percentage:
        try {
          final map = jsonDecode(value) as Map<String, dynamic>;
          final trials = (map['trials'] as num?)?.toDouble() ?? 0;
          final successes = (map['successes'] as num?)?.toDouble() ?? 0;
          if (trials == 0) return 0;
          return (successes / trials * 100).clamp(0, 100);
        } catch (_) {
          return null;
        }
      default:
        return null;
    }
  }
}
