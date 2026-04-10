import 'package:abaly/features/auth/cubit/auth_cubit.dart';
import 'package:abaly/features/auth/cubit/auth_state.dart';
import 'package:abaly/features/sessions/cubit/session_list_cubit.dart';
import 'package:abaly/features/sessions/cubit/session_list_state.dart';
import 'package:abaly/features/sessions/view/sessions_page.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:abaly/shared/models/session.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionListCubit extends MockCubit<SessionListState>
    implements SessionListCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockSessionListCubit mockSessionListCubit;
  late MockAuthCubit mockAuthCubit;

  const testUser = AppUser(
    id: 'user-1',
    email: 'test@example.com',
    fullName: 'Test User',
    role: UserRole.therapist,
    organizationId: 'org-1',
  );

  final testSession = Session(
    id: 'session-1',
    patientId: 'patient-1',
    templateId: 'template-1',
    therapistId: 'therapist-1',
    organizationId: 'org-1',
    status: SessionStatus.pending,
    createdBy: 'user-1',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  setUp(() {
    mockSessionListCubit = MockSessionListCubit();
    mockAuthCubit = MockAuthCubit();

    when(() => mockAuthCubit.state)
        .thenReturn(const AuthAuthenticated(testUser));
    when(() => mockSessionListCubit.loadSessions(any()))
        .thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          BlocProvider<SessionListCubit>.value(value: mockSessionListCubit),
        ],
        child: const SessionsPage(),
      ),
    );
  }

  group('SessionsPage', () {
    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      when(() => mockSessionListCubit.state)
          .thenReturn(const SessionListLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows list of sessions when loaded', (tester) async {
      when(() => mockSessionListCubit.state)
          .thenReturn(SessionListLoaded([testSession]));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Patient: patient-1'), findsOneWidget);
    });

    testWidgets('shows error message when error state', (tester) async {
      when(() => mockSessionListCubit.state)
          .thenReturn(const SessionListError('Something went wrong'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('has FAB with add icon', (tester) async {
      when(() => mockSessionListCubit.state)
          .thenReturn(const SessionListInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}

