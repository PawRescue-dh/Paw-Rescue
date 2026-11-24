import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/screens/register_screen.dart';

void main() {
  testWidgets('RegisterScreen tiene campos y selector de rol',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña (mín. 8 caracteres)'), findsOneWidget);
    expect(find.text('Registrarme'), findsOneWidget);
  });

  testWidgets('Registrar con campos vacíos muestra aviso de validación',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    await tester.tap(find.text('Registrarme'));
    await tester.pump();

    expect(find.text('Completa todos los campos'), findsOneWidget);
  });
}
