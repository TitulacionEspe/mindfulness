import 'package:flutter/material.dart';

import '../models/sleep_log_model.dart';
import '../services/sleep_logs_repository.dart';

class SleepLogsViewModel extends ChangeNotifier {
  SleepLogsViewModel({SleepLogsRepository? repository})
    : _repository = repository ?? SupabaseSleepLogsRepository();

  final SleepLogsRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<SleepLogModel> _logs = const [];
  List<SleepLogModel> get logs => _logs;

  Future<void> loadLogs({bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _logs = await _repository.listRecent(limit: 7);
    } catch (_) {
      _errorMessage =
          'No se pudieron cargar tus registros de sueño. Intenta nuevamente.';
      _logs = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLog({
    required TimeOfDay bedTime,
    required TimeOfDay wakeTime,
    required int sleepQualityRating,
    int? sleepLatencyMin,
    int? wakeAfterSleepOnsetMin,
    String? disturbances,
  }) async {
    final validationError = _validate(
      sleepQualityRating: sleepQualityRating,
      sleepLatencyMin: sleepLatencyMin,
      wakeAfterSleepOnsetMin: wakeAfterSleepOnsetMin,
      disturbances: disturbances,
    );
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final (bedDateTime, wakeDateTime) = _resolveSleepPeriod(
        bedTime,
        wakeTime,
      );
      final created = await _repository.create(
        bedTime: bedDateTime,
        wakeTime: wakeDateTime,
        sleepQualityRating: sleepQualityRating,
        sleepLatencyMin: sleepLatencyMin,
        wakeAfterSleepOnsetMin: wakeAfterSleepOnsetMin,
        disturbances: disturbances,
      );
      _logs = [created, ..._logs].take(7).toList();
      _successMessage = 'Registro de sueño guardado.';
      return true;
    } catch (_) {
      _errorMessage =
          'No se pudo guardar el registro de sueño. Revisa tu conexión e intenta nuevamente.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _logs = const [];
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String? _validate({
    required int sleepQualityRating,
    int? sleepLatencyMin,
    int? wakeAfterSleepOnsetMin,
    String? disturbances,
  }) {
    if (sleepQualityRating < 1 || sleepQualityRating > 5) {
      return 'Selecciona una calidad de sueño entre 1 y 5.';
    }
    if (sleepLatencyMin != null && sleepLatencyMin < 0) {
      return 'El tiempo para dormir no puede ser negativo.';
    }
    if (wakeAfterSleepOnsetMin != null && wakeAfterSleepOnsetMin < 0) {
      return 'El tiempo despierto durante la noche no puede ser negativo.';
    }
    if ((disturbances ?? '').trim().length > 240) {
      return 'La nota no debe superar 240 caracteres.';
    }
    return null;
  }

  (DateTime, DateTime) _resolveSleepPeriod(TimeOfDay bed, TimeOfDay wake) {
    final now = DateTime.now();
    final bedDate = DateTime(
      now.year,
      now.month,
      now.day,
      bed.hour,
      bed.minute,
    );
    var wakeDate = DateTime(
      now.year,
      now.month,
      now.day,
      wake.hour,
      wake.minute,
    );
    if (!wakeDate.isAfter(bedDate)) {
      wakeDate = wakeDate.add(const Duration(days: 1));
    }
    return (bedDate, wakeDate);
  }
}
