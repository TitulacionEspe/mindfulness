import 'package:flutter/material.dart';

import '../core/accessibility/accessibility_preferences.dart';
import '../services/accessibility_preferences_repository.dart';

class AccessibilityViewModel extends ChangeNotifier {
  AccessibilityViewModel({AccessibilityPreferencesRepository? repository})
    : _repository = repository ?? AccessibilityPreferencesRepository();

  final AccessibilityPreferencesRepository _repository;

  AccessibilityPreferences _preferences = const AccessibilityPreferences();
  AccessibilityPreferences get preferences => _preferences;

  double get fontScale => _preferences.fontScale;
  ColorVisionMode get colorVisionMode => _preferences.colorVisionMode;
  bool get isColorBlindModeEnabled => _preferences.isColorBlindModeEnabled;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String get fontScaleLabel =>
      AccessibilityPreferences.labelForFontScale(fontScale);

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await _repository.loadPreferences();
    } catch (_) {
      _preferences = const AccessibilityPreferences();
      _errorMessage = 'No se pudo cargar la configuración de accesibilidad.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFontScale(double value) async {
    final snappedValue = AccessibilityPreferences.snapFontScale(value);
    if ((snappedValue - fontScale).abs() < 0.001 && !_isLoading) return;

    final previousPreferences = _preferences;
    _preferences = _preferences.copyWith(fontScale: snappedValue);
    _isLoading = true;
    _errorMessage = null;
    _successMessage = 'Preferencia de accesibilidad actualizada.';
    notifyListeners();

    try {
      await _repository.saveFontScale(snappedValue);
    } catch (_) {
      _preferences = previousPreferences;
      _errorMessage = 'No se pudo guardar el tamaño del texto.';
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setColorVisionMode(ColorVisionMode mode) async {
    if (mode == colorVisionMode && !_isLoading) return;

    final previousPreferences = _preferences;
    _preferences = _preferences.copyWith(colorVisionMode: mode);
    _isLoading = true;
    _errorMessage = null;
    _successMessage = 'Preferencia de accesibilidad actualizada.';
    notifyListeners();

    try {
      await _repository.saveColorVisionMode(mode);
    } catch (_) {
      _preferences = previousPreferences;
      _errorMessage = 'No se pudo guardar el modo de color.';
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleColorBlindMode(bool enabled) {
    return setColorVisionMode(
      enabled ? ColorVisionMode.redGreenSupport : ColorVisionMode.normal,
    );
  }

  double effectiveTextScale(double systemTextScale) {
    return (systemTextScale * fontScale)
        .clamp(
          AccessibilityPreferences.minFontScale,
          AccessibilityPreferences.maxFontScale,
        )
        .toDouble();
  }
}
