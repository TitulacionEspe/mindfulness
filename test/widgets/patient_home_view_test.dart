import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/views/modulo_paciente/patient_feature_guide_view.dart';
import 'package:mindfulness_app/views/modulo_paciente/patient_home_view.dart';

Widget _buildApp({required ValueChanged<PatientFeatureAction> onAction}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.light,
    home: PatientHomeView(onFeatureAction: onAction),
  );
}

void main() {
  testWidgets('renders permanent Nidara welcome home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildApp(onAction: (_) {}));
    await tester.pumpAndSettle();

    expect(
      find.text('Bienvenido a Nidara, tu espacio para tu descanso placentero.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'En esta aplicación tú podrás realizar las siguientes actividades:',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Realizar actividades de respiración y relajación'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Encuentra ejercicios guiados para respirar con calma, relajarte y prepararte para el descanso.',
      ),
      findsOneWidget,
    );
    expect(find.text('Registrar hábitos de sueño'), findsOneWidget);
    expect(
      find.text(
        'Organiza horarios, recordatorios y preferencias para preparar mejor tu descanso.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Registrar notas en tu diario personal'),
      180,
    );
    expect(find.text('Registrar notas en tu diario personal'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Planificar una cita con un profesional.'),
      180,
    );
    await tester.scrollUntilVisible(
      find.text(
        'Tus datos personales e información que registres en la aplicación son confidenciales.',
      ),
      180,
    );
    expect(
      find.text(
        'Tus datos personales e información que registres en la aplicación son confidenciales.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Ir a actividades'), -180);
    expect(find.text('Ir a actividades'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appointment quick action keeps current navigation contract', (
    tester,
  ) async {
    PatientFeatureAction? selectedAction;

    await tester.pumpWidget(
      _buildApp(onAction: (action) => selectedAction = action),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Planificar cita'),
      180,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Planificar cita'));
    await tester.pumpAndSettle();

    expect(selectedAction, PatientFeatureAction.appointments);
  });
}
