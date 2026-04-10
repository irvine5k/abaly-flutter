import 'package:equatable/equatable.dart';

import '../../../shared/models/patient.dart';

sealed class PatientListState extends Equatable {
  const PatientListState();

  @override
  List<Object?> get props => [];
}

class PatientListInitial extends PatientListState {
  const PatientListInitial();
}

class PatientListLoading extends PatientListState {
  const PatientListLoading();
}

class PatientListLoaded extends PatientListState {
  const PatientListLoaded(this.patients);

  final List<Patient> patients;

  @override
  List<Object?> get props => [patients];
}

class PatientListError extends PatientListState {
  const PatientListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
