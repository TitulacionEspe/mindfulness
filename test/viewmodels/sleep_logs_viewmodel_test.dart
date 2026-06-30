import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/models/sleep_log_model.dart';
import 'package:mindfulness_app/services/sleep_logs_repository.dart';
import 'package:mindfulness_app/viewmodels/sleep_logs_viewmodel.dart';

class _FakeSleepLogsRepository implements SleepLogsRepository {
  _FakeSleepLogsRepository({this.failList = false});

  final bool failList;
  final List<SleepLogModel> created = [];

  @override
  Future<List<SleepLogModel>> listRecent({int limit = 7}) async {
    if (failList) throw Exception('network');
    return created.take(limit).toList();
  }

  @override
  Future<SleepLogModel> create({
    required DateTime bedTime,
    required DateTime wakeTime,
    required int sleepQualityRating,
    int? sleepLatencyMin,
    int? wakeAfterSleepOnsetMin,
    String? disturbances,
  }) async {
    final log = SleepLogModel(
      id: 'log-${created.length + 1}',
      patientId: 'patient-1',
      logDate: DateTime(bedTime.year, bedTime.month, bedTime.day),
      bedTime: bedTime,
      wakeTime: wakeTime,
      sleepLatencyMin: sleepLatencyMin,
      wakeAfterSleepOnsetMin: wakeAfterSleepOnsetMin,
      sleepQualityRating: sleepQualityRating,
      disturbances: disturbances?.trim(),
      recordedAt: DateTime.now(),
    );
    created.insert(0, log);
    return log;
  }
}

void main() {
  group('SleepLogsViewModel', () {
    test('carga registros vacíos sin error', () async {
      final viewModel = SleepLogsViewModel(
        repository: _FakeSleepLogsRepository(),
      );

      await viewModel.loadLogs();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.logs, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('guarda registro válido y muestra confirmación', () async {
      final viewModel = SleepLogsViewModel(
        repository: _FakeSleepLogsRepository(),
      );

      final success = await viewModel.createLog(
        bedTime: const TimeOfDay(hour: 22, minute: 30),
        wakeTime: const TimeOfDay(hour: 6, minute: 45),
        sleepQualityRating: 4,
        sleepLatencyMin: 20,
        disturbances: 'Sin interrupciones',
      );

      expect(success, isTrue);
      expect(viewModel.isSaving, isFalse);
      expect(viewModel.logs, hasLength(1));
      expect(viewModel.successMessage, 'Registro de sueño guardado.');
    });

    test('previene calidad de sueño fuera de rango', () async {
      final viewModel = SleepLogsViewModel(
        repository: _FakeSleepLogsRepository(),
      );

      final success = await viewModel.createLog(
        bedTime: const TimeOfDay(hour: 23, minute: 0),
        wakeTime: const TimeOfDay(hour: 7, minute: 0),
        sleepQualityRating: 6,
      );

      expect(success, isFalse);
      expect(
        viewModel.errorMessage,
        'Selecciona una calidad de sueño entre 1 y 5.',
      );
      expect(viewModel.logs, isEmpty);
    });

    test('muestra error recuperable si falla la carga', () async {
      final viewModel = SleepLogsViewModel(
        repository: _FakeSleepLogsRepository(failList: true),
      );

      await viewModel.loadLogs();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.logs, isEmpty);
      expect(
        viewModel.errorMessage,
        'No se pudieron cargar tus registros de sueño. Intenta nuevamente.',
      );
    });
  });
}
