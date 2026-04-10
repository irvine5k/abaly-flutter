import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/patient.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/patient_list_cubit.dart';
import '../cubit/patient_list_state.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<PatientListCubit>()
          .loadPatients(authState.user.organizationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/patients/create');
          if (result == true && mounted) {
            _loadPatients();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PatientListCubit, PatientListState>(
        builder: (context, state) {
          return switch (state) {
            PatientListInitial() => const SizedBox.shrink(),
            PatientListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            PatientListLoaded(:final patients) => patients.isEmpty
                ? const Center(child: Text('No patients found'))
                : ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      return _PatientCard(patient: patients[index]);
                    },
                  ),
            PatientListError(:final message) => Center(
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

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final dob = patient.dateOfBirth;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(patient.fullName),
        subtitle: dob != null
            ? Text(
                'DOB: ${dob.toLocal().toString().split(' ').first}',
              )
            : null,
      ),
    );
  }
}
