import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/ai_parser.dart';
import '../core/utils/text_limit_utils.dart';
import '../models/thought_entry_model.dart';
import '../services/thought_entries_repository.dart';

class ThoughtEntriesViewModel extends ChangeNotifier {
  ThoughtEntriesViewModel({ThoughtEntriesRepository? repository})
    : _repository = repository ?? SupabaseThoughtEntriesRepository();

  static const Duration editableWindow = Duration(hours: 24);
  static const int maxThoughtWords = 30;

  final ThoughtEntriesRepository _repository;

  List<ThoughtEntryModel> _entries = const [];
  List<ThoughtEntryModel> get entries => _entries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  String? _aiRetrospect;
  String? get aiRetrospect => _aiRetrospect;

  bool _aiSuggestsAppointment = false;
  bool get aiSuggestsAppointment => _aiSuggestsAppointment;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<void> loadEntries({bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = ThoughtEntryModel.sortNewestFirst(
        await _repository.listByPatient(),
      );
    } catch (_) {
      _errorMessage =
          'No se pudo cargar tu historial de notas privadas. Intenta nuevamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _entries = const [];
    _isLoading = false;
    _isSaving = false;
    _isAnalyzing = false;
    _aiRetrospect = null;
    _aiSuggestsAppointment = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> generateAIRetrospect(String thoughtContent) async {
    final normalized = thoughtContent.trim();
    if (normalized.isEmpty) return;

    _isAnalyzing = true;
    _aiRetrospect = null;
    _aiSuggestsAppointment = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'emotional-chat',
        body: {
          'message':
              'Analiza esta nota privada de un estudiante en Nidara: "$normalized". Responde en español con máximo 30 palabras. No diagnostiques. Recomienda una actividad concreta según el contexto: respiración, relajación, descanso, progreso o cita con personal de Psicología.',
          'history': [],
        },
      );

      final data = response.data;
      if (data is Map) {
        final payload = Map<String, dynamic>.from(data);
        final rawReply = (data['reply'] as String?)?.trim() ?? '';
        final safeReply = AiParser.isUnavailablePayload(payload)
            ? AiParser.assistantUnavailableReply
            : AiParser.cleanAssistantReply(
                rawReply,
                fallback: AiParser.assistantUnavailableReply,
              );
        _aiRetrospect = TextLimitUtils.truncateWords(
          safeReply,
          maxWords: maxThoughtWords,
        );
        final riskLevel = payload['riskLevel'] as String?;
        final suggestApp = payload['suggestAppointment'] == true;
        _aiSuggestsAppointment = suggestApp || riskLevel == 'high';
      } else if (data is String) {
        _aiRetrospect = TextLimitUtils.truncateWords(
          AiParser.cleanAssistantReply(
            data,
            fallback: AiParser.assistantUnavailableReply,
          ),
          maxWords: maxThoughtWords,
        );
      } else {
        _aiRetrospect = AiParser.assistantUnavailableReply;
      }
    } catch (e) {
      _aiRetrospect = AiParser.assistantUnavailableReply;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  bool canEditOrDelete(ThoughtEntryModel entry, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return reference.difference(entry.createdAt) <= editableWindow;
  }

  Future<bool> saveEntry({
    required String content,
    ThoughtEntryModel? existingEntry,
  }) async {
    final normalized = content.trim();
    final validationError = TextLimitUtils.requiredMaxWordsError(
      normalized,
      maxWords: maxThoughtWords,
      emptyMessage: 'Escribe una nota privada antes de guardar.',
      fieldName: 'La nota privada',
    );
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    if (existingEntry != null && !canEditOrDelete(existingEntry)) {
      _errorMessage =
          'Solo puedes editar entradas dentro de las primeras 24 horas.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = existingEntry == null
          ? await _repository.create(content: normalized)
          : await _repository.update(id: existingEntry.id, content: normalized);

      if (existingEntry == null) {
        _entries = ThoughtEntryModel.sortNewestFirst([..._entries, updated]);
        _successMessage = 'Nota privada guardada.';
      } else {
        _entries = ThoughtEntryModel.sortNewestFirst(
          _entries
              .map((entry) => entry.id == updated.id ? updated : entry)
              .toList(),
        );
        _successMessage = 'Nota privada actualizada.';
      }
      return true;
    } catch (_) {
      _errorMessage = existingEntry == null
          ? 'No se pudo guardar la nota privada. Intenta nuevamente.'
          : 'No se pudo actualizar la nota privada. Intenta nuevamente.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEntry(ThoughtEntryModel entry) async {
    if (!canEditOrDelete(entry)) {
      _errorMessage =
          'Solo puedes eliminar entradas dentro de las primeras 24 horas.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.delete(id: entry.id);
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _successMessage = 'Entrada eliminada.';
      return true;
    } catch (_) {
      _errorMessage = 'No se pudo eliminar la entrada.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _aiRetrospect = null;
    _aiSuggestsAppointment = false;
    notifyListeners();
  }
}
