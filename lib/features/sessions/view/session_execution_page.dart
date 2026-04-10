import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/session_execution_cubit.dart';
import '../cubit/session_execution_state.dart';
import '../widgets/session_field_builder.dart';

class SessionExecutionPage extends StatefulWidget {
  const SessionExecutionPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<SessionExecutionPage> createState() => _SessionExecutionPageState();
}

class _SessionExecutionPageState extends State<SessionExecutionPage> {
  @override
  void initState() {
    super.initState();
    context.read<SessionExecutionCubit>().loadSession(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionExecutionCubit, SessionExecutionState>(
      listenWhen: (prev, curr) =>
          curr.status == SessionExecutionStatus.completed ||
          (curr.status == SessionExecutionStatus.error &&
              prev.status == SessionExecutionStatus.completing),
      listener: (context, state) {
        if (state.status == SessionExecutionStatus.completed) {
          Navigator.of(context).pop();
        } else if (state.status == SessionExecutionStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.patient?.fullName ?? 'Session'),
            actions: [
              _SaveIndicator(status: state.status),
              const SizedBox(width: 8),
            ],
          ),
          body: switch (state.status) {
            SessionExecutionStatus.initial ||
            SessionExecutionStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            SessionExecutionStatus.error
                when state.session == null =>
              Center(
                child: Text(
                  state.error ?? 'Failed to load session',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            _ => _SessionExecutionBody(state: state),
          },
        );
      },
    );
  }
}

class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({required this.status});

  final SessionExecutionStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SessionExecutionStatus.saving => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 6),
            Text('Saving...', style: TextStyle(fontSize: 12)),
          ],
        ),
      SessionExecutionStatus.saved => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: Colors.green),
            SizedBox(width: 4),
            Text('Saved', style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SessionExecutionBody extends StatelessWidget {
  const _SessionExecutionBody({required this.state});

  final SessionExecutionState state;

  bool get _isReadOnly =>
      state.status == SessionExecutionStatus.completed ||
      state.status == SessionExecutionStatus.completing;

  @override
  Widget build(BuildContext context) {
    final template = state.template;
    if (template == null) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: template.fields.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final field = template.fields[index];
              final response = state.responses[field.label];
              final currentValue = response?.value ?? '';

              return SessionFieldBuilder(
                fieldType: field.type,
                label: field.label,
                value: currentValue,
                options: field.options,
                enabled: !_isReadOnly,
                onChanged: (value) {
                  context
                      .read<SessionExecutionCubit>()
                      .updateResponse(field.label, value);
                },
              );
            },
          ),
        ),
        if (!_isReadOnly)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    state.status == SessionExecutionStatus.completing
                        ? null
                        : () => _confirmComplete(context),
                child: state.status == SessionExecutionStatus.completing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Complete Session'),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmComplete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete Session'),
        content: const Text(
          'Are you sure you want to complete this session? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SessionExecutionCubit>().completeSession();
    }
  }
}
