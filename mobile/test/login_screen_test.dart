import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/screens/login_screen.dart';
import 'package:pawrescue/screens/register_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('LoginScreen muestra correo, contraseña y botón de acceso',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('Valida los campos vacíos antes de enviar',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa un correo válido'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('El botón de crear cuenta abre RegisterScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Crear una cuenta'));
    await tester.tap(find.text('Crear una cuenta'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
