import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/accessibility/accessibility_preferences.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';

void main() {
  group('App visual accessibility mode', () {
    tearDown(AppColors.useLight);

    test('uses normal light and dark palettes by default', () {
      AppColors.useVisualMode(ThemeMode.light, ColorVisionMode.normal);
      expect(AppColors.buttonPrimary, AppColors.lightPalette.buttonPrimary);

      AppColors.useVisualMode(ThemeMode.dark, ColorVisionMode.normal);
      expect(AppColors.buttonPrimary, AppColors.darkPalette.buttonPrimary);
    });

    test('uses color-blind palettes for light and dark modes', () {
      AppColors.useVisualMode(ThemeMode.light, ColorVisionMode.redGreenSupport);
      expect(
        AppColors.buttonPrimary,
        AppColors.colorBlindLightPalette.buttonPrimary,
      );

      AppColors.useVisualMode(ThemeMode.dark, ColorVisionMode.redGreenSupport);
      expect(
        AppColors.buttonPrimary,
        AppColors.colorBlindDarkPalette.buttonPrimary,
      );
    });

    test('returns theme variants according to color vision mode', () {
      expect(
        AppTheme.lightThemeFor(ColorVisionMode.normal).colorScheme.primary,
        AppColors.lightPalette.buttonPrimary,
      );
      expect(
        AppTheme.lightThemeFor(
          ColorVisionMode.redGreenSupport,
        ).colorScheme.primary,
        AppColors.colorBlindLightPalette.buttonPrimary,
      );
      expect(
        AppTheme.darkThemeFor(ColorVisionMode.normal).colorScheme.primary,
        AppColors.darkPalette.buttonPrimary,
      );
      expect(
        AppTheme.darkThemeFor(
          ColorVisionMode.redGreenSupport,
        ).colorScheme.primary,
        AppColors.colorBlindDarkPalette.buttonPrimary,
      );
    });
  });
}
