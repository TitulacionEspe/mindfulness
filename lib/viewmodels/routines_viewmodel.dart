import 'package:flutter/material.dart';

import '../models/assigned_activity_model.dart';
import '../models/routine_model.dart';
import '../services/routines_repository.dart';

class RoutinesViewModel extends ChangeNotifier {
  RoutinesViewModel({RoutinesDataSource? repository})
    : _repository = repository ?? RoutinesRepository();

  final RoutinesDataSource _repository;
  bool _hasLoadedData = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCompleting = false;
  bool get isCompleting => _isCompleting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RoutineCategory _selectedCategory = RoutineCategory.all;
  RoutineCategory get selectedCategory => _selectedCategory;

  List<RoutineModel> _routines = const [];
  List<RoutineModel> get routines => _routines;
  List<AssignedActivityModel> _assignedActivities = const [];
  List<AssignedActivityModel> get assignedActivities => _assignedActivities;

  List<RoutineModel> get filteredRoutines {
    if (_selectedCategory == RoutineCategory.all) return _routines;
    return _routines
        .where((routine) => routine.category == _selectedCategory)
        .toList();
  }

  Future<void> loadRoutines({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _hasLoadedData) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routines = await _repository.fetchRoutines();
    } catch (_) {
      _routines = RoutinesRepository.fallbackRoutines;
      _errorMessage =
          'No se pudo sincronizar el catalogo con Supabase. Mostramos rutinas basicas disponibles en el dispositivo.';
    }

    try {
      _assignedActivities = await _repository.fetchAssignedActivities();
    } catch (_) {
      _assignedActivities = const [];
      _errorMessage ??=
          'No se pudo cargar actividades asignadas por tu psicologa.';
    } finally {
      _hasLoadedData = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _hasLoadedData = false;
    _isLoading = false;
    _isCompleting = false;
    _errorMessage = null;
    _selectedCategory = RoutineCategory.all;
    _routines = const [];
    _assignedActivities = const [];
    notifyListeners();
  }

  void selectCategory(RoutineCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<String?> startSession({
    required RoutineModel routine,
    required DateTime startedAt,
  }) async {
    _isCompleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.startSession(
        routineId: routine.id,
        startedAt: startedAt,
      );
    } catch (_) {
      _errorMessage =
          'No se pudo iniciar la sesion. Verifica tu conexion e intenta nuevamente.';
      return null;
    } finally {
      _isCompleting = false;
      notifyListeners();
    }
  }

  Future<bool> completeSession({required String sessionId}) async {
    _isCompleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.completeSession(
        sessionId: sessionId,
        completedAt: DateTime.now(),
      );
      return true;
    } catch (_) {
      _errorMessage =
          'La rutina termino, pero no se pudo guardar el registro. Intenta nuevamente con conexion.';
      return false;
    } finally {
      _isCompleting = false;
      notifyListeners();
    }
  }
}
