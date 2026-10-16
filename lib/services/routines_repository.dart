import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/assigned_activity_model.dart';
import '../models/routine_model.dart';

abstract class RoutinesDataSource {
  Future<List<RoutineModel>> fetchRoutines();
  Future<String> startSession({
    required String routineId,
    required DateTime startedAt,
  });
  Future<void> completeSession({
    required String sessionId,
    required DateTime completedAt,
  });
  Future<List<AssignedActivityModel>> fetchAssignedActivities();
}

class RoutinesRepository implements RoutinesDataSource {
  RoutinesRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<RoutineModel>> fetchRoutines() async {
    final routinesResponse = await _client
        .from('routines')
        .select('id,title,description,category,duration_seconds,created_by')
        .eq('is_active', true)
        .order('duration_seconds', ascending: true);

    final routines = List<Map<String, dynamic>>.from(routinesResponse as List);
    if (routines.isEmpty) return const [];

    final routineIds = routines.map((r) => r['id'] as String).toList();

    // 1. Obtener patrones de respiración
    final patternsResponse = await _client
        .from('breathing_patterns')
        .select(
          'routine_id,inhale_sec,hold_in_sec,exhale_sec,hold_out_sec,cycles_recommended',
        )
        .inFilter('routine_id', routineIds);

    final patternRows = List<Map<String, dynamic>>.from(
      patternsResponse as List,
    );
    final patternsByRoutine = {
      for (final row in patternRows)
        row['routine_id'] as String: BreathingPatternModel.fromMap(row),
    };

    // 2. Obtener assets de audio
    final audiosByRoutine = await _fetchAudioAssets(routineIds);

    return routines
        .map(
          (row) => RoutineModel.fromMap(
            row,
            breathingPattern: patternsByRoutine[row['id'] as String],
            audioUrl: audiosByRoutine[row['id'] as String],
          ),
        )
        .toList();
  }

  Future<Map<String, String>> _fetchAudioAssets(List<String> routineIds) async {
    if (routineIds.isEmpty) return {};

    try {
      final assetsResponse = await _client
          .from('routine_assets')
          .select('routine_id,storage_path,file_type')
          .eq('is_active', true)
          .inFilter('routine_id', routineIds);

      final assetRows = List<Map<String, dynamic>>.from(assetsResponse as List);
      final audiosByRoutine = <String, String>{};

      for (final row in assetRows) {
        final path = row['storage_path'] as String;
        final type = (row['file_type'] as String?)?.toLowerCase() ?? '';

        // Aceptamos cualquier asset que parezca audio o que sea el único asset de la rutina
        if (type.contains('audio') ||
            type.contains('mp3') ||
            type.contains('wav') ||
            path.contains('.mp3') ||
            path.startsWith('http')) {
          // Si el path ya es una URL externa, la usamos directamente
          if (path.startsWith('http')) {
            audiosByRoutine[row['routine_id'] as String] = path;
          } else {
            final url = _client.storage
                .from('routine-assets')
                .getPublicUrl(path);
            audiosByRoutine[row['routine_id'] as String] = url;
          }
        }
      }
      return audiosByRoutine;
    } catch (e) {
      debugPrint("Error fetching audio assets: $e");
      return {};
    }
  }

  @override
  Future<String> startSession({
    required String routineId,
    required DateTime startedAt,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('activity_sessions')
        .insert({
          'patient_id': user.id,
          'routine_id': routineId,
          'started_at': startedAt.toIso8601String(),
          'status': 'interrupted',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required DateTime completedAt,
  }) async {
    await _client
        .from('activity_sessions')
        .update({
          'completed_at': completedAt.toIso8601String(),
          'status': 'completed',
        })
        .eq('id', sessionId);
  }

  @override
  Future<List<AssignedActivityModel>> fetchAssignedActivities() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];

    final assignmentsResponse = await _client
        .from('assignments')
        .select('id,routine_id,status,assigned_at,target_completion')
        .eq('patient_id', user.id)
        .order('assigned_at', ascending: false);

    final assignmentRows = List<Map<String, dynamic>>.from(
      assignmentsResponse as List,
    );
    if (assignmentRows.isEmpty) return const [];

    final routineIds = assignmentRows
        .map((row) => row['routine_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final routinesResponse = await _client
        .from('routines')
        .select('id,title,description,category,duration_seconds')
        .inFilter('id', routineIds);

    final routineRows = List<Map<String, dynamic>>.from(
      routinesResponse as List,
    );

    // 1. Cargar patrones de respiración
    final patternsResponse = await _client
        .from('breathing_patterns')
        .select(
          'routine_id,inhale_sec,hold_in_sec,exhale_sec,hold_out_sec,cycles_recommended',
        )
        .inFilter('routine_id', routineIds);

    final patternRows = List<Map<String, dynamic>>.from(
      patternsResponse as List,
    );
    final patternsByRoutine = {
      for (final row in patternRows)
        row['routine_id'] as String: BreathingPatternModel.fromMap(row),
    };

    // 2. Cargar assets de audio para rutinas asignadas (NUEVO)
    final audiosByRoutine = await _fetchAudioAssets(routineIds);

    final routinesById = {
      for (final row in routineRows)
        row['id'] as String: RoutineModel.fromMap(
          row,
          breathingPattern: patternsByRoutine[row['id'] as String],
          audioUrl: audiosByRoutine[row['id'] as String],
        ),
    };

    final result = <AssignedActivityModel>[];
    for (final row in assignmentRows) {
      final routineId = row['routine_id'] as String?;
      if (routineId == null) continue;

      final routine = routinesById[routineId];
      if (routine == null) continue;

      final assignedAtRaw = row['assigned_at'] as String?;
      final targetCompletionRaw = row['target_completion'] as String?;

      result.add(
        AssignedActivityModel(
          id: row['id'] as String,
          routineId: routineId,
          routine: routine,
          status: AssignmentStatusX.fromValue(row['status'] as String?),
          assignedAt: assignedAtRaw != null
              ? DateTime.tryParse(assignedAtRaw) ?? DateTime.now()
              : DateTime.now(),
          targetCompletion: targetCompletionRaw != null
              ? DateTime.tryParse(targetCompletionRaw)
              : null,
        ),
      );
    }

    return result;
  }
}
