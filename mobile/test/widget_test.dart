import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/main.dart';
import 'package:pawrescue/screens/login_screen.dart';

void main() {
  testWidgets('Sin sesión guardada, PawRescue abre la pantalla de login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
