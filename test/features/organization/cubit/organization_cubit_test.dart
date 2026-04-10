import 'package:abaly/features/organization/cubit/organization_cubit.dart';
import 'package:abaly/features/organization/cubit/organization_state.dart';
import 'package:abaly/features/organization/data/organization_repository.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:abaly/shared/models/invitation.dart';
import 'package:abaly/shared/models/organization.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizationRepository extends Mock
    implements OrganizationRepository {}

void main() {
  late MockOrganizationRepository mockRepository;

  final testOrg = Organization(
    id: 'org-1',
    name: 'Test Org',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  const testMembers = [
    AppUser(
      id: 'user-1',
      email: 'admin@example.com',
      fullName: 'Admin User',
      role: UserRole.admin,
      organizationId: 'org-1',
    ),
  ];

  final testInvitations = [
    Invitation(
      id: 'inv-1',
      organizationId: 'org-1',
      email: 'therapist@example.com',
      role: 'therapist',
      status: 'pending',
      invitedBy: 'user-1',
      createdAt: DateTime.utc(2024, 1, 2),
    ),
  ];

  setUp(() {
    mockRepository = MockOrganizationRepository();
  });

  group('OrganizationCubit', () {
    test('initial state is OrganizationState with status initial', () {
      final cubit = OrganizationCubit(organizationRepository: mockRepository);
      expect(cubit.state.status, OrganizationStatus.initial);
      cubit.close();
    });

    group('loadOrganization', () {
      blocTest<OrganizationCubit, OrganizationState>(
        'emits loading then loaded with org, members, and invitations on success',
        build: () {
          when(
            () => mockRepository.getOrganization(id: any(named: 'id')),
          ).thenAnswer((_) async => testOrg);
          when(
            () => mockRepository.getMembers(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenAnswer((_) async => testMembers);
          when(
            () => mockRepository.getInvitations(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenAnswer((_) async => testInvitations);
          return OrganizationCubit(organizationRepository: mockRepository);
        },
        act: (cubit) => cubit.loadOrganization('org-1'),
        expect: () => [
          const OrganizationState(status: OrganizationStatus.loading),
          OrganizationState(
            organization: testOrg,
            members: testMembers,
            pendingInvitations: testInvitations,
            status: OrganizationStatus.loaded,
          ),
        ],
      );

      blocTest<OrganizationCubit, OrganizationState>(
        'emits loading then error on failure',
        build: () {
          when(
            () => mockRepository.getOrganization(id: any(named: 'id')),
          ).thenThrow(Exception('Network error'));
          return OrganizationCubit(organizationRepository: mockRepository);
        },
        act: (cubit) => cubit.loadOrganization('org-1'),
        expect: () => [
          const OrganizationState(status: OrganizationStatus.loading),
          isA<OrganizationState>().having(
            (s) => s.status,
            'status',
            OrganizationStatus.error,
          ),
        ],
      );
    });

    group('sendInvitation', () {
      blocTest<OrganizationCubit, OrganizationState>(
        'emits loading then invitationSent and reloads invitations on success',
        build: () {
          when(
            () => mockRepository.sendInvitation(
              organizationId: any(named: 'organizationId'),
              email: any(named: 'email'),
              invitedBy: any(named: 'invitedBy'),
            ),
          ).thenAnswer((_) async => testInvitations.first);
          when(
            () => mockRepository.getInvitations(
              organizationId: any(named: 'organizationId'),
            ),
          ).thenAnswer((_) async => testInvitations);
          return OrganizationCubit(organizationRepository: mockRepository);
        },
        act: (cubit) => cubit.sendInvitation(
          email: 'therapist@example.com',
          organizationId: 'org-1',
          invitedBy: 'user-1',
        ),
        expect: () => [
          const OrganizationState(status: OrganizationStatus.loading),
          OrganizationState(
            pendingInvitations: testInvitations,
            status: OrganizationStatus.invitationSent,
          ),
        ],
      );

      blocTest<OrganizationCubit, OrganizationState>(
        'emits loading then invitationError on failure',
        build: () {
          when(
            () => mockRepository.sendInvitation(
              organizationId: any(named: 'organizationId'),
              email: any(named: 'email'),
              invitedBy: any(named: 'invitedBy'),
            ),
          ).thenThrow(Exception('Already invited'));
          return OrganizationCubit(organizationRepository: mockRepository);
        },
        act: (cubit) => cubit.sendInvitation(
          email: 'therapist@example.com',
          organizationId: 'org-1',
          invitedBy: 'user-1',
        ),
        expect: () => [
          const OrganizationState(status: OrganizationStatus.loading),
          isA<OrganizationState>().having(
            (s) => s.status,
            'status',
            OrganizationStatus.invitationError,
          ),
        ],
      );
    });
  });
}
