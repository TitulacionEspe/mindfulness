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
    test('loads initial history with default range 7 days', () async {
      final repository = FakePatientHistoryRepository()
        ..sessions = [
          HistorySessionItem(
            id: 'older',
            routineTitle: 'Respiracion 4-6',
            startedAt: DateTime(2026, 4, 20, 22, 0),
            completedAt: DateTime(2026, 4, 20, 22, 8),
            status: HistorySessionStatus.completed,
            assignmentContext: 'self-initiated',
          ),
          HistorySessionItem(
            id: 'newer',
            routineTitle: 'Escaneo corporal',
            startedAt: DateTime(2026, 4, 21, 22, 0),
            completedAt: DateTime(2026, 4, 21, 22, 8),
            status: HistorySessionStatus.completed,
            assignmentContext: 'assigned',
          ),
        ]
        ..emotions = [
          HistoryEmotionItem(
            id: 'e1',
            sessionId: 's1',
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
      final viewModel = PatientHistoryViewModel(repository: repository);

      await viewModel.loadHistory();

      expect(repository.lastRangeDays, 7);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.sessions.length, 2);
      expect(viewModel.sessions.first.id, 'newer');
      expect(viewModel.emotions.length, 1);
      expect(viewModel.thoughts.length, 1);
      expect(viewModel.summary.totalSessions, 2);
      expect(viewModel.summary.completedSessions, 2);
    });

    test('changes range from 7 to 30 days and reloads', () async {
      final repository = FakePatientHistoryRepository();
      final viewModel = PatientHistoryViewModel(repository: repository);

      await viewModel.setRangeDays(30);

      expect(viewModel.selectedRangeDays, 30);
      expect(repository.lastRangeDays, 30);
    });

    test('handles repository errors', () async {
      final repository = FakePatientHistoryRepository()..shouldThrow = true;
      final viewModel = PatientHistoryViewModel(repository: repository);

      await viewModel.loadHistory();

      expect(
        viewModel.errorMessage,
        'No se pudo cargar el historial personal. Intenta nuevamente.',
      );
      expect(viewModel.sessions, isEmpty);
      expect(viewModel.emotions, isEmpty);
      expect(viewModel.thoughts, isEmpty);
    });
  });
}
