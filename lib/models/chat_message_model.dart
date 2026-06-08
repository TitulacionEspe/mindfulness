enum ChatRole { user, assistant }

enum ChatRiskLevel { none, low, high }

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.patientId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.riskLevel = ChatRiskLevel.none,
  });

  final String id;
  final String patientId;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final ChatRiskLevel riskLevel;

  bool get isUser => role == ChatRole.user;

  static ChatRole roleFromString(String? value) =>
      value == 'assistant' ? ChatRole.assistant : ChatRole.user;

  static String roleToString(ChatRole role) =>
      role == ChatRole.assistant ? 'assistant' : 'user';

  static ChatRiskLevel riskFromString(String? value) {
    switch (value) {
      case 'high':
        return ChatRiskLevel.high;
      case 'low':
        return ChatRiskLevel.low;
      default:
        return ChatRiskLevel.none;
    }
  }

  static String riskToString(ChatRiskLevel level) {
    switch (level) {
      case ChatRiskLevel.high:
        return 'high';
      case ChatRiskLevel.low:
        return 'low';
      case ChatRiskLevel.none:
        return 'none';
    }
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '');

    return ChatMessageModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      role: roleFromString(json['role'] as String?),
      content: json['content'] as String? ?? '',
      createdAt: createdAt ?? DateTime.now(),
      riskLevel: riskFromString(json['risk_level'] as String?),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'patient_id': patientId,
      'role': roleToString(role),
      'content': content.trim(),
      'risk_level': riskToString(riskLevel),
    };
  }
}
