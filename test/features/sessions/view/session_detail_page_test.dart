import 'package:abaly/features/sessions/cubit/session_detail_cubit.dart';
import 'package:abaly/features/sessions/cubit/session_detail_state.dart';
import 'package:abaly/features/sessions/view/session_detail_page.dart';
import 'package:abaly/shared/models/patient.dart';
import 'package:abaly/shared/models/session.dart';
import 'package:abaly/shared/models/template.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionDetailCubit extends MockCubit<SessionDetailState>
    implements SessionDetailCubit {}

// DateTime is not const; keep fixtures at top level as final.
final _epoch = DateTime.utc(2024, 1, 1);

final _testPatient = Patient(
  id: 'patient-1',
  fullName: 'John Doe',
  organizationId: 'org-1',
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _testTemplate = Template(
  id: 'template-1',
  name: 'ABA Template',
  organizationId: 'org-1',
  fields: const [],
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _pendingSession = Session(
  id: 'session-1',
  patientId: 'patient-1',
  templateId: 'template-1',
  therapistId: 'therapist-1',
  organizationId: 'org-1',
  status: SessionStatus.pending,
  createdBy: 'user-1',
  createdAt: _epoch,
);

final _completedSession = Session(
  id: 'session-1',
  patientId: 'patient-1',
  templateId: 'template-1',
  therapistId: 'therapist-1',
  organizationId: 'org-1',
  status: SessionStatus.completed,
  completedAt: _epoch,
  createdBy: 'user-1',
  createdAt: _epoch,
);

void main() {
  late MockSessionDetailCubit mockCubit;

  setUp(() {
    mockCubit = MockSessionDetailCubit();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<SessionDetailCubit>.value(
        value: mockCubit,
        child: const SessionDetailPage(sessionId: 'session-1'),
      ),
    );
  }

  group('SessionDetailPage', () {
    testWidgets('shows loading indicator when state is SessionDetailLoading',
        (tester) async {
      when(() => mockCubit.state).thenReturn(const SessionDetailLoading());
      when(() => mockCubit.loadSession(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator when state is SessionDetailInitial',
        (tester) async {
      when(() => mockCubit.state).thenReturn(const SessionDetailInitial());
      when(() => mockCubit.loadSession(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows patient name, template name, and status when loaded',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        SessionDetailLoaded(
          session: _pendingSession,
          patient: _testPatient,
          template: _testTemplate,
        ),
      );
      when(() => mockCubit.loadSession(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('ABA Template'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows "Start Session" button when status is pending',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        SessionDetailLoaded(
          session: _pendingSession,
          patient: _testPatient,
          template: _testTemplate,
        ),
      );
      when(() => mockCubit.loadSession(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(
        find.widgetWithText(FilledButton, 'Start Session'),
        findsOneWidget,
      );
    });

    testWidgets('does NOT show "Start Session" button when status is completed',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        SessionDetailLoaded(
          session: _completedSession,
          patient: _testPatient,
          template: _testTemplate,
        ),
      );
      when(() => mockCubit.loadSession(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(
        find.widgetWithText(FilledButton, 'Start Session'),
        findsNothing,
      );
    });

    testWidgets('shows error message when state is SessionDetailError',
        (tester) async {
      when(() => mockCubit.state)
          .thenReturn(const SessionDetailError('Something went wrong'));
      when(() => mockCubit.loadSession(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
