import 'package:equatable/equatable.dart';

import '../../../shared/models/patient.dart';
import '../../../shared/models/session.dart';
import '../../../shared/models/template.dart';

sealed class SessionDetailState extends Equatable {
  const SessionDetailState();

  @override
  List<Object?> get props => [];
}

class SessionDetailInitial extends SessionDetailState {
  const SessionDetailInitial();
}

class SessionDetailLoading extends SessionDetailState {
  const SessionDetailLoading();
}

class SessionDetailLoaded extends SessionDetailState {
  const SessionDetailLoaded({
    required this.session,
    required this.patient,
    required this.template,
  });

  final Session session;
  final Patient patient;
  final Template template;

  @override
  List<Object?> get props => [session, patient, template];
}

class SessionDetailError extends SessionDetailState {
  const SessionDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
