import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/patient.dart';
import '../data/patient_repository.dart';
import 'create_patient_state.dart';

class CreatePatientCubit extends Cubit<CreatePatientState> {
  CreatePatientCubit({required PatientRepository patientRepository})
      : _patientRepository = patientRepository,
        super(const CreatePatientInitial());

  final PatientRepository _patientRepository;

  Future<void> createPatient({
    required String fullName,
    DateTime? dateOfBirth,
    required String organizationId,
    required String createdBy,
  }) async {
    if (fullName.trim().isEmpty) {
      emit(const CreatePatientError('Full name cannot be empty.'));
      return;
    }

    emit(const CreatePatientLoading());
    try {
      final patient = await _patientRepository.createPatient(
        patient: Patient(
          id: '',
          fullName: fullName.trim(),
          dateOfBirth: dateOfBirth,
          organizationId: organizationId,
          createdBy: createdBy,
          createdAt: DateTime.now(),
        ),
      );
      emit(CreatePatientSuccess(patient));
    } catch (e) {
      emit(CreatePatientError(e.toString()));
    }
  }
}
