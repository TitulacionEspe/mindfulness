import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/utils/text_limit_utils.dart';

void main() {
  group('TextLimitUtils', () {
    test('counts words separated by any whitespace', () {
      expect(TextLimitUtils.wordCount(' respirar  con calma\nhoy '), 4);
    });

    test('returns a clear max word error', () {
      final text = List.filled(31, 'calma').join(' ');

      expect(
        TextLimitUtils.maxWordsError(
          text,
          maxWords: 30,
          fieldName: 'La nota privada',
        ),
        'La nota privada permite máximo 30 palabras. Actualmente tiene 31.',
      );
    });

    test('truncates long text to the requested word limit', () {
      final text = List.filled(35, 'respira').join(' ');

      final truncated = TextLimitUtils.truncateWords(text, maxWords: 30);

      expect(TextLimitUtils.wordCount(truncated), 30);
      expect(truncated.endsWith('...'), isTrue);
    });

    test('returns a clear max character error', () {
      final text = List.filled(101, 'a').join();

      expect(
        TextLimitUtils.maxCharactersError(
          text,
          maxCharacters: 100,
          fieldName: 'La nota privada',
        ),
        'La nota privada permite máximo 100 caracteres. Actualmente tiene 101.',
      );
    });
  });
}
