import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/models/patient_history_model.dart';
import 'package:mindfulness_app/services/patient_history_repository.dart';
import 'package:mindfulness_app/viewmodels/patient_history_viewmodel.dart';

class FakePatientHistoryRepository implements PatientHistoryRepository {
  bool shouldThrow = false;
  int lastRangeDays = 7;

  List<HistorySessionItem> sessions = const [];
  List<HistoryEmotionItem> emotions = const [];
  List<HistoryThoughtItem> thoughts = const [];

  @override
  Future<List<HistorySessionItem>> getSessions(int rangeDays) async {
    if (shouldThrow) throw Exception('session error');
    lastRangeDays = rangeDays;
    return sessions;
  }

  @override
  Future<List<HistoryEmotionItem>> getAssessments(int rangeDays) async {
    if (shouldThrow) throw Exception('emotion error');
    lastRangeDays = rangeDays;
    return emotions;
  }

  @override
  Future<List<HistoryThoughtItem>> getThoughtEntries(int rangeDays) async {
    if (shouldThrow) throw Exception('thought error');
    lastRangeDays = rangeDays;
    return thoughts;
  }
}

void main() {
  group('PatientHistoryViewModel', () {
    final fixedNow = DateTime(2026, 4, 24, 23, 0); // Thursday

    test('loads initial history with default range 7 days', () async {
      final repository = FakePatientHistoryRepository()
        ..sessions = [
          HistorySessionItem(
            id: 'older',
            routineTitle: 'Respiracion 4-6',
            startedAt: DateTime(2026, 4, 21, 22, 0), // Monday
            completedAt: DateTime(2026, 4, 20, 22, 8),
            status: HistorySessionStatus.completed,
            assignmentContext: 'self-initiated',
          ),
          HistorySessionItem(
            id: 'newer',
            routineTitle: 'Escaneo corporal',
            startedAt: DateTime(2026, 4, 23, 22, 0), // Wednesday
            completedAt: DateTime(2026, 4, 21, 22, 8),
            status: HistorySessionStatus.completed,
            assignmentContext: 'assigned',
          ),
        ]
        ..emotions = [
          HistoryEmotionItem(
            id: 'e1',
            sessionId: 'newer',
            recordedAt: DateTime(2026, 4, 20, 22, 0),
            preEmotion: 'ansiedad',
            preIntensity: 7,
            postEmotion: 'calma',
            postIntensity: 3,
          ),
        ]
        ..thoughts = [
          HistoryThoughtItem(
            id: 't1',
            createdAt: DateTime(2026, 4, 20, 21, 55),
            preview: 'Hoy me senti con carga mental.',
          ),
        ];
      final viewModel = PatientHistoryViewModel(
        repository: repository,
        nowProvider: () => fixedNow,
      );

      await viewModel.loadHistory();

      expect(repository.lastRangeDays, 7);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.sessions.length, 2);
      expect(viewModel.sessions.first.id, 'newer');
      expect(viewModel.emotions.length, 1);
      expect(viewModel.thoughts.length, 1);
      expect(viewModel.summary.totalSessions, 2);
      expect(viewModel.summary.completedSessions, 2);
      expect(viewModel.historyMetrics.activeDaysInRange, 2);
      expect(viewModel.historyMetrics.completedSessionsInRange, 2);
      expect(viewModel.historyMetrics.weeklyActiveDays, 2);
      expect(viewModel.historyMetrics.improvedSessions, 1);
      expect(viewModel.historyMetrics.assessableSessions, 1);
    });

    test('changes range from 7 to 30 days and reloads', () async {
      final repository = FakePatientHistoryRepository();
      final viewModel = PatientHistoryViewModel(
        repository: repository,
        nowProvider: () => fixedNow,
      );

      await viewModel.setRangeDays(30);

      expect(viewModel.selectedRangeDays, 30);
      expect(repository.lastRangeDays, 30);
    });

    test('treats empty history as a valid new-account state', () async {
      final repository = FakePatientHistoryRepository();
      final viewModel = PatientHistoryViewModel(
        repository: repository,
        nowProvider: () => fixedNow,
      );

      await viewModel.loadHistory();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.sessions, isEmpty);
      expect(viewModel.emotions, isEmpty);
      expect(viewModel.thoughts, isEmpty);
      expect(viewModel.historyMetrics.activeDaysInRange, 0);
      expect(viewModel.historyMetrics.completedSessionsInRange, 0);
      expect(viewModel.historyMetrics.weeklyActiveDays, 0);
    });

    test('handles repository errors', () async {
      final repository = FakePatientHistoryRepository()..shouldThrow = true;
      final viewModel = PatientHistoryViewModel(
        repository: repository,
        nowProvider: () => fixedNow,
      );

      await viewModel.loadHistory();

      expect(
        viewModel.errorMessage,
        'No se pudo cargar el historial personal. Intenta nuevamente.',
      );
      expect(viewModel.sessions, isEmpty);
      expect(viewModel.emotions, isEmpty);
      expect(viewModel.thoughts, isEmpty);
    });

    test('loads home metrics with fixed 7 day range', () async {
      final repository = FakePatientHistoryRepository()
        ..sessions = [
          HistorySessionItem(
            id: 'a',
            routineTitle: 'Rutina A',
            startedAt: DateTime(2026, 4, 22, 20, 0),
            completedAt: DateTime(2026, 4, 22, 20, 8),
            status: HistorySessionStatus.completed,
            assignmentContext: 'self-initiated',
          ),
          HistorySessionItem(
            id: 'b',
            routineTitle: 'Rutina B',
            startedAt: DateTime(2026, 4, 23, 20, 0),
            completedAt: DateTime(2026, 4, 23, 20, 8),
            status: HistorySessionStatus.completed,
            assignmentContext: 'self-initiated',
          ),
        ]
        ..emotions = [
          HistoryEmotionItem(
            id: 'e-a',
            sessionId: 'a',
            recordedAt: DateTime(2026, 4, 22, 20, 0),
            preEmotion: 'ansiedad',
            preIntensity: 6,
            postEmotion: 'calma',
            postIntensity: 4,
          ),
          HistoryEmotionItem(
            id: 'e-b',
            sessionId: 'b',
            recordedAt: DateTime(2026, 4, 23, 20, 0),
            preEmotion: 'estres',
            preIntensity: 5,
            postEmotion: 'estres',
            postIntensity: 5,
          ),
        ];
      final viewModel = PatientHistoryViewModel(
        repository: repository,
        nowProvider: () => fixedNow,
      );

      await viewModel.loadHomeMetrics();

      expect(repository.lastRangeDays, 7);
      expect(viewModel.homeMetrics.activeDaysInRange, 2);
      expect(viewModel.homeMetrics.completedSessionsInRange, 2);
      expect(viewModel.homeMetrics.weeklyActiveDays, 2);
      expect(viewModel.homeMetrics.improvedSessions, 1);
      expect(viewModel.homeMetrics.assessableSessions, 2);
      expect(viewModel.homeMetrics.improvementRate, 0.5);
      expect(viewModel.homeMetricsErrorMessage, isNull);
    });
  });
}
