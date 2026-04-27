import 'package:flutter/material.dart';

import '../models/patient_history_model.dart';
import '../services/patient_history_repository.dart';

class PatientHistoryViewModel extends ChangeNotifier {
  PatientHistoryViewModel({PatientHistoryRepository? repository})
    : _repository = repository ?? SupabasePatientHistoryRepository();

  final PatientHistoryRepository _repository;

  static const List<int> allowedRanges = [7, 30];

  int _selectedRangeDays = 7;
  int get selectedRangeDays => _selectedRangeDays;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<HistorySessionItem> _sessions = const [];
  List<HistorySessionItem> get sessions => _sessions;

  List<HistoryEmotionItem> _emotions = const [];
  List<HistoryEmotionItem> get emotions => _emotions;

  List<HistoryThoughtItem> _thoughts = const [];
  List<HistoryThoughtItem> get thoughts => _thoughts;

  HistorySummary get summary => HistorySummary(
    totalSessions: _sessions.length,
    completedSessions: _sessions
        .where((session) => session.status == HistorySessionStatus.completed)
        .length,
    totalThoughts: _thoughts.length,
    totalEmotionLogs: _emotions.length,
  );

  Future<void> loadHistory({bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getSessions(_selectedRangeDays),
        _repository.getAssessments(_selectedRangeDays),
        _repository.getThoughtEntries(_selectedRangeDays),
      ]);

      _sessions = results[0] as List<HistorySessionItem>;
      _emotions = results[1] as List<HistoryEmotionItem>;
      _thoughts = results[2] as List<HistoryThoughtItem>;
      _sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      _emotions.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      _thoughts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      _errorMessage =
          'No se pudo cargar el historial personal. Intenta nuevamente.';
      _sessions = const [];
      _emotions = const [];
      _thoughts = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRangeDays(int days) async {
    if (!allowedRanges.contains(days)) return;
    if (_selectedRangeDays == days) return;
    _selectedRangeDays = days;
    notifyListeners();
    await loadHistory(force: true);
  }
}
