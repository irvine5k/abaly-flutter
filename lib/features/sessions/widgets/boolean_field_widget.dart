import 'package:flutter/material.dart';

class BooleanFieldWidget extends StatelessWidget {
  const BooleanFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;

  /// 'true' or 'false' as a string.
  final String value;

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isChecked = value == 'true';

    return SwitchListTile(
      title: Text(label),
      value: isChecked,
      onChanged: enabled ? (v) => onChanged(v.toString()) : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}
