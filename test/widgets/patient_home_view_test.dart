import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/models/patient_history_model.dart';
import 'package:mindfulness_app/services/patient_history_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Importamos el ViewModel de Autenticación
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/patient_history_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/patient_home_view.dart';
import 'package:provider/provider.dart';

// 1. Doble de riesgo para engañar a la vista de que hay una sesión iniciada
class FakeAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// 2. Doble de riesgo para simular la base de datos
class FakePatientHistoryRepository implements PatientHistoryRepository {
  bool shouldThrow = false;

  List<HistorySessionItem> sessions = const [];
  List<HistoryEmotionItem> emotions = const [];
  List<HistoryThoughtItem> thoughts = const [];

  @override
  Future<List<HistorySessionItem>> getSessions(int rangeDays) async {
    if (shouldThrow) throw Exception('sessions error');
    return sessions;
  }

  @override
  Future<List<HistoryEmotionItem>> getAssessments(int rangeDays) async {
    if (shouldThrow) throw Exception('emotions error');
    return emotions;
  }

  @override
  Future<List<HistoryThoughtItem>> getThoughtEntries(int rangeDays) async {
    if (shouldThrow) throw Exception('thoughts error');
    return thoughts;
  }
}

// 3. Constructor de la App falsa para el test
Widget _buildApp(PatientHistoryRepository repository) {
  return MultiProvider(
    providers: [
      // Inyectamos el AuthViewModel falso
      ChangeNotifierProvider<AuthViewModel>(create: (_) => FakeAuthViewModel()),
      // Inyectamos el Historial y FORZAMOS la carga de métricas
      ChangeNotifierProvider<PatientHistoryViewModel>(
        create: (_) => PatientHistoryViewModel(
          repository: repository,
          nowProvider: () => DateTime(2026, 4, 24, 21, 0),
        )..loadHomeMetrics(), // <-- La clave para que no se quede cargando
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const PatientHomeView(),
    ),
  );
}

void main() {
  testWidgets('renders home progress summary metrics', (tester) async {
    final repository = FakePatientHistoryRepository()
      ..sessions = [
        HistorySessionItem(
          id: 's1',
          routineTitle: 'Rutina 1',
          startedAt: DateTime(2026, 4, 22, 21, 0),
          completedAt: DateTime(2026, 4, 22, 21, 8),
          status: HistorySessionStatus.completed,
          assignmentContext: 'self-initiated',
        ),
      ]
      ..emotions = [
        HistoryEmotionItem(
          id: 'e1',
          sessionId: 's1',
          recordedAt: DateTime(2026, 4, 22, 21, 0),
          preEmotion: 'ansiedad',
          preIntensity: 7,
          postEmotion: 'calma',
          postIntensity: 4,
        ),
      ];

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    // Validamos los textos en pantalla
    expect(find.textContaining('Progreso reciente'), findsOneWidget);
    expect(find.text('Frecuencia'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);
    expect(find.text('Constancia'), findsOneWidget);
    expect(find.textContaining('1'), findsWidgets);
    expect(find.text('1/7'), findsOneWidget);
  });

  testWidgets('shows error state when home metrics fail', (tester) async {
    final repository = FakePatientHistoryRepository()..shouldThrow = true;

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo cargar tu progreso reciente. Intenta nuevamente.'),
      findsOneWidget,
    );
  });
}
