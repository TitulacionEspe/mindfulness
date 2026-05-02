import 'package:flutter/material.dart';

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
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
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
    notifyListeners();
  }
}
