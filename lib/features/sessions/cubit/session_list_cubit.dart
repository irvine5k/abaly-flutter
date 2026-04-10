import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/session_repository.dart';
import 'session_list_state.dart';

class SessionListCubit extends Cubit<SessionListState> {
  SessionListCubit({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository,
        super(const SessionListInitial());

  final SessionRepository _sessionRepository;

  Future<void> loadSessions(String organizationId) async {
    emit(const SessionListLoading());
    try {
      final sessions = await _sessionRepository.getSessions(
        organizationId: organizationId,
      );
      emit(SessionListLoaded(sessions));
    } catch (e) {
      emit(SessionListError(e.toString()));
    }
  }
}
