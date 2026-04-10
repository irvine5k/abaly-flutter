import 'package:equatable/equatable.dart';

import '../../../shared/models/patient.dart';
import '../../../shared/models/session.dart';
import '../../../shared/models/template.dart';

sealed class CreateSessionState extends Equatable {
  const CreateSessionState();

  @override
  List<Object?> get props => [];
}

class CreateSessionInitial extends CreateSessionState {
  const CreateSessionInitial();
}

class CreateSessionLoading extends CreateSessionState {
  const CreateSessionLoading();
}

class CreateSessionFormLoaded extends CreateSessionState {
  const CreateSessionFormLoaded({
    required this.patients,
    required this.templates,
  });

  final List<Patient> patients;
  final List<Template> templates;

  @override
  List<Object?> get props => [patients, templates];
}

class CreateSessionSuccess extends CreateSessionState {
  const CreateSessionSuccess(this.session);

  final Session session;

  @override
  List<Object?> get props => [session];
}

class CreateSessionError extends CreateSessionState {
  const CreateSessionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
