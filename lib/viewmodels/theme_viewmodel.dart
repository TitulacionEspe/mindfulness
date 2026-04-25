import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/theme_preferences_repository.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({ThemePreferencesRepository? repository})
    : _repository = repository ?? ThemePreferencesRepository() {
    AppColors.useLight();
  }

  final ThemePreferencesRepository _repository;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _themeMode = await _repository.loadThemeMode();
      AppColors.useThemeMode(_themeMode);
    } catch (_) {
      _themeMode = ThemeMode.light;
      AppColors.useLight();
      _errorMessage = 'No se pudo cargar la preferencia de tema.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode && !_isLoading) return;

    final previousMode = _themeMode;
    _themeMode = mode;
    _isLoading = true;
    _errorMessage = null;
    AppColors.useThemeMode(_themeMode);
    notifyListeners();

    try {
      await _repository.saveThemeMode(mode);
    } catch (_) {
      _themeMode = previousMode;
      AppColors.useThemeMode(_themeMode);
      _errorMessage = 'No se pudo guardar la preferencia de tema.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(bool useDarkMode) {
    return setThemeMode(useDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
}
