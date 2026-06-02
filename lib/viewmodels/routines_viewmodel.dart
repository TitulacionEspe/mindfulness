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

  List<AssignedActivityModel> get pendingAssignedActivities {
    final now = DateTime.now();
    return _assignedActivities.where((activity) {
      if (activity.status != AssignmentStatus.pending) return false;
      if (activity.targetCompletion != null &&
          activity.targetCompletion!.isBefore(now)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<RoutineModel> get filteredRoutines {
    // Filtrar primero por creador (solo default/null)
    final baseRoutines = _routines.where(
      (routine) => routine.createdBy == null,
    );

    if (_selectedCategory == RoutineCategory.all) return baseRoutines.toList();
    return baseRoutines
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
          'No se pudo sincronizar el catálogo con Supabase. Mostramos rutinas básicas disponibles en el dispositivo.';
    }

    try {
      _assignedActivities = await _repository.fetchAssignedActivities();
    } catch (_) {
      _assignedActivities = const [];
      _errorMessage ??=
          'No se pudo cargar actividades asignadas por tu psicóloga.';
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
          'No se pudo iniciar la sesión. Verifica tu conexión e intenta nuevamente.';
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
          'La rutina terminó, pero no se pudo guardar el registro. Intenta nuevamente con conexión.';
      return false;
    } finally {
      _isCompleting = false;
      notifyListeners();
    }
  }
}
