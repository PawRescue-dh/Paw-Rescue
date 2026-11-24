import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/screens/register_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('RegisterScreen muestra los campos y el aviso de privacidad',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const RegisterScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Ciudadano'), findsOneWidget);
    expect(find.text('Albergue'), findsOneWidget);
    expect(find.text('aviso de privacidad'), findsOneWidget);
  });

  testWidgets('Exige datos válidos al registrarse', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const RegisterScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Registrarme'));
    await tester.tap(find.text('Registrarme'));
    await tester.pump();

    expect(find.text('Ingresa al menos 3 caracteres'), findsOneWidget);
    expect(find.text('Ingresa un correo válido'), findsOneWidget);
  });
}
