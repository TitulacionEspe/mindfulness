import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_history_model.dart';

abstract class PatientHistoryRepository {
  Future<List<HistorySessionItem>> getSessions(int rangeDays);
  Future<List<HistoryEmotionItem>> getAssessments(int rangeDays);
  Future<List<HistoryThoughtItem>> getThoughtEntries(int rangeDays);
}

class SupabasePatientHistoryRepository implements PatientHistoryRepository {
  SupabasePatientHistoryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  DateTime _fromDate(int rangeDays) {
    return DateTime.now().subtract(Duration(days: rangeDays));
  }

  String _toIsoUtc(DateTime value) {
    return value.toUtc().toIso8601String();
  }

  int _parseIntensity(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 1;
  }

  @override
  Future<List<HistorySessionItem>> getSessions(int rangeDays) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final fromDate = _fromDate(rangeDays);

    final sessionsResponse = await _client
        .from('activity_sessions')
        .select('id,routine_id,started_at,completed_at,status')
        .eq('patient_id', user.id)
        .gte('started_at', _toIsoUtc(fromDate))
        .order('started_at', ascending: false);

    final sessionRows = List<Map<String, dynamic>>.from(
      sessionsResponse as List,
    );
    if (sessionRows.isEmpty) return const [];

    final routineIds = sessionRows
        .map((row) => row['routine_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final routinesResponse = await _client
        .from('routines')
        .select('id,title')
        .inFilter('id', routineIds);
    final routineRows = List<Map<String, dynamic>>.from(
      routinesResponse as List,
    );
    final routineTitles = {
      for (final row in routineRows)
        row['id'] as String: (row['title'] as String?) ?? 'Rutina',
    };

    final assignmentsResponse = await _client
        .from('assignments')
        .select('routine_id')
        .eq('patient_id', user.id);
    final assignmentRows = List<Map<String, dynamic>>.from(
      assignmentsResponse as List,
    );
    final assignedRoutineIds = assignmentRows
        .map((row) => row['routine_id'] as String?)
        .whereType<String>()
        .toSet();

    return sessionRows.map((row) {
      final routineId = row['routine_id'] as String?;
      final startedAt = DateTime.tryParse(row['started_at'] as String? ?? '');
      final completedAt = DateTime.tryParse(
        row['completed_at'] as String? ?? '',
      );
      return HistorySessionItem(
        id: row['id'] as String,
        routineTitle: routineTitles[routineId] ?? 'Rutina',
        startedAt: startedAt ?? DateTime.now(),
        completedAt: completedAt,
        status: HistorySessionStatusX.fromValue(row['status'] as String?),
        assignmentContext: assignedRoutineIds.contains(routineId)
            ? 'assigned'
            : 'self-initiated',
      );
    }).toList();
  }

  @override
  Future<List<HistoryEmotionItem>> getAssessments(int rangeDays) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final fromDate = _fromDate(rangeDays);
    final response = await _client
        .from('self_assessments')
        .select('id,session_id,context,emotion_id,intensity,recorded_at')
        .eq('patient_id', user.id)
        .gte('recorded_at', _toIsoUtc(fromDate))
        .order('recorded_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(response as List);
    if (rows.isEmpty) return const [];

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final sessionId = (row['session_id'] as String?) ?? row['id'] as String;
      grouped.putIfAbsent(sessionId, () => <Map<String, dynamic>>[]).add(row);
    }

    final result = <HistoryEmotionItem>[];
    for (final entry in grouped.entries) {
      final items = entry.value;
      final pre = items.firstWhere(
        (item) => item['context'] == 'pre_session',
        orElse: () => items.first,
      );
      final post = items.firstWhere(
        (item) => item['context'] == 'post_session',
        orElse: () => <String, dynamic>{},
      );
      final recordedAt = DateTime.tryParse(pre['recorded_at'] as String? ?? '');
      result.add(
        HistoryEmotionItem(
          id: pre['id'] as String,
          sessionId: pre['session_id'] as String?,
          recordedAt: recordedAt ?? DateTime.now(),
          preEmotion: (pre['emotion_id'] as String?) ?? 'sin_emocion',
          preIntensity: _parseIntensity(pre['intensity']),
          postEmotion: post.isEmpty ? null : post['emotion_id'] as String?,
          postIntensity: post.isEmpty
              ? null
              : _parseIntensity(post['intensity']),
        ),
      );
    }

    result.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return result;
  }

  @override
  Future<List<HistoryThoughtItem>> getThoughtEntries(int rangeDays) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final fromDate = _fromDate(rangeDays);
    final response = await _client
        .from('thought_entries')
        .select('id,content_ciphertext,created_at')
        .eq('patient_id', user.id)
        .gte('created_at', _toIsoUtc(fromDate))
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map((row) {
      final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
      final content = (row['content_ciphertext'] as String? ?? '').trim();
      final preview = content.isEmpty
          ? '(Sin contenido)'
          : content.length <= 120
          ? content
          : '${content.substring(0, 120)}...';
      return HistoryThoughtItem(
        id: row['id'] as String,
        createdAt: createdAt ?? DateTime.now(),
        preview: preview,
      );
    }).toList();
  }
}
