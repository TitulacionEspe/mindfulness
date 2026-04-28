import 'package:flutter/material.dart';
import '../model/assignment_model.dart';
import '../services/tasks_service.dart';

class TasksViewModel extends ChangeNotifier {
  final _service = TasksService();

  List<Assignment> pendingTasks = [];
  List<Assignment> completedTasks = [];
  bool isLoading = false;
  String? error;

  /// Carga y clasifica las tareas
  Future<void> loadTasks() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final all = await _service.getAllPatientTasks();
      debugPrint("DEBUG: Tareas crudas recibidas: ${all.length}");

      // Creamos NUEVAS LISTAS para que Flutter detecte el cambio de referencia
      final newPending = all.where((t) => t.status == 'pending').toList();
      final newCompleted = all.where((t) => t.status == 'completed').toList();

      pendingTasks = List.from(newPending);
      completedTasks = List.from(newCompleted);

      debugPrint(
        "DEBUG: Pendientes: ${pendingTasks.length}, Completadas: ${completedTasks.length}",
      );
    } catch (e) {
      error = "No se pudieron cargar las tareas";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Inicia una sesión y retorna su ID
  Future<String?> startSession(String routineId) async {
    try {
      return await _service.createSession(routineId);
    } catch (e) {
      debugPrint("Error al iniciar sesión: $e");
      return null;
    }
  }

  /// Finaliza la tarea y actualiza la lista local
  Future<bool> markAsDone(String sessionId, String assignmentId) async {
    try {
      await _service.completeTask(sessionId, assignmentId);
      await loadTasks(); // Refrescar listas
      return true;
    } catch (e) {
      debugPrint("Error al marcar como hecho: $e");
      return false;
    }
  }
}
