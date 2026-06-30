import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/thought_entry_model.dart';
import 'thought_encryption_service.dart';

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
  SupabaseThoughtEntriesRepository({
    SupabaseClient? client,
    ThoughtEncryptionService? encryptionService,
  }) : _client = client ?? Supabase.instance.client,
       _encryptionService = encryptionService ?? ThoughtEncryptionService();

  final SupabaseClient _client;
  final ThoughtEncryptionService _encryptionService;

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
    final entries = <ThoughtEntryModel>[];
    for (final row in rows) {
      entries.add(await _mapRow(row, user.id));
    }
    return entries;
  }

  @override
  Future<ThoughtEntryModel> create({required String content}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final encryptedContent = await _encryptionService.encrypt(
      content.trim(),
      userId: user.id,
    );

    final response = await _client
        .from('thought_entries')
        .insert({'patient_id': user.id, 'content_ciphertext': encryptedContent})
        .select('id,patient_id,content_ciphertext,created_at,updated_at')
        .single();

    return _mapRow(Map<String, dynamic>.from(response), user.id);
  }

  @override
  Future<ThoughtEntryModel> update({
    required String id,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final encryptedContent = await _encryptionService.encrypt(
      content.trim(),
      userId: user.id,
    );

    final response = await _client
        .from('thought_entries')
        .update({
          'content_ciphertext': encryptedContent,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select('id,patient_id,content_ciphertext,created_at,updated_at')
        .single();

    return _mapRow(Map<String, dynamic>.from(response), user.id);
  }

  @override
  Future<void> delete({required String id}) async {
    await _client.from('thought_entries').delete().eq('id', id);
  }

  Future<ThoughtEntryModel> _mapRow(
    Map<String, dynamic> row,
    String userId,
  ) async {
    final model = ThoughtEntryModel.fromJson(row);
    try {
      final plainText = await _encryptionService.decrypt(
        model.content,
        userId: userId,
      );
      return model.copyWith(content: plainText);
    } on ThoughtDecryptionException {
      return model.copyWith(
        content:
            'No se pudo descifrar esta entrada en este dispositivo. Si cambiaste de equipo, crea una nueva nota para continuar.',
      );
    }
  }
}
