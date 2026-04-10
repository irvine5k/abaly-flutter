import 'package:abaly/features/auth/data/auth_repository.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:abaly/main.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
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
  });

  testWidgets('App renders login page when unauthenticated',
      (WidgetTester tester) async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => null);

    await tester.pumpWidget(AbalyApp(authRepository: mockAuthRepository));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('App renders home page when authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(AbalyApp(authRepository: mockAuthRepository));
    await tester.pumpAndSettle();

    expect(find.text('Sessions'), findsWidgets);
    expect(find.text('Patients'), findsWidgets);
  });
}
