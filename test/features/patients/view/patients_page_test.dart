import 'package:abaly/features/auth/cubit/auth_cubit.dart';
import 'package:abaly/features/auth/cubit/auth_state.dart';
import 'package:abaly/features/patients/cubit/patient_list_cubit.dart';
import 'package:abaly/features/patients/cubit/patient_list_state.dart';
import 'package:abaly/features/patients/view/patients_page.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:abaly/shared/models/patient.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPatientListCubit extends MockCubit<PatientListState>
    implements PatientListCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockPatientListCubit mockPatientListCubit;
  late MockAuthCubit mockAuthCubit;

  const testUser = AppUser(
    id: 'user-1',
    email: 'test@example.com',
    fullName: 'Test User',
    role: UserRole.therapist,
    organizationId: 'org-1',
  );

  final testPatient = Patient(
    id: 'patient-1',
    fullName: 'John Doe',
    organizationId: 'org-1',
    createdBy: 'user-1',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  setUp(() {
    mockPatientListCubit = MockPatientListCubit();
    mockAuthCubit = MockAuthCubit();

    when(() => mockAuthCubit.state)
        .thenReturn(const AuthAuthenticated(testUser));
    when(() => mockPatientListCubit.loadPatients(any()))
        .thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          BlocProvider<PatientListCubit>.value(value: mockPatientListCubit),
        ],
        child: const PatientsPage(),
      ),
    );
  }

  group('PatientsPage', () {
    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      when(() => mockPatientListCubit.state)
          .thenReturn(const PatientListLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows list of patients when loaded', (tester) async {
      when(() => mockPatientListCubit.state)
          .thenReturn(PatientListLoaded([testPatient]));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('has FAB with add icon', (tester) async {
      when(() => mockPatientListCubit.state)
          .thenReturn(const PatientListInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
