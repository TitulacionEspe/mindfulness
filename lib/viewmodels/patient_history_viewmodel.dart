import 'package:flutter/material.dart';

import '../models/patient_history_model.dart';
import '../services/patient_history_repository.dart';

class PatientHistoryViewModel extends ChangeNotifier {
  PatientHistoryViewModel({
    PatientHistoryRepository? repository,
    DateTime Function()? nowProvider,
  }) : _repository = repository ?? SupabasePatientHistoryRepository(),
       _nowProvider = nowProvider ?? DateTime.now;

  final PatientHistoryRepository _repository;
  final DateTime Function() _nowProvider;

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

  ProgressMetrics _historyMetrics = const ProgressMetrics.empty();
  ProgressMetrics get historyMetrics => _historyMetrics;

  ProgressMetrics _homeMetrics = const ProgressMetrics.empty();
  ProgressMetrics get homeMetrics => _homeMetrics;

  bool _isLoadingHomeMetrics = false;
  bool get isLoadingHomeMetrics => _isLoadingHomeMetrics;

  String? _homeMetricsErrorMessage;
  String? get homeMetricsErrorMessage => _homeMetricsErrorMessage;

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
      _historyMetrics = _buildMetrics(
        sessions: _sessions,
        emotions: _emotions,
        rangeDays: _selectedRangeDays,
      );
      if (_selectedRangeDays == 7) {
        _homeMetrics = _historyMetrics;
        _homeMetricsErrorMessage = null;
      }
    } catch (_) {
      _errorMessage =
          'No se pudo cargar el historial personal. Intenta nuevamente.';
      _sessions = const [];
      _emotions = const [];
      _thoughts = const [];
      _historyMetrics = const ProgressMetrics.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedRangeDays = 7;
    _isLoading = false;
    _errorMessage = null;
    _sessions = const [];
    _emotions = const [];
    _thoughts = const [];
    _historyMetrics = const ProgressMetrics.empty();
    _homeMetrics = const ProgressMetrics.empty();
    _isLoadingHomeMetrics = false;
    _homeMetricsErrorMessage = null;
    notifyListeners();
  }

  Future<void> setRangeDays(int days) async {
    if (!allowedRanges.contains(days)) return;
    if (_selectedRangeDays == days) return;
    _selectedRangeDays = days;
    notifyListeners();
    await loadHistory(force: true);
  }

  Future<void> loadHomeMetrics({bool force = false}) async {
    if (_isLoadingHomeMetrics && !force) return;

    _isLoadingHomeMetrics = true;
    _homeMetricsErrorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getSessions(7),
        _repository.getAssessments(7),
      ]);

      final sessions = (results[0] as List<HistorySessionItem>)
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      final emotions = (results[1] as List<HistoryEmotionItem>)
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

      _homeMetrics = _buildMetrics(
        sessions: sessions,
        emotions: emotions,
        rangeDays: 7,
      );
    } catch (_) {
      _homeMetricsErrorMessage =
          'No se pudo cargar tu progreso reciente. Intenta nuevamente.';
      _homeMetrics = const ProgressMetrics.empty();
    } finally {
      _isLoadingHomeMetrics = false;
      notifyListeners();
    }
  }

  ProgressMetrics _buildMetrics({
    required List<HistorySessionItem> sessions,
    required List<HistoryEmotionItem> emotions,
    required int rangeDays,
  }) {
    final completedSessions = sessions
        .where((session) => session.status == HistorySessionStatus.completed)
        .toList();

    final activeDays = <String>{};
    for (final session in completedSessions) {
      activeDays.add(_dayKey(session.startedAt));
    }

    final now = _nowProvider().toLocal();
    final weekStart = _startOfWeekMonday(now);
    final weekEndExclusive = weekStart.add(const Duration(days: 7));

    final weeklyActiveDays = completedSessions
        .where((session) {
          final startedAt = session.startedAt.toLocal();
          return !startedAt.isBefore(weekStart) &&
              startedAt.isBefore(weekEndExclusive);
        })
        .map((session) => _dayKey(session.startedAt))
        .toSet()
        .length;

    final completedSessionIds = completedSessions
        .map((session) => session.id)
        .toSet();

    var assessableSessions = 0;
    var improvedSessions = 0;
    for (final emotion in emotions) {
      final sessionId = emotion.sessionId;
      if (sessionId == null || !completedSessionIds.contains(sessionId)) {
        continue;
      }
      if (!emotion.hasPost) continue;
      assessableSessions += 1;
      if ((emotion.postIntensity ?? emotion.preIntensity) <
          emotion.preIntensity) {
        improvedSessions += 1;
      }
    }

    return ProgressMetrics(
      activeDaysInRange: activeDays.length,
      completedSessionsInRange: completedSessions.length,
      weeklyActiveDays: weeklyActiveDays,
      weeklyTargetDays: 7,
      improvedSessions: improvedSessions,
      assessableSessions: assessableSessions,
    );
  }

  DateTime _startOfWeekMonday(DateTime value) {
    final localDate = DateTime(value.year, value.month, value.day);
    return localDate.subtract(Duration(days: localDate.weekday - 1));
  }

  String _dayKey(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month}-${local.day}';
  }
}
