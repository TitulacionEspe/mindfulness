import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/model_psicologa/patient_model.dart';
import '../../models/routine_model.dart';

class PsychologistRepository {
  final _client = Supabase.instance.client;

  Future<List<PatientModel>> getPatients() async {
    try {
      // 1. Obtener todos los perfiles que son pacientes
      final List<dynamic> patientsData = await _client
          .from('profiles')
          .select('id, full_name, email')
          .eq('role', 'patient')
          .eq('is_active', true);

      final List<PatientModel> patients = [];

      for (var data in patientsData) {
        final patientId = data['id'];

        // 2. Obtener estadísticas de asignaciones para este paciente
        // Nota: En una app real, esto se optimizaría con una View en SQL o una RPC
        final assignmentsResponse = await _client
            .from('assignments')
            .select('status, routines(title)')
            .eq('patient_id', patientId);

        final List<dynamic> assignments = assignmentsResponse as List<dynamic>;

        int total = assignments.length;
        int completed = assignments
            .where((a) => a['status'] == 'completed')
            .length;

        double progress = total > 0 ? (completed / total) : 0.0;

        // Obtener la tarea más reciente (asumiendo que la última en la lista es la más nueva o podríamos ordenar por fecha)
        String? latestTask;
        if (assignments.isNotEmpty) {
          // Intentamos sacar el título de la rutina si existe el join
          final routineData = assignments.last['routines'];
          if (routineData != null) {
            latestTask = routineData['title'] as String?;
          }
        }

        patients.add(
          PatientModel.fromMap(
            data as Map<String, dynamic>,
            progress: progress,
            totalAssigned: total,
            totalCompleted: completed,
            currentTask: latestTask,
          ),
        );
      }

      return patients;
    } catch (e) {
      throw Exception('Error al obtener pacientes: $e');
    }
  }

  Future<void> assignRoutine({
    required String patientId,
    required String professionalId,
    required String routineId,
    DateTime? targetCompletion,
  }) async {
    try {
      await _client.from('assignments').insert({
        'patient_id': patientId,
        'professional_id': professionalId,
        'routine_id': routineId,
        'status': 'pending',
        'target_completion': targetCompletion?.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al asignar rutina: $e');
    }
  }

  Future<List<RoutineModel>> getAvailableRoutines() async {
    try {
      final List<dynamic> data = await _client
          .from('routines')
          .select('*')
          .eq('is_active', true)
          .eq('is_visible_to_patients', true);

      return data
          .map((r) => RoutineModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener rutinas: $e');
    }
  }
}
