import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/ai_parser.dart';
import '../models/thought_entry_model.dart';
import '../services/thought_entries_repository.dart';

class ThoughtEntriesViewModel extends ChangeNotifier {
  ThoughtEntriesViewModel({ThoughtEntriesRepository? repository})
    : _repository = repository ?? SupabaseThoughtEntriesRepository();

  static const Duration editableWindow = Duration(hours: 24);

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
          'No se pudo cargar tu historial de pensamientos. Intenta nuevamente.';
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
              'Analiza el siguiente pensamiento registrado por un estudiante en su diario de descarga emocional: "$normalized". Por favor, responde en español siguiendo estas reglas: \n1. Si el pensamiento es predominantemente positivo, responde con un mensaje alegre, optimista y motivador. \n2. Si el pensamiento es intermedio, neutral o describe un día común con estrés normal, da una respuesta empática y equilibrada. \n3. Si el pensamiento es muy negativo, triste, de alta tensión o sugiere riesgo emocional, bríndale una retrospectiva de por qué puede sentirse así, recuérdale con mucha empatía que no está solo, y recomiéndale de forma cálida solicitar una cita con un profesional de psicología en la aplicación.',
          'history': [],
        },
      );

      final data = response.data;
      if (data is Map) {
        final rawReply = (data['reply'] as String?)?.trim() ?? '';
        _aiRetrospect = AiParser.cleanAiResponse(rawReply);
        final riskLevel = data['riskLevel'] as String?;
        final suggestApp = data['suggestAppointment'] == true;
        _aiSuggestsAppointment = suggestApp || riskLevel == 'high';
      } else if (data is String) {
        _aiRetrospect = AiParser.cleanAiResponse(data);
      } else {
        _aiRetrospect =
            'Interesante reflexión. Recuerda que siempre tienes la opción de tomar un momento para respirar y cuidar de ti.';
      }
    } catch (e) {
      _aiRetrospect =
          'He guardado tu pensamiento con éxito. El asistente de Nidara no pudo generar una retrospectiva en este momento por un problema de conexión, pero recuerda que estás haciendo un esfuerzo valioso por cuidar de ti.';
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
    if (normalized.isEmpty) {
      _errorMessage = 'Escribe un pensamiento antes de guardar.';
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
        _successMessage = 'Pensamiento guardado.';
      } else {
        _entries = ThoughtEntryModel.sortNewestFirst(
          _entries
              .map((entry) => entry.id == updated.id ? updated : entry)
              .toList(),
        );
        _successMessage = 'Entrada actualizada.';
      }
      return true;
    } catch (_) {
      _errorMessage = existingEntry == null
          ? 'No se pudo guardar el pensamiento.'
          : 'No se pudo actualizar la entrada.';
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
