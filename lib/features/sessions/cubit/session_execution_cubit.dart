import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/patients/data/patient_repository.dart';
import '../../../features/templates/data/template_repository.dart';
import '../../../shared/models/response.dart';
import '../../../shared/models/session.dart';
import '../data/response_repository.dart';
import '../data/session_repository.dart';
import 'session_execution_state.dart';

class SessionExecutionCubit extends Cubit<SessionExecutionState> {
  SessionExecutionCubit({
    required SessionRepository sessionRepository,
    required ResponseRepository responseRepository,
    required TemplateRepository templateRepository,
    required PatientRepository patientRepository,
  })  : _sessionRepository = sessionRepository,
        _responseRepository = responseRepository,
        _templateRepository = templateRepository,
        _patientRepository = patientRepository,
        super(const SessionExecutionState());

  final SessionRepository _sessionRepository;
  final ResponseRepository _responseRepository;
  final TemplateRepository _templateRepository;
  final PatientRepository _patientRepository;

  Timer? _debounceTimer;

  Future<void> loadSession(String sessionId) async {
    emit(state.copyWith(status: SessionExecutionStatus.loading));
    try {
      var session = await _sessionRepository.getSession(id: sessionId);

      // Auto-transition pending session to in_progress.
      if (session.status == SessionStatus.pending) {
        session = await _sessionRepository.updateSessionStatus(
          id: session.id,
          status: SessionStatus.inProgress,
        );
      }

      final patient = await _patientRepository.getPatient(id: session.patientId);
      final template = await _templateRepository.getTemplate(id: session.templateId);
      final existingResponses =
          await _responseRepository.getResponses(sessionId: sessionId);

      // Build a map of fieldLabel -> SessionResponse from existing DB responses.
      final responsesMap = <String, SessionResponse>{
        for (final r in existingResponses) r.fieldLabel: r,
      };

      emit(
        state.copyWith(
          session: session,
          patient: patient,
          template: template,
          responses: responsesMap,
          status: SessionExecutionStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SessionExecutionStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  void updateResponse(String fieldLabel, String value) {
    final template = state.template;
    if (template == null) return;

    final field = template.fields.firstWhere((f) => f.label == fieldLabel);
    final existing = state.responses[fieldLabel];

    final updated = existing != null
        ? SessionResponse(
            id: existing.id,
            sessionId: state.session!.id,
            fieldLabel: fieldLabel,
            fieldType: field.type,
            value: value,
            updatedAt: DateTime.now(),
          )
        : SessionResponse(
            // Use a timestamp-based placeholder id; DB upsert on (session_id,
            // field_label) unique constraint handles insert vs update.
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            sessionId: state.session!.id,
            fieldLabel: fieldLabel,
            fieldType: field.type,
            value: value,
            updatedAt: DateTime.now(),
          );

    final updatedResponses = Map<String, SessionResponse>.from(state.responses)
      ..[fieldLabel] = updated;

    emit(state.copyWith(responses: updatedResponses));

    // Debounced autosave — cancel any pending timer and start a new one.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), saveResponses);
  }

  Future<void> saveResponses() async {
    if (state.responses.isEmpty) return;

    emit(state.copyWith(status: SessionExecutionStatus.saving));
    try {
      await _responseRepository.upsertResponses(
        responses: state.responses.values.toList(),
      );
      emit(state.copyWith(status: SessionExecutionStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          status: SessionExecutionStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> completeSession() async {
    final session = state.session;
    final template = state.template;
    if (session == null || template == null) return;

    // Validate all template fields have a response.
    final missingFields = template.fields
        .where((f) => !state.responses.containsKey(f.label))
        .toList();

    if (missingFields.isNotEmpty) {
      emit(
        state.copyWith(
          status: SessionExecutionStatus.error,
          error:
              'Please fill in all fields before completing the session.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: SessionExecutionStatus.completing));
    try {
      // Force-save all responses before marking complete.
      await _responseRepository.upsertResponses(
        responses: state.responses.values.toList(),
      );

      final now = DateTime.now();
      await _sessionRepository.updateSessionStatus(
        id: session.id,
        status: SessionStatus.completed,
        completedAt: now,
      );

      emit(state.copyWith(status: SessionExecutionStatus.completed));
    } catch (e) {
      emit(
        state.copyWith(
          status: SessionExecutionStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
