import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import 'core/supabase/supabase_init.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/organization/data/organization_repository.dart';
import 'features/organization/data/supabase_organization_repository.dart';
import 'features/patients/data/patient_repository.dart';
import 'features/patients/data/supabase_patient_repository.dart';
import 'features/progress/data/progress_repository.dart';
import 'features/progress/data/supabase_progress_repository.dart';
import 'features/sessions/data/response_repository.dart';
import 'features/sessions/data/session_repository.dart';
import 'features/sessions/data/supabase_response_repository.dart';
import 'features/sessions/data/supabase_session_repository.dart';
import 'features/templates/data/supabase_template_repository.dart';
import 'features/templates/data/template_repository.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  final client = Supabase.instance.client;

  runApp(AbalyApp(
    authRepository: SupabaseAuthRepository(client: client),
    sessionRepository: SupabaseSessionRepository(client: client),
    responseRepository: SupabaseResponseRepository(client: client),
    patientRepository: SupabasePatientRepository(client: client),
    templateRepository: SupabaseTemplateRepository(client: client),
    organizationRepository: SupabaseOrganizationRepository(client: client),
    progressRepository: SupabaseProgressRepository(client: client),
  ));
}

class AbalyApp extends StatelessWidget {
  const AbalyApp({
    super.key,
    required this.authRepository,
    required this.sessionRepository,
    required this.responseRepository,
    required this.patientRepository,
    required this.templateRepository,
    required this.organizationRepository,
    required this.progressRepository,
  });

  final AuthRepository authRepository;
  final SessionRepository sessionRepository;
  final ResponseRepository responseRepository;
  final PatientRepository patientRepository;
  final TemplateRepository templateRepository;
  final OrganizationRepository organizationRepository;
  final ProgressRepository progressRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SessionRepository>.value(value: sessionRepository),
        RepositoryProvider<ResponseRepository>.value(value: responseRepository),
        RepositoryProvider<PatientRepository>.value(value: patientRepository),
        RepositoryProvider<TemplateRepository>.value(value: templateRepository),
        RepositoryProvider<OrganizationRepository>.value(
          value: organizationRepository,
        ),
        RepositoryProvider<ProgressRepository>.value(
          value: progressRepository,
        ),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(authRepository: authRepository)
          ..checkAuthStatus(),
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            return MaterialApp.router(
              title: 'Abaly',
              theme: AppTheme.lightTheme,
              routerConfig: appRouter(authCubit),
            );
          },
        ),
      ),
    );
  }
}
