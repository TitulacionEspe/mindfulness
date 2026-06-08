import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder_model.dart';
import '../services/notification_service.dart';

class RemindersViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NotificationPermissionState? _permissionState;
  NotificationPermissionState? get permissionState => _permissionState;

  Future<void> ensureNotificationPermissions() async {
    try {
      _permissionState = await _notificationService.requestPermissions();
    } catch (_) {
      // Keep UI flow uninterrupted if the OS rejects a permission call.
      _permissionState = const NotificationPermissionState(
        notificationsGranted: false,
        exactAlarmsGranted: false,
      );
    } finally {
      notifyListeners();
    }
  }

  /// Carga los recordatorios desde Supabase
  Future<void> loadReminders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('reminders')
          .select()
          .eq('patient_id', user.id)
          .order('trigger_time', ascending: true);

      _reminders = (response as List)
          .map((json) => ReminderModel.fromJson(json))
          .toList();

      await _syncLocalNotifications();
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _reminders = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Agrega un nuevo recordatorio
  Future<bool> addReminder(ReminderModel reminder) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('reminders')
          .insert(reminder.toJson())
          .select()
          .single();

      final newReminder = ReminderModel.fromJson(response);
      _reminders.add(newReminder);

      if (newReminder.isActive) {
        await _notificationService.scheduleReminder(newReminder);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza un recordatorio existente
  Future<bool> updateReminder(ReminderModel reminder) async {
    if (reminder.id == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase
          .from('reminders')
          .update(reminder.toJson())
          .eq('id', reminder.id!);

      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
      }

      if (reminder.isActive) {
        await _notificationService.scheduleReminder(reminder);
      } else if (reminder.notificationBaseId != null) {
        await _notificationService.cancelReminder(reminder.notificationBaseId!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Elimina un recordatorio
  Future<bool> deleteReminder(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.from('reminders').delete().eq('id', id);

      _reminders.removeWhere((r) => r.id == id);
      await _notificationService.cancelReminder(id.hashCode & 0x7fffffff);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna el estado activo de un recordatorio
  Future<void> toggleReminder(ReminderModel reminder) async {
    final updated = reminder.copyWith(isActive: !reminder.isActive);
    await updateReminder(updated);
  }

  Future<void> _syncLocalNotifications() async {
    for (final reminder in _reminders) {
      if (reminder.isActive) {
        await _notificationService.scheduleReminder(reminder);
      } else if (reminder.notificationBaseId != null) {
        await _notificationService.cancelReminder(reminder.notificationBaseId!);
      }
    }
  }

  String _friendlyError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('auth') || raw.contains('autenticado')) {
      return 'Tu sesión no está activa. Inicia sesión nuevamente.';
    }
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('fetch') ||
        raw.contains('connection')) {
      return 'No se pudo conectar. Revisa tu internet e intenta nuevamente.';
    }
    return 'No se pudo guardar el recordatorio. Revisa los datos e intenta nuevamente.';
  }
}
