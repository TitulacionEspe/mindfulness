import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sleep_log_model.dart';

abstract class SleepLogsRepository {
  Future<List<SleepLogModel>> listRecent({int limit = 7});
  Future<SleepLogModel> create({
    required DateTime bedTime,
    required DateTime wakeTime,
    required int sleepQualityRating,
    int? sleepLatencyMin,
    int? wakeAfterSleepOnsetMin,
    String? disturbances,
  });
}

class SupabaseSleepLogsRepository implements SleepLogsRepository {
  SupabaseSleepLogsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<SleepLogModel>> listRecent({int limit = 7}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final response = await _client
        .from('sleep_logs')
        .select()
        .eq('patient_id', user.id)
        .order('log_date', ascending: false)
        .limit(limit);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(SleepLogModel.fromJson).toList();
  }

  @override
  Future<SleepLogModel> create({
    required DateTime bedTime,
    required DateTime wakeTime,
    required int sleepQualityRating,
    int? sleepLatencyMin,
    int? wakeAfterSleepOnsetMin,
    String? disturbances,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final response = await _client
        .from('sleep_logs')
        .insert({
          'patient_id': user.id,
          'log_date': _dateOnlyIso(DateTime.now()),
          'bed_time': bedTime.toUtc().toIso8601String(),
          'wake_time': wakeTime.toUtc().toIso8601String(),
          'sleep_latency_min': sleepLatencyMin,
          'wake_after_sleep_onset_min': wakeAfterSleepOnsetMin,
          'sleep_quality_rating': sleepQualityRating,
          'disturbances': disturbances?.trim().isEmpty == true
              ? null
              : disturbances?.trim(),
        })
        .select()
        .single();

    return SleepLogModel.fromJson(Map<String, dynamic>.from(response));
  }

  String _dateOnlyIso(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
