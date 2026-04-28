import 'package:flutter/material.dart';

import '../model_ps/routine_model.dart';
import '../services_ps/routines_service.dart';

class RoutinesViewModel2 extends ChangeNotifier {
  final _service = RoutinesService();
  List<RoutineTemplate> routines = [];
  bool isLoading = false;

  Future<void> loadRoutines() async {
    isLoading = true;
    notifyListeners();
    routines = await _service.getAllRoutines();
    isLoading = false;
    notifyListeners();
  }

  Future<void> createBreathingRoutine(
    String title,
    String desc,
    Map<String, int> pattern,
  ) async {
    await _service.saveRoutineWithPattern(
      title: title,
      desc: desc,
      cat: 'respiracion',
      pattern: pattern,
    );
    await loadRoutines();
  }

  Future<void> assignToPatient(String patientId, String routineId) async {
    await _service.assignTask(patientId, routineId);
  }
}
