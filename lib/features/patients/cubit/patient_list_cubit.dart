import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/patient_repository.dart';
import 'patient_list_state.dart';

class PatientListCubit extends Cubit<PatientListState> {
  PatientListCubit({required PatientRepository patientRepository})
      : _patientRepository = patientRepository,
        super(const PatientListInitial());

  final PatientRepository _patientRepository;

  Future<void> loadPatients(String organizationId) async {
    emit(const PatientListLoading());
    try {
      final patients = await _patientRepository.getPatients(
        organizationId: organizationId,
      );
      emit(PatientListLoaded(patients));
    } catch (e) {
      emit(PatientListError(e.toString()));
    }
  }
}
