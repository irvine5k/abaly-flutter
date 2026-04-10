import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/session.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/session_list_cubit.dart';
import '../cubit/session_list_state.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<SessionListCubit>()
          .loadSessions(authState.user.organizationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/sessions/create'),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<SessionListCubit, SessionListState>(
        builder: (context, state) {
          return switch (state) {
            SessionListInitial() => const SizedBox.shrink(),
            SessionListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            SessionListLoaded(:final sessions) => sessions.isEmpty
                ? const Center(child: Text('No sessions found'))
                : ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return _SessionCard(
                        session: session,
                        onTap: () => context.go('/sessions/${session.id}'),
                      );
                    },
                  ),
            SessionListError(:final message) => Center(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          };
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onTap,
  });

  final Session session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text('Patient: ${session.patientId}'),
        subtitle: Text('Template: ${session.templateId}'),
        trailing: _StatusBadge(status: session.status),
        isThreeLine: false,
      ),
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

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
