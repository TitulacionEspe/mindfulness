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

  static String truncateWords(String value, {required int maxWords}) {
    final words = RegExp(
      r'\S+',
    ).allMatches(value.trim()).map((match) => match.group(0)!).toList();
    if (words.length <= maxWords) return value.trim();
    return '${words.take(maxWords).join(' ')}...';
  }
}
