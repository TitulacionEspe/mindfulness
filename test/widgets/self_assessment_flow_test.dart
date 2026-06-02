import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/models/assigned_activity_model.dart';
import 'package:mindfulness_app/models/routine_model.dart';
import 'package:mindfulness_app/models/self_assessment_model.dart';
import 'package:mindfulness_app/services/routines_repository.dart';
import 'package:mindfulness_app/services/self_assessments_repository.dart';
import 'package:mindfulness_app/viewmodels/routines_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/self_assessments_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/self_assessment_flow.dart';
import 'package:provider/provider.dart';

class FakeRoutinesDataSource implements RoutinesDataSource {
  @override
  Future<void> completeSession({
    required String sessionId,
    required DateTime completedAt,
  }) async {}

  @override
  Future<List<AssignedActivityModel>> fetchAssignedActivities() async =>
      const [];

  @override
  Future<List<RoutineModel>> fetchRoutines() async => const [];

  @override
  Future<String> startSession({
    required String routineId,
    required DateTime startedAt,
  }) async {
    return 'session-1';
  }
}

class FakeSelfAssessmentsRepository implements SelfAssessmentsRepository {
  @override
  Future<void> createAssessment({
    required String sessionId,
    required AssessmentContext context,
    required String emotionId,
    required int intensity,
  }) async {}

  @override
  Future<List<SelfAssessmentModel>> listBySession(String sessionId) async {
    return const [];
  }
}

Widget _wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => RoutinesViewModel(repository: FakeRoutinesDataSource()),
      ),
      ChangeNotifierProvider(
        create: (_) => SelfAssessmentsViewModel(
          repository: FakeSelfAssessmentsRepository(),
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
  testWidgets('Likert sheet blocks finish until a face is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithProviders(
        const Scaffold(
          body: PostSessionLikertSheet(
            sessionId: 'session-1',
            routineTitle: 'Respiración guiada',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Botón debe estar deshabilitado sin selección
    final finishButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Guardar y finalizar'),
    );
    expect(finishButton.onPressed, isNull);

    // Tocar una carita (la tercera: 😐 Regular)
    await tester.tap(find.text('😐'));
    await tester.pumpAndSettle();

    // Ahora el botón debe estar habilitado
    final enabledButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Guardar y finalizar'),
    );
    expect(enabledButton.onPressed, isNotNull);
  });
}
