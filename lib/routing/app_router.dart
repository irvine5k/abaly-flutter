import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/cubit/auth_state.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/sign_up_page.dart';
import '../features/home/view/home_page.dart';
import '../features/organization/cubit/organization_cubit.dart';
import '../features/organization/data/organization_repository.dart';
import '../features/organization/view/organization_page.dart';
import '../features/patients/cubit/create_patient_cubit.dart';
import '../features/patients/cubit/patient_list_cubit.dart';
import '../features/patients/data/patient_repository.dart';
import '../features/patients/view/create_patient_page.dart';
import '../features/patients/view/patients_page.dart';
import '../features/sessions/cubit/create_session_cubit.dart';
import '../features/sessions/cubit/session_detail_cubit.dart';
import '../features/sessions/cubit/session_list_cubit.dart';
import '../features/sessions/data/session_repository.dart';
import '../features/sessions/view/create_session_page.dart';
import '../features/sessions/view/session_detail_page.dart';
import '../features/sessions/view/sessions_page.dart';
import '../features/templates/cubit/create_template_cubit.dart';
import '../features/templates/cubit/template_list_cubit.dart';
import '../features/templates/data/template_repository.dart';
import '../features/templates/view/create_template_page.dart';
import '../features/templates/view/templates_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter appRouter(AuthCubit authCubit) => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/sessions',
      refreshListenable: _AuthRefreshListenable(authCubit),
      redirect: (context, state) {
        final authState = authCubit.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/sign-up';

        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && isAuthRoute) return '/sessions';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return HomePage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/sessions',
                  builder: (context, state) => BlocProvider(
                    create: (context) => SessionListCubit(
                      sessionRepository:
                          context.read<SessionRepository>(),
                    ),
                    child: const SessionsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => BlocProvider(
                        create: (_) => CreateSessionCubit(
                          sessionRepository:
                              context.read<SessionRepository>(),
                          patientRepository:
                              context.read<PatientRepository>(),
                          templateRepository:
                              context.read<TemplateRepository>(),
                        ),
                        child: const CreateSessionPage(),
                      ),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final sessionId = state.pathParameters['id']!;
                        return BlocProvider(
                          create: (_) => SessionDetailCubit(
                            sessionRepository:
                                context.read<SessionRepository>(),
                            patientRepository:
                                context.read<PatientRepository>(),
                            templateRepository:
                                context.read<TemplateRepository>(),
                          ),
                          child: SessionDetailPage(sessionId: sessionId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/patients',
                  builder: (context, state) => BlocProvider(
                    create: (context) => PatientListCubit(
                      patientRepository: context.read<PatientRepository>(),
                    ),
                    child: const PatientsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => BlocProvider(
                        create: (_) => CreatePatientCubit(
                          patientRepository: context.read<PatientRepository>(),
                        ),
                        child: const CreatePatientPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/templates',
                  builder: (context, state) => BlocProvider(
                    create: (context) => TemplateListCubit(
                      templateRepository: context.read<TemplateRepository>(),
                    ),
                    child: const TemplatesPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => BlocProvider(
                        create: (context) => CreateTemplateCubit(
                          templateRepository:
                              context.read<TemplateRepository>(),
                        ),
                        child: const CreateTemplatePage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organization',
                  builder: (context, state) => BlocProvider(
                    create: (context) => OrganizationCubit(
                      organizationRepository:
                          context.read<OrganizationRepository>(),
                    ),
                    child: const OrganizationPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}
