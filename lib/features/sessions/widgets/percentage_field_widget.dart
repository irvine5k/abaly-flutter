import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PercentageFieldWidget extends StatefulWidget {
  const PercentageFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;

  /// JSON string: {"trials": int, "successes": int}
  final String value;

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<PercentageFieldWidget> createState() => _PercentageFieldWidgetState();
}

class _PercentageFieldWidgetState extends State<PercentageFieldWidget> {
  late final TextEditingController _trialsController;
  late final TextEditingController _successesController;

  @override
  void initState() {
    super.initState();
    final parsed = _parseValue(widget.value);
    _trialsController =
        TextEditingController(text: parsed.trials.toString());
    _successesController =
        TextEditingController(text: parsed.successes.toString());
  }

  @override
  void didUpdateWidget(PercentageFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final parsed = _parseValue(widget.value);
      final currentTrials = int.tryParse(_trialsController.text) ?? 0;
      final currentSuccesses =
          int.tryParse(_successesController.text) ?? 0;
      if (parsed.trials != currentTrials) {
        _trialsController.text = parsed.trials.toString();
      }
      if (parsed.successes != currentSuccesses) {
        _successesController.text = parsed.successes.toString();
      }
    }
  }

  ({int trials, int successes}) _parseValue(String value) {
    if (value.isEmpty) return (trials: 0, successes: 0);
    try {
      final map = jsonDecode(value) as Map<String, dynamic>;
      return (
        trials: (map['trials'] as num?)?.toInt() ?? 0,
        successes: (map['successes'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return (trials: 0, successes: 0);
    }
  }

  void _emitValue() {
    final trials = int.tryParse(_trialsController.text) ?? 0;
    final successes = int.tryParse(_successesController.text) ?? 0;
    widget.onChanged(
      jsonEncode({'trials': trials, 'successes': successes}),
    );
  }

  double get _percentage {
    final trials = int.tryParse(_trialsController.text) ?? 0;
    final successes = int.tryParse(_successesController.text) ?? 0;
    if (trials == 0) return 0;
    return (successes / trials * 100).clamp(0, 100);
  }

  @override
  void dispose() {
    _trialsController.dispose();
    _successesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label,
                style: Theme.of(context).textTheme.bodyLarge),
            Text(
              '${_percentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _trialsController,
                decoration: const InputDecoration(
                  labelText: 'Trials',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: widget.enabled,
                onChanged: (_) {
                  setState(() {});
                  _emitValue();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _successesController,
                decoration: const InputDecoration(
                  labelText: 'Successes',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: widget.enabled,
                onChanged: (_) {
                  setState(() {});
                  _emitValue();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
