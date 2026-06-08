import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../services/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({ChatRepository? repository})
    : _repository = repository ?? SupabaseChatRepository();

  final ChatRepository _repository;

  List<ChatMessageModel> _messages = const [];
  List<ChatMessageModel> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSending = false;
  bool get isSending => _isSending;

  bool _suggestAppointment = false;
  bool get suggestAppointment => _suggestAppointment;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasMessages => _messages.isNotEmpty;

  Future<void> loadHistory({bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _repository.listByPatient();
      _suggestAppointment =
          _messages.isNotEmpty &&
          _messages.last.riskLevel == ChatRiskLevel.high;
    } catch (_) {
      _errorMessage = 'No se pudo cargar tu conversación. Intenta nuevamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty || _isSending) return;

    final tempUserMessage = ChatMessageModel(
      id: 'temp_user',
      patientId: '',
      role: ChatRole.user,
      content: normalized,
      createdAt: DateTime.now(),
      riskLevel: ChatRiskLevel.none,
    );

    // Render immediate local message and start loader
    _messages = [..._messages, tempUserMessage];
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final historyForSend = _messages.where((m) => m.id != 'temp_user').toList();
      final result = await _repository.sendMessage(
        text: normalized,
        history: historyForSend,
      );
      _messages = [
        ..._messages.where((m) => m.id != 'temp_user'),
        result.userMessage,
        result.assistantMessage,
      ];
      _suggestAppointment =
          result.suggestAppointment ||
          result.assistantMessage.riskLevel == ChatRiskLevel.high;
    } catch (_) {
      _messages = _messages.where((m) => m.id != 'temp_user').toList();
      _errorMessage =
          'No se pudo enviar tu mensaje. Revisa tu conexión e intenta otra vez.';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void dismissAppointmentSuggestion() {
    _suggestAppointment = false;
    notifyListeners();
  }

  Future<void> clearConversation() async {
    try {
      await _repository.clearHistory();
      _messages = const [];
      _suggestAppointment = false;
    } catch (_) {
      _errorMessage = 'No se pudo borrar la conversación.';
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
