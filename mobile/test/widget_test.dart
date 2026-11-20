import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/main.dart';

void main() {
  testWidgets('PawRescue app renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}