import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/create_session_cubit.dart';
import '../cubit/create_session_state.dart';

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  String? _selectedPatientId;
  String? _selectedTemplateId;
  DateTime? _scheduledAt;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<CreateSessionCubit>()
          .loadFormData(authState.user.organizationId);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _scheduledAt = picked);
    }
  }

  void _submit() {
    final patientId = _selectedPatientId;
    final templateId = _selectedTemplateId;

    if (patientId == null || templateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient and template.')),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<CreateSessionCubit>().createSession(
          patientId: patientId,
          templateId: templateId,
          therapistId: authState.user.id,
          organizationId: authState.user.organizationId,
          createdBy: authState.user.id,
          scheduledAt: _scheduledAt,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: BlocConsumer<CreateSessionCubit, CreateSessionState>(
        listener: (context, state) {
          if (state is CreateSessionSuccess) {
            context.pop(true);
          } else if (state is CreateSessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateSessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CreateSessionFormLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Patient',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPatientId,
                        hint: const Text('Select a patient'),
                        isExpanded: true,
                        items: state.patients
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedPatientId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Template',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTemplateId,
                        hint: const Text('Select a template'),
                        isExpanded: true,
                        items: state.templates
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedTemplateId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _scheduledAt == null
                          ? 'Pick scheduled date (optional)'
                          : 'Scheduled: ${_scheduledAt!.toLocal().toString().split(' ').first}',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Create Session'),
                  ),
                ],
              ),
            );
          }

          if (state is CreateSessionError) {
            return Center(child: Text(state.message));
          }

          // CreateSessionInitial — loading skeleton while awaiting initState call
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
