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

  String _searchQuery = '';
  String _selectedCategory = 'Todas';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<RoutineTemplate> get filteredRoutines {
    return routines.where((routine) {
      final matchesSearch =
          routine.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          routine.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesCategory =
          _selectedCategory == 'Todas' || routine.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Map<String, dynamic>> favorites = [];

  /// Indica si el profesional no tiene ninguna rutina creada
  bool get hasNoRoutines => routines.isEmpty && !isLoading;

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
      // Cargamos favoritos preventivamente
      favorites = await _service.getProfessionalFavorites();
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
      favorites = await _service.getProfessionalFavorites();
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
    String? externalAudioUrl,
    String? audioName,
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
          throw Exception("Faltan datos del patrón de respiración");
        }

        // Cálculo de ciclos: duración / (suma de segundos del patrón).
        final cycleSeconds = inhale + holdIn + exhale + holdOut;
        final cyclesRecommended = cycleSeconds > 0
            ? (durationSeconds / cycleSeconds).floor()
            : 1;

        await _service.saveBreathingPattern(
          routineId: routineId,
          inhale: inhale,
          holdIn: holdIn,
          exhale: exhale,
          holdOut: holdOut,
          cyclesRecommended: cyclesRecommended,
        );
      } else if (category == 'soundscape' ||
          category == 'relaxation' ||
          category == 'sleep_induction' ||
          category == 'terapia_sonido') {
        if (externalAudioUrl != null) {
          // Opción A: URL de favoritos
          final label = audioName != null ? "$audioName external" : "external";
          await _service.saveExternalRoutineAudio(
            routineId: routineId,
            externalUrl: externalAudioUrl,
            bucketLabel: label,
          );
        } else if (audioFile != null) {
          // Opción B: Archivo físico
          await _service.uploadRoutineAudio(
            routineId: routineId,
            audioFile: audioFile,
          );
        } else {
          throw Exception(
            "Debes seleccionar un favorito o subir un archivo de audio",
          );
        }
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
