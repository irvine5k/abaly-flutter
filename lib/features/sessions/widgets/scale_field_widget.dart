import 'package:flutter/material.dart';

class ScaleFieldWidget extends StatelessWidget {
  const ScaleFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;

  /// Numeric value as a string (e.g. '0', '3', '5').
  final String value;

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final sliderValue = double.tryParse(value) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text(
              sliderValue.toInt().toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Slider(
          value: sliderValue,
          min: 0,
          max: 5,
          divisions: 5,
          label: sliderValue.toInt().toString(),
          onChanged: enabled
              ? (v) => onChanged(v.toInt().toString())
              : null,
        ),
      ],
    );
  }
}
