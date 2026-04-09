import 'package:flutter_test/flutter_test.dart';

import 'package:abaly/main.dart';

void main() {
  testWidgets('App renders home page with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AbalyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sessions'), findsWidgets);
    expect(find.text('Patients'), findsWidgets);
    expect(find.text('Templates'), findsWidgets);
    expect(find.text('Organization'), findsWidgets);
  });
}
