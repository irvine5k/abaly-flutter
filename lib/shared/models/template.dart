import 'package:equatable/equatable.dart';

import 'template_field.dart';

class Template extends Equatable {
  const Template({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.fields,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String organizationId;
  final List<TemplateField> fields;
  final String createdBy;
  final DateTime createdAt;

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organization_id'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'organization_id': organizationId,
      'fields': fields.map((e) => e.toJson()).toList(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, organizationId, fields, createdBy, createdAt];
}
