import 'dart:convert';

class AiParser {
  /// Sanea y extrae la respuesta legible de la IA, previniendo que se muestren
  /// llaves, comillas o trazas de JSON en caso de respuestas truncadas o incorrectas.
  static String cleanAiResponse(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return '';

    // Si el texto tiene trazas de estructura JSON (completa o parcial)
    if (trimmed.startsWith('{') || trimmed.contains('"reply"')) {
      // 1. Decodificar directamente si es un JSON completo y válido
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map && decoded.containsKey('reply')) {
          return (decoded['reply'] as String? ?? '').trim();
        }
      } catch (_) {
        // Proceder a extracción alternativa si el JSON está incompleto o corrupto
      }

      // 2. Extraer por Expresión Regular para soportar JSON truncado
      // Busca la clave "reply" y captura su valor de cadena con escapes de comillas
      final regExp = RegExp(r'"reply"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"?');
      final match = regExp.firstMatch(trimmed);
      if (match != null && match.groupCount >= 1) {
        String extracted = match.group(1) ?? '';
        extracted = extracted.replaceAll(r'\"', '"').replaceAll(r'\n', '\n');
        if (extracted.trim().isNotEmpty) {
          return extracted.trim();
        }
      }

      // 3. Extracción de subcadena heurística si la RegExp falla
      final index = trimmed.indexOf('"reply"');
      if (index != -1) {
        final afterReply = trimmed.substring(index + 7);
        final firstQuote = afterReply.indexOf('"');
        if (firstQuote != -1) {
          final content = afterReply.substring(firstQuote + 1);
          final lastQuote = content.lastIndexOf('"');
          String clean = lastQuote != -1
              ? content.substring(0, lastQuote)
              : content;
          clean = clean.replaceAll(r'\"', '"').replaceAll(r'\n', '\n');
          // Quitar caracteres residuales de JSON al final
          clean = clean.replaceAll(RegExp(r'[}"]+$'), '').trim();
          if (clean.isNotEmpty) return clean;
        }
      }
    }

    // 4. Si es una estructura JSON válida pero no tiene la clave 'reply'
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          for (final value in decoded.values) {
            if (value is String && value.trim().isNotEmpty) {
              return value.trim();
            }
          }
        }
      } catch (_) {}
    }

    // 5. Devolución de texto plano si no cumple patrones de JSON
    return trimmed;
  }
}
