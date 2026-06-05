import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalIAChatMessage {
  final String? id;
  final String professionalId;
  final String role;
  final String content;
  final String category;
  final DateTime? createdAt;

  ProfessionalIAChatMessage({
    this.id,
    required this.professionalId,
    required this.role,
    required this.content,
    this.category = 'general',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'professional_id': professionalId,
      'role': role,
      'content': content,
      'category': category,
    };
  }

  factory ProfessionalIAChatMessage.fromMap(Map<String, dynamic> map) {
    return ProfessionalIAChatMessage(
      id: map['id'],
      professionalId: map['professional_id'],
      role: map['role'],
      content: map['content'],
      category: map['category'] ?? 'general',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class IAChatService {
  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// Modelo gratuito en OpenRouter (Gemini 2.0 Flash)
  static const _model = 'meta-llama/llama-3.1-8b-instruct';

  static const _systemPrompt =
      'Eres un asistente experto en psicología y mindfulness. '
      'Tu objetivo es ayudar a profesionales de la salud mental a generar contenido '
      'terapéutico, visualizaciones guiadas, guías de respiración y resúmenes. '
      'Mantén un tono profesional, empático y técnico. '
      'Responde siempre en español.';

  final SupabaseClient _supabase = Supabase.instance.client;

  String? _apiKey;

  String get _key {
    _apiKey ??= dotenv.env['OPENROUTER_API_KEY'];
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OPENROUTER_API_KEY no encontrada en el archivo .env');
    }
    return _apiKey!;
  }

  // ── Gestión del Historial en Supabase ──────────────────────────────────────

  /// Obtiene el historial de chat para el profesional actual
  Future<List<ProfessionalIAChatMessage>> getChatHistory(
    String professionalId,
  ) async {
    try {
      final response = await _supabase
          .from('professional_ia_chat')
          .select()
          .eq('professional_id', professionalId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((m) => ProfessionalIAChatMessage.fromMap(m))
          .toList();
    } catch (e) {
      print('Error al obtener historial IA: $e');
      return [];
    }
  }

  /// Guarda un mensaje en el historial
  Future<void> saveMessage(ProfessionalIAChatMessage message) async {
    try {
      await _supabase.from('professional_ia_chat').insert(message.toMap());
    } catch (e) {
      print('Error al guardar mensaje IA: $e');
    }
  }

  // ── Eliminación de mensajes ──────────────────────────────────────────────

  /// Elimina mensajes específicos por sus IDs
  Future<void> deleteMessages(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      await _supabase.from('professional_ia_chat').delete().inFilter('id', ids);
    } catch (e) {
      print('Error al eliminar mensajes IA: $e');
    }
  }

  /// Elimina todos los mensajes de un profesional
  Future<void> deleteAllMessages(String professionalId) async {
    try {
      await _supabase
          .from('professional_ia_chat')
          .delete()
          .eq('professional_id', professionalId);
    } catch (e) {
      print('Error al eliminar todos los mensajes IA: $e');
    }
  }

  // ── Integración con OpenRouter (API compatible OpenAI) ─────────────────────

  /// Envía la petición a la IA y devuelve la respuesta
  Future<String> getAIResponse(
    String prompt,
    List<ProfessionalIAChatMessage> history,
  ) async {
    try {
      // Construimos los mensajes en formato OpenAI
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': _systemPrompt},
        for (final msg in history)
          {
            'role': msg.role == 'user' ? 'user' : 'assistant',
            'content': msg.content,
          },
        {'role': 'user', 'content': prompt},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_key',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://mindfulness-espe.app',
          'X-Title': 'Nidara Mindfulness',
        },
        body: jsonEncode({'model': _model, 'messages': messages}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          return message?['content']?.toString() ??
              'La IA no devolvió ninguna respuesta.';
        }
        return 'La IA no devolvió ninguna respuesta.';
      } else {
        print('OpenRouter error ${response.statusCode}: ${response.body}');
        return 'Error del servidor IA (${response.statusCode}). Intenta de nuevo.';
      }
    } catch (e) {
      print('Error en OpenRouter API: $e');
      return 'Lo siento, tuve un error al procesar tu solicitud: $e';
    }
  }
}
