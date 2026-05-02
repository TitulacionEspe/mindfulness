import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model_ps/routine_model.dart';

class RoutinesService {
  final _db = Supabase.instance.client;

  Future<List<RoutineTemplate>> getAllRoutines() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await _db
        .from('routines')
        .select()
        .eq('created_by', userId)
        .eq('is_active', true);

    return (res as List).map((j) => RoutineTemplate.fromJson(j)).toList();
  }

  /// Obtiene las categorías del ENUM routine_category reflejando la estructura de Supabase
  Future<List<String>> getEnumCategories() async {
    // Sincronizado manualmente con el CREATE TYPE routine_category de Supabase
    return [
      'relaxation',
      'breathing',
      'sleep_induction',
      'soundscape',
      'terapia_sonido'
    ];
  }

  /// Paso A: Crear la rutina base
  Future<Map<String, dynamic>> createBaseRoutine({
    required String title,
    required String description,
    required String category,
    required int durationSeconds,
  }) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception("Sesion no iniciada");

    return await _db
        .from('routines')
        .insert({
          'title': title,
          'description': description,
          'category': category,
          'duration_seconds': durationSeconds,
          'created_by': userId,
          'content_status': 'active',
          'is_visible_to_patients': true,
        })
        .select()
        .single();
  }

  /// Paso C (Opción Respiración): Guardar patrón
  Future<void> saveBreathingPattern({
    required String routineId,
    required int inhale,
    required int holdIn,
    required int exhale,
    required int holdOut,
  }) async {
    await _db.from('breathing_patterns').insert({
      'routine_id': routineId,
      'inhale_sec': inhale,
      'hold_in_sec': holdIn,
      'exhale_sec': exhale,
      'hold_out_sec': holdOut,
      'cycles_recommended': 5,
    });
  }

  /// Paso C (Opción Audio): Subir a Storage y guardar en routine_assets
  Future<void> uploadRoutineAudio({
    required String routineId,
    required File audioFile,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(audioFile.path)}';
    final storagePath = 'routines/$routineId/$fileName';

    // 1. Subir al bucket 'routine-assets'
    await _db.storage
        .from('routine-assets')
        .upload(
          storagePath,
          audioFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    // 2. Registrar en routine_assets
    await _db.from('routine_assets').insert({
      'routine_id': routineId,
      'storage_bucket': 'routine-assets',
      'storage_path': storagePath,
      'file_type': 'audio',
      'file_size_bytes': await audioFile.length(),
    });
  }

  Future<void> assignTask(String patientId, String routineId) async {
    final proId = _db.auth.currentUser?.id;
    if (proId == null) throw Exception("Sesion profesional no valida");

    await _db.from('assignments').insert({
      'patient_id': patientId,
      'professional_id': proId,
      'routine_id': routineId,
      'status': 'pending',
    });
  }
}
