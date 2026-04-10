import 'package:flutter/material.dart';

class FrequencyFieldWidget extends StatelessWidget {
  const FrequencyFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;

  /// Integer count as a string (e.g. '0', '5').
  final String value;

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final count = int.tryParse(value) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton.filled(
              onPressed: enabled && count > 0
                  ? () => onChanged((count - 1).toString())
                  : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              onPressed: enabled
                  ? () => onChanged((count + 1).toString())
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
