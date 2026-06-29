import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/ai_parser.dart';
import '../models/chat_message_model.dart';

/// Resultado de enviar un mensaje: el mensaje del usuario y la respuesta del
/// asistente ya persistidos, más la señal de sugerir una cita.
class ChatSendResult {
  const ChatSendResult({
    required this.userMessage,
    required this.assistantMessage,
    required this.suggestAppointment,
  });

  final ChatMessageModel userMessage;
  final ChatMessageModel assistantMessage;
  final bool suggestAppointment;
}

abstract class ChatRepository {
  Future<List<ChatMessageModel>> listByPatient();
  Future<ChatSendResult> sendMessage({
    required String text,
    required List<ChatMessageModel> history,
  });
  Future<void> clearHistory();
}

class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _columns = 'id,patient_id,role,content,risk_level,created_at';

  @override
  Future<List<ChatMessageModel>> listByPatient() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('chat_messages')
        .select(_columns)
        .eq('patient_id', user.id)
        .order('created_at', ascending: true);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(ChatMessageModel.fromJson).toList();
  }

  @override
  Future<ChatSendResult> sendMessage({
    required String text,
    required List<ChatMessageModel> history,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final trimmed = text.trim();

    // 1. Persiste el mensaje del usuario.
    final userRow = await _client
        .from('chat_messages')
        .insert({
          'patient_id': user.id,
          'role': 'user',
          'content': trimmed,
          'risk_level': 'none',
        })
        .select(_columns)
        .single();
    final userMessage = ChatMessageModel.fromJson(
      Map<String, dynamic>.from(userRow),
    );

    Map<String, dynamic> map = {};
    var cleanReply = AiParser.assistantUnavailableReply;

    // 2. Llama a la Edge Function (la API key vive en el servidor).
    // Si la IA falla por cuota, red o JSON inválido, mantenemos el flujo del
    // chat con una respuesta clara y no mostramos fragmentos técnicos.
    try {
      final invokeResponse = await _client.functions.invoke(
        'emotional-chat',
        body: {
          'message': trimmed,
          'history': history
              .map(
                (m) => {
                  'role': ChatMessageModel.roleToString(m.role),
                  'content': m.content,
                },
              )
              .toList(),
        },
      );

      final data = invokeResponse.data;
      if (data is Map) {
        map = Map<String, dynamic>.from(data);
        if (AiParser.isUnavailablePayload(map)) {
          cleanReply = AiParser.assistantUnavailableReply;
        } else {
          final rawReply = (map['reply'] as String?)?.trim() ?? '';
          cleanReply = AiParser.cleanAssistantReply(
            rawReply,
            fallback: AiParser.assistantUnavailableReply,
          );
        }
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            map = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}

        if (map.isNotEmpty && AiParser.isUnavailablePayload(map)) {
          cleanReply = AiParser.assistantUnavailableReply;
        } else {
          cleanReply = AiParser.cleanAssistantReply(
            data,
            fallback: AiParser.assistantUnavailableReply,
          );
        }
      }
    } catch (_) {
      cleanReply = AiParser.assistantUnavailableReply;
    }

    final riskLevel = ChatMessageModel.riskFromString(
      map['riskLevel'] as String?,
    );
    final suggestAppointment = map['suggestAppointment'] == true;

    // 3. Persiste la respuesta del asistente.
    final assistantRow = await _client
        .from('chat_messages')
        .insert({
          'patient_id': user.id,
          'role': 'assistant',
          'content': cleanReply,
          'risk_level': ChatMessageModel.riskToString(riskLevel),
        })
        .select(_columns)
        .single();
    final assistantMessage = ChatMessageModel.fromJson(
      Map<String, dynamic>.from(assistantRow),
    );

    return ChatSendResult(
      userMessage: userMessage,
      assistantMessage: assistantMessage,
      suggestAppointment: suggestAppointment,
    );
  }

  @override
  Future<void> clearHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    await _client.from('chat_messages').delete().eq('patient_id', user.id);
  }
}
