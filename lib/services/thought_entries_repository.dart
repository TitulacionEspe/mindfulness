import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/thought_entry_model.dart';

abstract class ThoughtEntriesRepository {
  Future<List<ThoughtEntryModel>> listByPatient();
  Future<ThoughtEntryModel> create({required String content});
  Future<ThoughtEntryModel> update({
    required String id,
    required String content,
  });
  Future<void> delete({required String id});
}

class SupabaseThoughtEntriesRepository implements ThoughtEntriesRepository {
  SupabaseThoughtEntriesRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<ThoughtEntryModel>> listByPatient() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('thought_entries')
        .select('id,patient_id,content_ciphertext,created_at,updated_at')
        .eq('patient_id', user.id)
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(ThoughtEntryModel.fromJson).toList();
  }

  @override
  Future<ThoughtEntryModel> create({required String content}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('thought_entries')
        .insert({'patient_id': user.id, 'content_ciphertext': content.trim()})
        .select('id,patient_id,content_ciphertext,created_at,updated_at')
        .single();

    return ThoughtEntryModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<ThoughtEntryModel> update({
    required String id,
    required String content,
  }) async {
    final response = await _client
        .from('thought_entries')
        .update({
          'content_ciphertext': content.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select('id,patient_id,content_ciphertext,created_at,updated_at')
        .single();

    return ThoughtEntryModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<void> delete({required String id}) async {
    await _client.from('thought_entries').delete().eq('id', id);
  }
}
