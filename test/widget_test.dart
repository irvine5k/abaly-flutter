import 'package:abaly/features/auth/data/auth_repository.dart';
import 'package:abaly/features/sessions/data/session_repository.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:abaly/shared/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:abaly/main.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSessionRepository mockSessionRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionRepository = MockSessionRepository();
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const AppUser(
              id: 'user-1',
              email: 'test@example.com',
              fullName: 'Test User',
              role: UserRole.therapist,
              organizationId: 'org-1',
            ));
    when(
      () => mockSessionRepository.getSessions(
        organizationId: any(named: 'organizationId'),
      ),
    ).thenAnswer((_) async => <Session>[]);
  });

  testWidgets('App renders login page when unauthenticated',
      (WidgetTester tester) async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => null);

    await tester.pumpWidget(AbalyApp(
      authRepository: mockAuthRepository,
      sessionRepository: mockSessionRepository,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('App renders home page when authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(AbalyApp(
      authRepository: mockAuthRepository,
      sessionRepository: mockSessionRepository,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sessions'), findsWidgets);
    expect(find.text('Patients'), findsWidgets);
  });
}
