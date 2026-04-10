import 'package:equatable/equatable.dart';

import '../../../shared/models/session.dart';

sealed class SessionListState extends Equatable {
  const SessionListState();

  @override
  List<Object?> get props => [];
}

class SessionListInitial extends SessionListState {
  const SessionListInitial();
}

class SessionListLoading extends SessionListState {
  const SessionListLoading();
}

class SessionListLoaded extends SessionListState {
  const SessionListLoaded(this.sessions);

  final List<Session> sessions;

  @override
  List<Object?> get props => [sessions];
}

class SessionListError extends SessionListState {
  const SessionListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
