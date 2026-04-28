import 'package:supabase_flutter/supabase_flutter.dart';

import '../model_ps/routine_model.dart';

class RoutinesService {
  final _db = Supabase.instance.client;

  Future<List<RoutineTemplate>> getAllRoutines() async {
    final res = await _db.from('routines').select();
    return (res as List).map((j) => RoutineTemplate.fromJson(j)).toList();
  }

  Future<void> saveRoutineWithPattern({
    required String title,
    required String desc,
    required String cat,
    required Map<String, int> pattern,
  }) async {
    final routine = await _db
        .from('routines')
        .insert({
          'title': title,
          'description': desc,
          'category': cat,
          'duration_seconds': 60,
          'created_by': _db.auth.currentUser!.id,
        })
        .select()
        .single();

    await _db.from('breathing_patterns').insert({
      'routine_id': routine['id'],
      'inhale_sec': pattern['inhale'],
      'hold_in_sec': pattern['hold'],
      'exhale_sec': pattern['exhale'],
      'hold_out_sec': 0,
    });
  }

  Future<void> assignTask(String patientId, String routineId) async {
    await _db.from('assignments').insert({
      'patient_id': patientId,
      'professional_id': _db.auth.currentUser!.id,
      'routine_id': routineId,
      'status': 'pending',
    });
  }
}
