import 'package:flutter/material.dart';

import '../../../shared/models/template_field.dart';
import 'boolean_field_widget.dart';
import 'frequency_field_widget.dart';
import 'percentage_field_widget.dart';
import 'scale_field_widget.dart';
import 'single_choice_field_widget.dart';
import 'text_field_widget.dart';

/// Factory widget that renders the correct input widget for a given [FieldType].
class SessionFieldBuilder extends StatelessWidget {
  const SessionFieldBuilder({
    super.key,
    required this.fieldType,
    required this.label,
    required this.value,
    required this.onChanged,
    this.options,
    this.enabled = true,
  });

  final FieldType fieldType;
  final String label;

  /// Current string value for the field.
  final String value;

  final ValueChanged<String> onChanged;

  /// Options for singleChoice fields.
  final List<String>? options;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return switch (fieldType) {
      FieldType.boolean => BooleanFieldWidget(
          label: label,
          value: value.isEmpty ? 'false' : value,
          onChanged: onChanged,
          enabled: enabled,
        ),
      FieldType.scale => ScaleFieldWidget(
          label: label,
          value: value.isEmpty ? '0' : value,
          onChanged: onChanged,
          enabled: enabled,
        ),
      FieldType.text => SessionTextFieldWidget(
          label: label,
          value: value,
          onChanged: onChanged,
          enabled: enabled,
        ),
      FieldType.singleChoice => SingleChoiceFieldWidget(
          label: label,
          value: value,
          options: options ?? [],
          onChanged: onChanged,
          enabled: enabled,
        ),
      FieldType.frequency => FrequencyFieldWidget(
          label: label,
          value: value.isEmpty ? '0' : value,
          onChanged: onChanged,
          enabled: enabled,
        ),
      FieldType.percentage => PercentageFieldWidget(
          label: label,
          value: value,
          onChanged: onChanged,
          enabled: enabled,
        ),
    };
  }
}
