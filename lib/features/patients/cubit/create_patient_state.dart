import 'package:equatable/equatable.dart';

import '../../../shared/models/patient.dart';

sealed class CreatePatientState extends Equatable {
  const CreatePatientState();

  @override
  List<Object?> get props => [];
}

class CreatePatientInitial extends CreatePatientState {
  const CreatePatientInitial();
}

class CreatePatientLoading extends CreatePatientState {
  const CreatePatientLoading();
}

class CreatePatientSuccess extends CreatePatientState {
  const CreatePatientSuccess(this.patient);

  final Patient patient;

  @override
  List<Object?> get props => [patient];
}

class CreatePatientError extends CreatePatientState {
  const CreatePatientError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
