import 'package:equatable/equatable.dart';

import 'template_field.dart';

class SessionResponse extends Equatable {
  const SessionResponse({
    required this.id,
    required this.sessionId,
    required this.fieldLabel,
    required this.fieldType,
    required this.value,
    required this.updatedAt,
  });

  final String id;
  final String sessionId;
  final String fieldLabel;
  final FieldType fieldType;
  final String value;
  final DateTime updatedAt;

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      fieldLabel: json['field_label'] as String,
      fieldType: FieldType.fromString(json['field_type'] as String),
      value: json['value'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'field_label': fieldLabel,
      'field_type': fieldType.name,
      'value': value,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        fieldLabel,
        fieldType,
        value,
        updatedAt,
      ];
}
