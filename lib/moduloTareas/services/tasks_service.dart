import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/assignment_model.dart';

class TasksService {
  final _db = Supabase.instance.client;

  /// Obtiene todas las asignaciones del paciente actual
  Future<List<Assignment>> getAllPatientTasks() async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return [];

      final response = await _db
          .from('assignments')
          .select('''
            *,
            routines:routine_id (
              id,
              title,
              description,
              category,
              breathing_patterns (
                inhale_sec,
                hold_in_sec,
                exhale_sec,
                hold_out_sec,
                cycles_recommended
              )
            )
          ''')
          .eq('patient_id', user.id)
          .order('assigned_at', ascending: false);

      return (response as List)
          .map((json) => Assignment.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint("TasksService Error (getAllPatientTasks): $e");
      return [];
    }
  }

  /// Registra el inicio de una sesión
  Future<String> createSession(String routineId) async {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception("No autenticado");

    final res = await _db
        .from('activity_sessions')
        .insert({
          'patient_id': user.id,
          'routine_id': routineId,
          'status': 'interrupted',
          'started_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();

    return res['id'].toString();
  }

  /// Marca como completada tanto la sesión como la asignación
  Future<void> completeTask(String sessionId, String assignmentId) async {
    try {
      // 1. Actualizar sesión de actividad
      await _db
          .from('activity_sessions')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);

      // 2. Actualizar estado de la asignación
      await _db
          .from('assignments')
          .update({'status': 'completed'})
          .eq('id', assignmentId);

      debugPrint("Sincronización de completado exitosa para: $assignmentId");
    } catch (e) {
      debugPrint("TasksService Error (completeTask): $e");
      rethrow;
    }
  }
}
