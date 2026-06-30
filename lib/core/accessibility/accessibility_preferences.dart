enum ColorVisionMode {
  normal,
  redGreenSupport;

  static ColorVisionMode fromStorageValue(String? value) {
    return switch (value) {
      'red_green_support' => ColorVisionMode.redGreenSupport,
      _ => ColorVisionMode.normal,
    };
  }

  String get storageValue {
    return switch (this) {
      ColorVisionMode.normal => 'normal',
      ColorVisionMode.redGreenSupport => 'red_green_support',
    };
  }

  String get label {
    return switch (this) {
      ColorVisionMode.normal => 'Normal',
      ColorVisionMode.redGreenSupport => 'Modo daltonismo',
    };
  }
}

class AccessibilityPreferences {
  const AccessibilityPreferences({
    this.fontScale = defaultFontScale,
    this.colorVisionMode = ColorVisionMode.normal,
  });

  static const double minFontScale = 0.90;
  static const double maxFontScale = 1.30;
  static const double defaultFontScale = 1.00;
  static const List<double> allowedFontScales = [0.90, 1.00, 1.10, 1.20, 1.30];

  final double fontScale;
  final ColorVisionMode colorVisionMode;

  bool get isColorBlindModeEnabled =>
      colorVisionMode == ColorVisionMode.redGreenSupport;

  AccessibilityPreferences copyWith({
    double? fontScale,
    ColorVisionMode? colorVisionMode,
  }) {
    return AccessibilityPreferences(
      fontScale: fontScale ?? this.fontScale,
      colorVisionMode: colorVisionMode ?? this.colorVisionMode,
    );
  }

  static bool isAllowedFontScale(double value) {
    return allowedFontScales.any((scale) => (scale - value).abs() < 0.001);
  }

  static double normalizeFontScale(double value) {
    if (isAllowedFontScale(value)) return value;
    return defaultFontScale;
  }

  static double snapFontScale(double value) {
    return allowedFontScales.reduce((current, next) {
      final currentDistance = (current - value).abs();
      final nextDistance = (next - value).abs();
      return nextDistance < currentDistance ? next : current;
    });
  }

  static String labelForFontScale(double value) {
    final normalized = snapFontScale(value);
    if (normalized == 0.90) return 'Pequeño';
    if (normalized == 1.00) return 'Normal';
    if (normalized == 1.10) return 'Grande';
    if (normalized == 1.20) return 'Muy grande';
    return 'Máximo';
  }
}
