import 'package:flutter/material.dart';

class SessionTextFieldWidget extends StatefulWidget {
  const SessionTextFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<SessionTextFieldWidget> createState() => _SessionTextFieldWidgetState();
}

class _SessionTextFieldWidgetState extends State<SessionTextFieldWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SessionTextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if the value changed externally (e.g. from a load)
    // and does not match what the user is currently typing.
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }
}
