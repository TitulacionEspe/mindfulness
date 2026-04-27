import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/models/patient_history_model.dart';
import 'package:mindfulness_app/services/patient_history_repository.dart';
import 'package:mindfulness_app/viewmodels/patient_history_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/patient_history_view.dart';
import 'package:provider/provider.dart';

class FakePatientHistoryRepository implements PatientHistoryRepository {
  bool shouldThrow = false;
  int lastRangeDays = 7;

  List<HistorySessionItem> sessions = const [];
  List<HistoryEmotionItem> emotions = const [];
  List<HistoryThoughtItem> thoughts = const [];

  @override
  Future<List<HistorySessionItem>> getSessions(int rangeDays) async {
    if (shouldThrow) throw Exception('sessions error');
    lastRangeDays = rangeDays;
    return sessions;
  }

  @override
  Future<List<HistoryEmotionItem>> getAssessments(int rangeDays) async {
    if (shouldThrow) throw Exception('emotions error');
    lastRangeDays = rangeDays;
    return emotions;
  }

  @override
  Future<List<HistoryThoughtItem>> getThoughtEntries(int rangeDays) async {
    if (shouldThrow) throw Exception('thoughts error');
    lastRangeDays = rangeDays;
    return thoughts;
  }
}

Widget _buildApp(PatientHistoryRepository repository) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => PatientHistoryViewModel(repository: repository),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const PatientHistoryView(),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('renders tabs and history content', (tester) async {
    final repository = FakePatientHistoryRepository()
      ..sessions = [
        HistorySessionItem(
          id: 's1',
          routineTitle: 'Escaneo corporal nocturno',
          startedAt: DateTime(2026, 4, 26, 22, 0),
          completedAt: DateTime(2026, 4, 26, 22, 7),
          status: HistorySessionStatus.completed,
          assignmentContext: 'assigned',
        ),
      ]
      ..emotions = [
        HistoryEmotionItem(
          id: 'e1',
          sessionId: 's1',
          recordedAt: DateTime(2026, 4, 26, 22, 0),
          preEmotion: 'ansiedad',
          preIntensity: 8,
          postEmotion: 'calma',
          postIntensity: 3,
        ),
      ]
      ..thoughts = [
        HistoryThoughtItem(
          id: 't1',
          createdAt: DateTime(2026, 4, 26, 21, 55),
          preview: 'Respire profundo y me senti mejor.',
        ),
      ];

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Historial personal'), findsOneWidget);
    expect(find.text('Sesiones'), findsAtLeastNWidgets(1));
    expect(find.text('Pensamientos'), findsAtLeastNWidgets(1));
    expect(find.text('Escaneo corporal nocturno'), findsOneWidget);
    expect(find.textContaining('Antes:'), findsOneWidget);

    final tabBar = find.byType(TabBar);
    await tester.tap(
      find.descendant(of: tabBar, matching: find.text('Pensamientos')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Respire profundo y me senti mejor.'), findsOneWidget);
  });

  testWidgets('updates content when changing range filter 7/30', (
    tester,
  ) async {
    final repository = FakePatientHistoryRepository()
      ..sessions = [
        HistorySessionItem(
          id: 's1',
          routineTitle: 'Respiracion 4-7-8',
          startedAt: DateTime(2026, 4, 24, 22, 0),
          completedAt: DateTime(2026, 4, 24, 22, 8),
          status: HistorySessionStatus.completed,
          assignmentContext: 'self-initiated',
        ),
      ];

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(repository.lastRangeDays, 7);
    await tester.tap(find.text('30 dias'));
    await tester.pumpAndSettle();
    expect(repository.lastRangeDays, 30);
  });

  testWidgets('shows visible error state when repository fails', (
    tester,
  ) async {
    final repository = FakePatientHistoryRepository()..shouldThrow = true;

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo cargar el historial personal. Intenta nuevamente.'),
      findsOneWidget,
    );
  });
}
