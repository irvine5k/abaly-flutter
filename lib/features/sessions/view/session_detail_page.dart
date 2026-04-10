import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/session.dart';
import '../cubit/session_detail_cubit.dart';
import '../cubit/session_detail_state.dart';

class SessionDetailPage extends StatefulWidget {
  const SessionDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<SessionDetailCubit>().loadSession(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
      ),
      body: BlocBuilder<SessionDetailCubit, SessionDetailState>(
        builder: (context, state) {
          return switch (state) {
            SessionDetailInitial() || SessionDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            SessionDetailError(:final message) => Center(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            SessionDetailLoaded(:final session, :final patient, :final template) =>
              _SessionDetailBody(
                session: session,
                patientName: patient.fullName,
                templateName: template.name,
              ),
          };
        },
      ),
    );
  }
}

class _SessionDetailBody extends StatelessWidget {
  const _SessionDetailBody({
    required this.session,
    required this.patientName,
    required this.templateName,
  });

  final Session session;
  final String patientName;
  final String templateName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailRow(
          label: 'Patient',
          value: patientName,
          textTheme: textTheme,
        ),
        const SizedBox(height: 12),
        _DetailRow(
          label: 'Template',
          value: templateName,
          textTheme: textTheme,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Status', style: textTheme.labelLarge),
            const SizedBox(width: 12),
            _StatusBadge(status: session.status),
          ],
        ),
        if (session.scheduledAt != null) ...[
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Scheduled',
            value: _formatDate(session.scheduledAt!),
            textTheme: textTheme,
          ),
        ],
        if (session.completedAt != null) ...[
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Completed',
            value: _formatDate(session.completedAt!),
            textTheme: textTheme,
          ),
        ],
        if (session.status == SessionStatus.pending ||
            session.status == SessionStatus.inProgress) ...[
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context.go('/sessions/${session.id}/execute');
            },
            child: const Text('Start Session'),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$month $day, $year at $hour:$minute $period';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(value, style: textTheme.bodyLarge),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SessionStatus.pending => ('Pending', Colors.orange),
      SessionStatus.inProgress => ('In Progress', Colors.blue),
      SessionStatus.completed => ('Completed', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
