class ThoughtEntryModel {
  const ThoughtEntryModel({
    required this.id,
    required this.patientId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  ThoughtEntryModel copyWith({String? content, DateTime? updatedAt}) {
    return ThoughtEntryModel(
      id: id,
      patientId: patientId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ThoughtEntryModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '');
    final updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

    return ThoughtEntryModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      content: json['content_ciphertext'] as String? ?? '',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? createdAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson({
    required String patientId,
    required String content,
  }) {
    return {'patient_id': patientId, 'content_ciphertext': content.trim()};
  }

  static List<ThoughtEntryModel> sortNewestFirst(
    List<ThoughtEntryModel> items,
  ) {
    final copied = List<ThoughtEntryModel>.from(items);
    copied.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copied;
  }
}
