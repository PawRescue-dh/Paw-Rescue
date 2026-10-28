import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/main.dart';

void main() {
  testWidgets('Muestra la pantalla inicial de PawRescue', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('PawRescue App'), findsOneWidget);
  });
}
