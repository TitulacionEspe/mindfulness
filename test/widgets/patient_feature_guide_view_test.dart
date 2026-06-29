import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/views/modulo_paciente/patient_feature_guide_view.dart';

void main() {
  testWidgets('renders Nidara guide with numbered activities', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: PatientFeatureGuideView(
          isFirstRun: false,
          onContinue: () {},
          onFeatureAction: (_) {},
        ),
      ),
    );

    expect(find.text('¿Qué puedes hacer en Nidara?'), findsOneWidget);
    expect(find.text('Respiración y relajación'), findsOneWidget);
    expect(find.text('Registrar hábitos de sueño'), findsOneWidget);
    expect(find.text('Diario personal'), findsOneWidget);
    expect(find.text('Solicitar o revisar citas'), findsOneWidget);
    expect(find.text('Ir a actividades'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('uses application wording in first run CTA', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: PatientFeatureGuideView(
          isFirstRun: true,
          onContinue: () {},
          onFeatureAction: (_) {},
        ),
      ),
    );

    expect(find.text('Continuar a la aplicación'), findsOneWidget);
  });
}
