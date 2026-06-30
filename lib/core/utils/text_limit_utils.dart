class TextLimitUtils {
  const TextLimitUtils._();

  static int wordCount(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 0;
    return RegExp(r'\S+').allMatches(normalized).length;
  }

  static bool isWithinWordLimit(String value, {required int maxWords}) {
    return wordCount(value) <= maxWords;
  }

  static int characterCount(String value) => value.runes.length;

  static bool isWithinCharacterLimit(
    String value, {
    required int maxCharacters,
  }) {
    return characterCount(value) <= maxCharacters;
  }

  static String? maxWordsError(
    String value, {
    required int maxWords,
    required String fieldName,
  }) {
    final count = wordCount(value);
    if (count <= maxWords) return null;
    return '$fieldName permite máximo $maxWords palabras. Actualmente tiene $count.';
  }

  static String? requiredMaxWordsError(
    String value, {
    required int maxWords,
    required String emptyMessage,
    required String fieldName,
  }) {
    if (value.trim().isEmpty) return emptyMessage;
    return maxWordsError(value, maxWords: maxWords, fieldName: fieldName);
  }

  static String? maxCharactersError(
    String value, {
    required int maxCharacters,
    required String fieldName,
  }) {
    final count = characterCount(value);
    if (count <= maxCharacters) return null;
    return '$fieldName permite máximo $maxCharacters caracteres. Actualmente tiene $count.';
  }

  static String? requiredMaxCharactersError(
    String value, {
    required int maxCharacters,
    required String emptyMessage,
    required String fieldName,
  }) {
    if (value.trim().isEmpty) return emptyMessage;
    return maxCharactersError(
      value,
      maxCharacters: maxCharacters,
      fieldName: fieldName,
    );
  }

  static String truncateWords(String value, {required int maxWords}) {
    final words = RegExp(
      r'\S+',
    ).allMatches(value.trim()).map((match) => match.group(0)!).toList();
    if (words.length <= maxWords) return value.trim();
    return '${words.take(maxWords).join(' ')}...';
  }
}
