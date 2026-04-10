import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/invitation.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/organization_cubit.dart';
import '../cubit/organization_state.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<OrganizationCubit>()
          .loadOrganization(authState.user.organizationId);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizationCubit, OrganizationState>(
      listener: (context, state) {
        if (state.status == OrganizationStatus.invitationSent) {
          _emailController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invitation sent successfully')),
          );
        } else if (state.status == OrganizationStatus.invitationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Failed to send invitation'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<OrganizationCubit, OrganizationState>(
            builder: (context, state) {
              final orgName = state.organization?.name ?? 'Organization';
              return Text(orgName);
            },
          ),
        ),
        body: BlocBuilder<OrganizationCubit, OrganizationState>(
          builder: (context, state) {
            if (state.status == OrganizationStatus.loading &&
                state.organization == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == OrganizationStatus.error &&
                state.organization == null) {
              return Center(
                child: Text(
                  state.error ?? 'An error occurred',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }

            final authState = context.read<AuthCubit>().state;
            final isAdmin = authState is AuthAuthenticated &&
                authState.user.role == UserRole.admin;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(title: 'Members'),
                if (state.members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No members found'),
                  )
                else
                  ...state.members.map(
                    (member) => _MemberTile(member: member),
                  ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Pending Invitations'),
                if (state.pendingInvitations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No pending invitations'),
                  )
                else
                  ...state.pendingInvitations.map(
                    (invitation) => _InvitationTile(invitation: invitation),
                  ),
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Invite Therapist'),
                  const SizedBox(height: 8),
                  _InviteForm(emailController: _emailController),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final AppUser member;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(member.fullName),
        subtitle: Text(member.email),
        trailing: _RoleBadge(role: member.role),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toJson(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isAdmin
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}

class _InvitationTile extends StatelessWidget {
  const _InvitationTile({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final dateStr = invitation.createdAt.toLocal().toString().split(' ').first;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(invitation.email),
        subtitle: Text('Invited on $dateStr'),
        trailing: const Icon(Icons.schedule, size: 16),
      ),
    );
  }
}

class _InviteForm extends StatelessWidget {
  const _InviteForm({required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizationCubit, OrganizationState>(
      builder: (context, state) {
        final isLoading = state.status == OrganizationStatus.loading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(),
                hintText: 'therapist@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => _onSendInvite(context, state),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  void _onSendInvite(BuildContext context, OrganizationState state) {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<OrganizationCubit>().sendInvitation(
          email: email,
          organizationId: authState.user.organizationId,
          invitedBy: authState.user.id,
        );
  }
}
