import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import 'core/supabase/supabase_init.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/patients/data/patient_repository.dart';
import 'features/patients/data/supabase_patient_repository.dart';
import 'features/sessions/data/session_repository.dart';
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
    patientRepository: SupabasePatientRepository(client: client),
    templateRepository: SupabaseTemplateRepository(client: client),
  ));
}

class AbalyApp extends StatelessWidget {
  const AbalyApp({
    super.key,
    required this.authRepository,
    required this.sessionRepository,
    required this.patientRepository,
    required this.templateRepository,
  });

  final AuthRepository authRepository;
  final SessionRepository sessionRepository;
  final PatientRepository patientRepository;
  final TemplateRepository templateRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SessionRepository>.value(value: sessionRepository),
        RepositoryProvider<PatientRepository>.value(value: patientRepository),
        RepositoryProvider<TemplateRepository>.value(value: templateRepository),
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
