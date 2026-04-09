import 'package:equatable/equatable.dart';

enum FieldType {
  boolean,
  scale,
  text;

  static FieldType fromString(String value) {
    return FieldType.values.firstWhere(
      (e) => e.name == value,
    );
  }
}

class TemplateField extends Equatable {
  const TemplateField({
    required this.label,
    required this.type,
  });

  final String label;
  final FieldType type;

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      label: json['label'] as String,
      type: FieldType.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'type': type.name,
    };
  }

  @override
  List<Object?> get props => [label, type];
}
