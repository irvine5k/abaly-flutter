import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/patients/data/patient_repository.dart';
import '../../../features/templates/data/template_repository.dart';
import '../../../shared/models/session.dart';
import '../data/session_repository.dart';
import 'create_session_state.dart';

class CreateSessionCubit extends Cubit<CreateSessionState> {
  CreateSessionCubit({
    required SessionRepository sessionRepository,
    required PatientRepository patientRepository,
    required TemplateRepository templateRepository,
  })  : _sessionRepository = sessionRepository,
        _patientRepository = patientRepository,
        _templateRepository = templateRepository,
        super(const CreateSessionInitial());

  final SessionRepository _sessionRepository;
  final PatientRepository _patientRepository;
  final TemplateRepository _templateRepository;

  Future<void> loadFormData(String organizationId) async {
    emit(const CreateSessionLoading());
    try {
      final patients = await _patientRepository.getPatients(
        organizationId: organizationId,
      );
      final templates = await _templateRepository.getTemplates(
        organizationId: organizationId,
      );

      emit(CreateSessionFormLoaded(patients: patients, templates: templates));
    } catch (e) {
      emit(CreateSessionError(e.toString()));
    }
  }

  Future<void> createSession({
    required String patientId,
    required String templateId,
    required String therapistId,
    required String organizationId,
    required String createdBy,
    DateTime? scheduledAt,
  }) async {
    emit(const CreateSessionLoading());
    try {
      // id and createdAt are assigned by the server; pass placeholders that
      // the repository implementation will replace on insert.
      final session = Session(
        id: '',
        patientId: patientId,
        templateId: templateId,
        therapistId: therapistId,
        organizationId: organizationId,
        status: SessionStatus.pending,
        scheduledAt: scheduledAt,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      final created = await _sessionRepository.createSession(session: session);
      emit(CreateSessionSuccess(created));
    } catch (e) {
      emit(CreateSessionError(e.toString()));
    }
  }
}
