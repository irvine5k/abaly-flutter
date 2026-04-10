import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase/supabase_init.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/sessions/data/session_repository.dart';
import 'features/sessions/data/supabase_session_repository.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  final authRepository = SupabaseAuthRepository(
    client: Supabase.instance.client,
  );

  final sessionRepository = SupabaseSessionRepository(
    client: Supabase.instance.client,
  );

  runApp(AbalyApp(
    authRepository: authRepository,
    sessionRepository: sessionRepository,
  ));
}

class AbalyApp extends StatelessWidget {
  const AbalyApp({
    super.key,
    required this.authRepository,
    required this.sessionRepository,
  });

  final AuthRepository authRepository;
  final SessionRepository sessionRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SessionRepository>.value(value: sessionRepository),
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
