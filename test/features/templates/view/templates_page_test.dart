import 'package:abaly/features/auth/cubit/auth_cubit.dart';
import 'package:abaly/features/auth/cubit/auth_state.dart';
import 'package:abaly/features/templates/cubit/template_list_cubit.dart';
import 'package:abaly/features/templates/cubit/template_list_state.dart';
import 'package:abaly/features/templates/view/templates_page.dart';
import 'package:abaly/shared/models/app_user.dart';
import 'package:abaly/shared/models/template.dart';
import 'package:abaly/shared/models/template_field.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateListCubit extends MockCubit<TemplateListState>
    implements TemplateListCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockTemplateListCubit mockTemplateListCubit;
  late MockAuthCubit mockAuthCubit;

  const testUser = AppUser(
    id: 'user-1',
    email: 'test@example.com',
    fullName: 'Test User',
    role: UserRole.therapist,
    organizationId: 'org-1',
  );

  final testTemplate = Template(
    id: 'template-1',
    name: 'Attention Template',
    organizationId: 'org-1',
    fields: const [TemplateField(label: 'Attention', type: FieldType.scale)],
    createdBy: 'user-1',
    createdAt: DateTime.utc(2024, 1, 1),
  );

  setUp(() {
    mockTemplateListCubit = MockTemplateListCubit();
    mockAuthCubit = MockAuthCubit();

    when(() => mockAuthCubit.state)
        .thenReturn(const AuthAuthenticated(testUser));
    when(() => mockTemplateListCubit.loadTemplates(any()))
        .thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          BlocProvider<TemplateListCubit>.value(value: mockTemplateListCubit),
        ],
        child: const TemplatesPage(),
      ),
    );
  }

  group('TemplatesPage', () {
    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      when(() => mockTemplateListCubit.state)
          .thenReturn(const TemplateListLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows list of templates when loaded', (tester) async {
      when(() => mockTemplateListCubit.state)
          .thenReturn(TemplateListLoaded([testTemplate]));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Attention Template'), findsOneWidget);
      expect(find.text('1 field'), findsOneWidget);
    });

    testWidgets('has FAB with add icon', (tester) async {
      when(() => mockTemplateListCubit.state)
          .thenReturn(const TemplateListInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
