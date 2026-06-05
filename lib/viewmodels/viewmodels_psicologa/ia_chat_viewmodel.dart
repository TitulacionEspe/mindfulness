import 'package:flutter/material.dart';
import '../../services/services_psicologa/ia_chat_service.dart';

class IAChatViewModel extends ChangeNotifier {
  final IAChatService _chatService = IAChatService();

  /// Historial completo (para el drawer)
  List<ProfessionalIAChatMessage> _historyMessages = [];
  List<ProfessionalIAChatMessage> get historyMessages => _historyMessages;

  /// Mensajes de la sesión actual (para el chat)
  List<ProfessionalIAChatMessage> _chatMessages = [];
  List<ProfessionalIAChatMessage> get chatMessages => _chatMessages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _professionalId;

  /// Inicializa: carga el historial para el drawer, chat empieza vacío
  Future<void> init(String professionalId) async {
    if (_professionalId == professionalId) return;

    _professionalId = professionalId;
    _isLoading = true;
    notifyListeners();

    _historyMessages = await _chatService.getChatHistory(professionalId);
    _chatMessages = []; // Chat siempre empieza vacío

    _isLoading = false;
    notifyListeners();
  }

  /// Envía un mensaje y obtiene respuesta de la IA
  Future<void> sendMessage(String text) async {
    if (_professionalId == null || text.trim().isEmpty) return;

    final userMessage = ProfessionalIAChatMessage(
      professionalId: _professionalId!,
      role: 'user',
      content: text,
    );

    // Añadir a la sesión actual y guardar en DB
    _chatMessages.add(userMessage);
    notifyListeners();
    await _chatService.saveMessage(userMessage);

    // Cargar respuesta de la IA (usa solo el contexto de la sesión actual)
    _isLoading = true;
    notifyListeners();

    final aiResponseText =
        await _chatService.getAIResponse(text, _chatMessages);

    final aiMessage = ProfessionalIAChatMessage(
      professionalId: _professionalId!,
      role: 'assistant',
      content: aiResponseText,
    );

    _chatMessages.add(aiMessage);
    _isLoading = false;
    notifyListeners();
    await _chatService.saveMessage(aiMessage);

    // Refrescar historial para el drawer
    _historyMessages = await _chatService.getChatHistory(_professionalId!);
    notifyListeners();
  }

  /// Limpia la sesión actual (chat vuelve a vacío, historial intacto)
  void clearCurrentChat() {
    _chatMessages.clear();
    notifyListeners();
  }

  /// Elimina mensajes del historial por sus IDs
  Future<void> deleteHistoryMessages(List<String> ids) async {
    if (ids.isEmpty) return;

    await _chatService.deleteMessages(ids);
    _historyMessages.removeWhere((m) => ids.contains(m.id));
    _chatMessages.removeWhere((m) => ids.contains(m.id));
    notifyListeners();
  }

  /// Elimina todo el historial del profesional
  Future<void> deleteAllHistory() async {
    if (_professionalId == null) return;

    await _chatService.deleteAllMessages(_professionalId!);
    _historyMessages.clear();
    _chatMessages.clear();
    notifyListeners();
  }
}
