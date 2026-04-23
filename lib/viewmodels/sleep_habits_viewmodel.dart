import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SleepHabitsViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay get bedtime => _bedtime;

  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay get wakeTime => _wakeTime;

  // Máscara de bits para los días (1=Lun, 2=Mar, 4=Mie, 8=Jue, 16=Vie, 32=Sab, 64=Dom)
  int _academicLoadDays = 0;
  int get academicLoadDays => _academicLoadDays;

  bool _darkModeEnforced = true;
  bool get darkModeEnforced => _darkModeEnforced;

  void setBedtime(TimeOfDay time) {
    _bedtime = time;
    notifyListeners();
  }

  void setWakeTime(TimeOfDay time) {
    _wakeTime = time;
    notifyListeners();
  }

  void toggleAcademicDay(int bitValue) {
    if ((_academicLoadDays & bitValue) != 0) {
      _academicLoadDays &= ~bitValue; // Quitar día
    } else {
      _academicLoadDays |= bitValue; // Añadir día
    }
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkModeEnforced = value;
    notifyListeners();
  }

  /// Carga la configuración actual del usuario desde Supabase
  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('patient_settings')
          .select()
          .eq('patient_id', user.id)
          .maybeSingle();

      if (response != null) {
        _hasCompletedOnboarding = true;
        // Parsear horarios
        final bedStr = response['habitual_bedtime'] as String?;
        if (bedStr != null) {
          final parts = bedStr.split(':');
          _bedtime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        final wakeStr = response['habitual_wake_time'] as String?;
        if (wakeStr != null) {
          final parts = wakeStr.split(':');
          _wakeTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        _academicLoadDays = response['academic_load_days'] ?? 0;
        _darkModeEnforced = response['dark_mode_enforced'] ?? true;
      } else {
        _hasCompletedOnboarding = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guarda la configuración en Supabase
  Future<bool> saveSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final bedStr =
          '${_bedtime.hour.toString().padLeft(2, '0')}:${_bedtime.minute.toString().padLeft(2, '0')}:00';
      final wakeStr =
          '${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}:00';

      await _supabase.from('patient_settings').upsert({
        'patient_id': user.id,
        'habitual_bedtime': bedStr,
        'habitual_wake_time': wakeStr,
        'academic_load_days': _academicLoadDays,
        'dark_mode_enforced': _darkModeEnforced,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _hasCompletedOnboarding = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
