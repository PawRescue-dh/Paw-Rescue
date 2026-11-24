import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/screens/login_screen.dart';
import 'package:pawrescue/screens/register_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('LoginScreen muestra correo, contraseña y botón Ingresar',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });

  testWidgets('El enlace de registro abre RegisterScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    await tester.tap(find.text('¿No tienes cuenta? Regístrate aquí'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Crear Cuenta - PawRescue'), findsOneWidget);
  });
}
