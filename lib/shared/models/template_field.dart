import 'package:equatable/equatable.dart';

enum FieldType {
  boolean,
  scale,
  text,
  singleChoice,
  frequency,
  percentage;

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
    this.options,
  });

  final String label;
  final FieldType type;
  final List<String>? options;

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      label: json['label'] as String,
      type: FieldType.fromString(json['type'] as String),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'label': label,
      'type': type.name,
    };
    if (options != null) {
      map['options'] = options;
    }
    return map;
  }

  @override
  List<Object?> get props => [label, type, options];
}
