import 'package:abaly/features/auth/cubit/auth_cubit.dart';
import 'package:abaly/features/auth/cubit/auth_state.dart';
import 'package:abaly/features/organization/cubit/organization_cubit.dart';
import 'package:abaly/features/organization/cubit/organization_state.dart';
import 'package:abaly/features/organization/view/organization_page.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:abaly/shared/models/invitation.dart';
import 'package:abaly/shared/models/organization.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizationCubit extends MockCubit<OrganizationState>
    implements OrganizationCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockOrganizationCubit mockOrganizationCubit;
  late MockAuthCubit mockAuthCubit;

  const adminUser = AppUser(
    id: 'user-1',
    email: 'admin@example.com',
    fullName: 'Admin User',
    role: UserRole.admin,
    organizationId: 'org-1',
  );

  const therapistUser = AppUser(
    id: 'user-2',
    email: 'therapist@example.com',
    fullName: 'Therapist User',
    role: UserRole.therapist,
    organizationId: 'org-1',
  );

  final testOrg = Organization(
    id: 'org-1',
    name: 'My Clinic',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  const testMembers = [adminUser, therapistUser];

  final testInvitations = [
    Invitation(
      id: 'inv-1',
      organizationId: 'org-1',
      email: 'new@example.com',
      role: 'therapist',
      status: 'pending',
      invitedBy: 'user-1',
      createdAt: DateTime.utc(2024, 2, 1),
    ),
  ];

  setUp(() {
    mockOrganizationCubit = MockOrganizationCubit();
    mockAuthCubit = MockAuthCubit();

    when(() => mockOrganizationCubit.loadOrganization(any()))
        .thenAnswer((_) async {});
    when(() => mockOrganizationCubit.sendInvitation(
          email: any(named: 'email'),
          organizationId: any(named: 'organizationId'),
          invitedBy: any(named: 'invitedBy'),
        )).thenAnswer((_) async {});
  });

  Widget buildSubject({AppUser user = adminUser}) {
    when(() => mockAuthCubit.state)
        .thenReturn(AuthAuthenticated(user));
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          BlocProvider<OrganizationCubit>.value(value: mockOrganizationCubit),
        ],
        child: const OrganizationPage(),
      ),
    );
  }

  group('OrganizationPage', () {
    testWidgets('shows org name and members when loaded', (tester) async {
      when(() => mockOrganizationCubit.state).thenReturn(
        OrganizationState(
          organization: testOrg,
          members: testMembers,
          pendingInvitations: testInvitations,
          status: OrganizationStatus.loaded,
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('My Clinic'), findsOneWidget);
      expect(find.text('Admin User'), findsOneWidget);
      expect(find.text('Therapist User'), findsOneWidget);
    });

    testWidgets('shows invite form for admin users', (tester) async {
      when(() => mockOrganizationCubit.state).thenReturn(
        OrganizationState(
          organization: testOrg,
          members: testMembers,
          pendingInvitations: const [],
          status: OrganizationStatus.loaded,
        ),
      );

      await tester.pumpWidget(buildSubject(user: adminUser));

      expect(find.text('Invite Therapist'), findsOneWidget);
      expect(find.text('Send Invite'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('does not show invite form for therapist users', (tester) async {
      when(() => mockOrganizationCubit.state).thenReturn(
        OrganizationState(
          organization: testOrg,
          members: testMembers,
          pendingInvitations: const [],
          status: OrganizationStatus.loaded,
        ),
      );

      await tester.pumpWidget(buildSubject(user: therapistUser));

      expect(find.text('Invite Therapist'), findsNothing);
      expect(find.text('Send Invite'), findsNothing);
    });

    testWidgets('shows loading indicator when status is loading and no org',
        (tester) async {
      when(() => mockOrganizationCubit.state).thenReturn(
        const OrganizationState(status: OrganizationStatus.loading),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
