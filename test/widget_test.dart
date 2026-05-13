import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prueba_proyecto/main.dart';

void main() {
  testWidgets('Muestra la pantalla de login al iniciar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('login'), findsOneWidget);
    expect(find.text('email'), findsOneWidget);
  });
}
