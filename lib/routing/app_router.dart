import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/view/home_page.dart';
import '../features/organization/view/organization_page.dart';
import '../features/patients/view/patients_page.dart';
import '../features/sessions/view/sessions_page.dart';
import '../features/templates/view/templates_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/sessions',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomePage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sessions',
              builder: (context, state) => const SessionsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/patients',
              builder: (context, state) => const PatientsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/templates',
              builder: (context, state) => const TemplatesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/organization',
              builder: (context, state) => const OrganizationPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
