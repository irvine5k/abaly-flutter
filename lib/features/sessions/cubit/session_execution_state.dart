import 'package:equatable/equatable.dart';

import '../../../shared/models/patient.dart';
import '../../../shared/models/response.dart';
import '../../../shared/models/session.dart';
import '../../../shared/models/template.dart';

enum SessionExecutionStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  completing,
  completed,
  error,
}

class SessionExecutionState extends Equatable {
  const SessionExecutionState({
    this.session,
    this.patient,
    this.template,
    this.responses = const {},
    this.status = SessionExecutionStatus.initial,
    this.error,
  });

  final Session? session;
  final Patient? patient;
  final Template? template;

  /// Map of fieldLabel -> SessionResponse for all current responses.
  final Map<String, SessionResponse> responses;

  final SessionExecutionStatus status;
  final String? error;

  SessionExecutionState copyWith({
    Session? session,
    Patient? patient,
    Template? template,
    Map<String, SessionResponse>? responses,
    SessionExecutionStatus? status,
    String? error,
  }) {
    return SessionExecutionState(
      session: session ?? this.session,
      patient: patient ?? this.patient,
      template: template ?? this.template,
      responses: responses ?? this.responses,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        session,
        patient,
        template,
        responses,
        status,
        error,
      ];
}
