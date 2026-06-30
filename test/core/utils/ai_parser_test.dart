import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/utils/ai_parser.dart';

void main() {
  group('AiParser', () {
    test('extracts a valid JSON reply', () {
      final reply = AiParser.cleanAssistantReply(
        '{"reply":"Te leo con calma. Probemos una respiración breve.","riskLevel":"none","suggestAppointment":false}',
      );

      expect(reply, 'Te leo con calma. Probemos una respiración breve.');
    });

    test('rejects truncated JSON instead of showing raw braces', () {
      final reply = AiParser.cleanAssistantReply(
        '{ "reply": "',
        fallback: AiParser.assistantUnavailableReply,
      );

      expect(reply, AiParser.assistantUnavailableReply);
    });

    test('rejects incomplete one-word fragments', () {
      final reply = AiParser.cleanAssistantReply(
        'Mi',
        fallback: AiParser.assistantUnavailableReply,
      );

      expect(reply, AiParser.assistantUnavailableReply);
    });

    test('removes romantic or possessive treatment', () {
      final reply = AiParser.cleanAssistantReply(
        'Hola de nuevo, mi corazón. Aquí estoy para escucharte.',
      );

      expect(reply, 'Hola de nuevo. Aquí estoy para escucharte.');
      expect(reply.toLowerCase(), isNot(contains('mi corazón')));
    });

    test('detects unavailable payloads from the Edge Function', () {
      expect(AiParser.isUnavailablePayload({'available': false}), isTrue);
      expect(AiParser.isUnavailablePayload({'error': 'quota'}), isTrue);
      expect(AiParser.isUnavailablePayload({'reply': 'hola'}), isFalse);
    });
  });
}
