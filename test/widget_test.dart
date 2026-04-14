import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App structure', () {
    testWidgets('MaterialApp builds without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Mindfulness - Gestión del Sueño')),
          ),
        ),
      );

      expect(find.text('Mindfulness - Gestión del Sueño'), findsOneWidget);
    });
  });
}
