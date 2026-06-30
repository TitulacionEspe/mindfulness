import 'dart:convert';

class AiParser {
  static const supportFallbackReply =
      'Estoy aquí para acompañarte. Cuéntame un poco más, con calma.';

  static const assistantUnavailableReply =
      'El asistente de Nidara no está disponible en este momento. Intenta nuevamente más tarde.';

  static const _minimumUsefulCharacters = 12;

  static final RegExp _hasLetterPattern = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]');

  static final List<RegExp> _romanticAddressPatterns = [
    RegExp(
      r'(^|,\s*|\s+)mi\s+(amor|corazón|corazon|vida|cielo|rey|reina)\b[,.!¡¿?\s]*',
      caseSensitive: false,
    ),
    RegExp(
      r'(^|,\s*|\s+)(amor|corazón|corazon|cariño|cariña|corazoncito)\b[,.!¡¿?\s]*',
      caseSensitive: false,
    ),
  ];

  /// Sanea y extrae la respuesta legible de la IA.
  ///
  /// Si la respuesta parece JSON pero está incompleta, devuelve una cadena vacía.
  /// Esto evita que la UI muestre fragmentos como `{ "reply": "` o `Mi`.
  static String cleanAiResponse(String rawText) {
    final extracted = _extractReply(rawText);
    return normalizeSupportTone(extracted);
  }

  static String cleanAssistantReply(
    String rawText, {
    String fallback = supportFallbackReply,
  }) {
    final cleanReply = cleanAiResponse(rawText);
    if (!isUsableAssistantReply(cleanReply)) return fallback;
    return cleanReply;
  }

  static bool isUnavailablePayload(Map<String, dynamic> payload) {
    final available = payload['available'];
    final error = payload['error'];
    return available == false || error != null;
  }

  static bool isUsableAssistantReply(String text) {
    final clean = normalizeSupportTone(text).trim();
    if (clean.isEmpty) return false;
    if (!_hasLetterPattern.hasMatch(clean)) return false;
    if (_looksLikeBrokenStructuredPayload(clean)) return false;

    final lower = clean.toLowerCase();
    if (lower == 'mi' ||
        lower == 'null' ||
        lower == 'undefined' ||
        lower == 'reply') {
      return false;
    }

    final wordCount = RegExp(r'\S+').allMatches(clean).length;
    return clean.length >= _minimumUsefulCharacters || wordCount >= 3;
  }

  static String normalizeSupportTone(String text) {
    var clean = text.trim();
    if (clean.isEmpty) return '';

    for (final pattern in _romanticAddressPatterns) {
      clean = clean.replaceAllMapped(pattern, (match) {
        final prefix = match.group(1) ?? '';
        if (prefix.contains(',')) return '. ';
        return prefix;
      });
    }

    clean = clean.replaceAllMapped(
      RegExp(r'\s+([,.!?])'),
      (match) => match.group(1) ?? '',
    );
    return clean
        .replaceAllMapped(
          RegExp(r'([,.!?])([A-Za-zÁÉÍÓÚÜÑáéíóúüñ])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .replaceAll(RegExp(r'^\s*[,.!?]+\s*'), '')
        .trim();
  }

  static String _extractReply(String rawText) {
    final trimmed = _stripMarkdownFence(rawText.trim());
    if (trimmed.isEmpty) return '';

    if (_looksLikeStructuredPayload(trimmed)) {
      final decoded = _decodeJsonMap(trimmed);
      if (decoded == null) return '';

      final reply = decoded['reply'];
      if (reply is String) return reply.trim();

      for (final value in decoded.values) {
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return '';
    }

    return trimmed;
  }

  static bool _looksLikeStructuredPayload(String text) {
    final trimmed = text.trimLeft();
    return trimmed.startsWith('{') ||
        trimmed.startsWith('[') ||
        trimmed.contains('"reply"') ||
        trimmed.contains("'reply'");
  }

  static bool _looksLikeBrokenStructuredPayload(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) return true;
    if (trimmed.contains('"reply"') || trimmed.contains("'reply'")) return true;
    return false;
  }

  static Map<String, dynamic>? _decodeJsonMap(String text) {
    final candidates = <String>[text];
    final firstBrace = text.indexOf('{');
    final lastBrace = text.lastIndexOf('}');
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      candidates.add(text.substring(firstBrace, lastBrace + 1));
    }

    for (final candidate in candidates) {
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // Try next candidate.
      }
    }
    return null;
  }

  static String _stripMarkdownFence(String text) {
    if (!text.startsWith('```')) return text;

    final withoutOpening = text.replaceFirst(
      RegExp(r'^```(?:json)?\s*', caseSensitive: false),
      '',
    );
    return withoutOpening.replaceFirst(RegExp(r'\s*```$'), '').trim();
  }
}
