import 'package:shared_preferences/shared_preferences.dart';

import '../core/accessibility/accessibility_preferences.dart';

class AccessibilityPreferencesRepository {
  AccessibilityPreferencesRepository({
    Future<SharedPreferences> Function()? preferencesFactory,
  }) : _preferencesFactory =
           preferencesFactory ?? SharedPreferences.getInstance;

  static const String fontScaleKey = 'accessibility_font_scale';
  static const String colorVisionModeKey = 'accessibility_color_vision_mode';

  final Future<SharedPreferences> Function() _preferencesFactory;

  Future<AccessibilityPreferences> loadPreferences() async {
    final preferences = await _preferencesFactory();
    final storedFontScale = preferences.getDouble(fontScaleKey);
    final storedColorVisionMode = preferences.getString(colorVisionModeKey);

    return AccessibilityPreferences(
      fontScale: storedFontScale == null
          ? AccessibilityPreferences.defaultFontScale
          : AccessibilityPreferences.normalizeFontScale(storedFontScale),
      colorVisionMode: ColorVisionMode.fromStorageValue(storedColorVisionMode),
    );
  }

  Future<void> savePreferences(AccessibilityPreferences preferences) async {
    final localPreferences = await _preferencesFactory();
    await localPreferences.setDouble(
      fontScaleKey,
      AccessibilityPreferences.normalizeFontScale(preferences.fontScale),
    );
    await localPreferences.setString(
      colorVisionModeKey,
      preferences.colorVisionMode.storageValue,
    );
  }

  Future<void> saveFontScale(double fontScale) async {
    final localPreferences = await _preferencesFactory();
    await localPreferences.setDouble(
      fontScaleKey,
      AccessibilityPreferences.normalizeFontScale(fontScale),
    );
  }

  Future<void> saveColorVisionMode(ColorVisionMode mode) async {
    final localPreferences = await _preferencesFactory();
    await localPreferences.setString(colorVisionModeKey, mode.storageValue);
  }
}
