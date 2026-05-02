import 'dart:io';
import 'package:flutter/material.dart';

import '../model_ps/routine_model.dart';
import '../services_ps/routines_service.dart';

class RoutinesViewModel2 extends ChangeNotifier {
  final _service = RoutinesService();
  List<RoutineTemplate> routines = [];
  List<String> categories = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadRoutines() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      routines = await _service.getAllRoutines();
      // También cargamos las categorías dinámicas si la lista está vacía
      if (categories.isEmpty) {
        categories = await _service.getEnumCategories();
      }
    } catch (e) {
      errorMessage = "No se pudieron cargar las plantillas";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Método para recargar categorías manualmente si es necesario
  Future<void> loadCategories() async {
    try {
      categories = await _service.getEnumCategories();
      notifyListeners();
    } catch (_) {}
  }

  /// Método principal dinámico para guardar cualquier tipo de rutina
  Future<bool> saveFullRoutine({
    required String title,
    required String description,
    required String category,
    required int durationSeconds,
    // Para respiración
    int? inhale,
    int? holdIn,
    int? exhale,
    int? holdOut,
    // Para audio
    File? audioFile,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Paso A: Crear la rutina base
      final routineData = await _service.createBaseRoutine(
        title: title,
        description: description,
        category: category,
        durationSeconds: durationSeconds,
      );

      final routineId = routineData['id'] as String;

      // Paso C: Lógica condicional según categoría
      if (category == 'breathing') {
        if (inhale == null ||
            holdIn == null ||
            exhale == null ||
            holdOut == null) {
          throw Exception("Faltan datos del patron de respiracion");
        }
        await _service.saveBreathingPattern(
          routineId: routineId,
          inhale: inhale,
          holdIn: holdIn,
          exhale: exhale,
          holdOut: holdOut,
        );
      } else if (category == 'soundscape' || category == 'relaxation') {
        if (audioFile == null) {
          throw Exception(
            "Debes subir un archivo de audio para esta categoria",
          );
        }
        await _service.uploadRoutineAudio(
          routineId: routineId,
          audioFile: audioFile,
        );
      }

      await loadRoutines();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Error al guardar rutina: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignToPatient(String patientId, String routineId) async {
    await _service.assignTask(patientId, routineId);
  }
}
