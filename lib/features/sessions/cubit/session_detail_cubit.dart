import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/patients/data/patient_repository.dart';
import '../../../features/sessions/data/session_repository.dart';
import '../../../features/templates/data/template_repository.dart';
import 'session_detail_state.dart';

class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit({
    required SessionRepository sessionRepository,
    required PatientRepository patientRepository,
    required TemplateRepository templateRepository,
  })  : _sessionRepository = sessionRepository,
        _patientRepository = patientRepository,
        _templateRepository = templateRepository,
        super(const SessionDetailInitial());

  final SessionRepository _sessionRepository;
  final PatientRepository _patientRepository;
  final TemplateRepository _templateRepository;

  Future<void> loadSession(String sessionId) async {
    emit(const SessionDetailLoading());
    try {
      final session = await _sessionRepository.getSession(id: sessionId);
      final patient =
          await _patientRepository.getPatient(id: session.patientId);
      final template =
          await _templateRepository.getTemplate(id: session.templateId);

      emit(
        SessionDetailLoaded(
          session: session,
          patient: patient,
          template: template,
        ),
      );
    } catch (e) {
      emit(SessionDetailError(e.toString()));
    }
  }
}
