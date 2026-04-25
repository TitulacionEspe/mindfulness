import 'package:flutter/material.dart';

@immutable
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.surfaceBright,
    required this.textPrimary,
    required this.textSecondary,
    required this.outline,
    required this.outlineVariant,
    required this.lavender,
    required this.mint,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.tertiaryOnContainer,
    required this.buttonPrimary,
    required this.buttonPrimaryText,
    required this.error,
    required this.successBg,
    required this.warningBg,
    required this.tertiaryBg,
    required this.secondaryContainer,
  });

  final Color background;
  final Color surface;
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color surfaceBright;
  final Color textPrimary;
  final Color textSecondary;
  final Color outline;
  final Color outlineVariant;
  final Color lavender;
  final Color mint;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color tertiaryOnContainer;
  final Color buttonPrimary;
  final Color buttonPrimaryText;
  final Color error;
  final Color successBg;
  final Color warningBg;
  final Color tertiaryBg;
  final Color secondaryContainer;
}

class AppColors {
  AppColors._();

  static const AppPalette lightPalette = AppPalette(
    background: Color(0xFFF8F6FA),
    surface: Color(0xFFFFFBFF),
    surfaceLowest: Color(0xFFFFFFFF),
    surfaceLow: Color(0xFFF2EEF5),
    surfaceHigh: Color(0xFFE9E4ED),
    surfaceHighest: Color(0xFFDED8E3),
    surfaceBright: Color(0xFFFFFBFF),
    textPrimary: Color(0xFF211F24),
    textSecondary: Color(0xFF5E5864),
    outline: Color(0xFF746D79),
    outlineVariant: Color(0xFFC9C1CE),
    lavender: Color(0xFF6F5C91),
    mint: Color(0xFF006B63),
    tertiary: Color(0xFF6A5D16),
    tertiaryContainer: Color(0xFFF3E6B0),
    tertiaryOnContainer: Color(0xFF2B2500),
    buttonPrimary: Color(0xFF006B63),
    buttonPrimaryText: Color(0xFFFFFFFF),
    error: Color(0xFFBA1A1A),
    successBg: Color(0x2611736B),
    warningBg: Color(0x266F5C91),
    tertiaryBg: Color(0x266A5D16),
    secondaryContainer: Color(0xFFD4EFEB),
  );

  static const AppPalette darkPalette = AppPalette(
    background: Color(0xFF141315),
    surface: Color(0xFF201F21),
    surfaceLowest: Color(0xFF0F0E10),
    surfaceLow: Color(0xFF1C1B1D),
    surfaceHigh: Color(0xFF2B292C),
    surfaceHighest: Color(0xFF363437),
    surfaceBright: Color(0xFF3A383B),
    textPrimary: Color(0xFFE6E1E4),
    textSecondary: Color(0xFFCAC4CD),
    outline: Color(0xFF948F97),
    outlineVariant: Color(0xFF49454D),
    lavender: Color(0xFFD1C4E9),
    mint: Color(0xFFB2DFDB),
    tertiary: Color(0xFFF3E6B0),
    tertiaryContainer: Color(0xFFD6CA96),
    tertiaryOnContainer: Color(0xFF5D552B),
    buttonPrimary: Color(0xFFB2DFDB),
    buttonPrimaryText: Color(0xFF053734),
    error: Color(0xFFFFB4AB),
    successBg: Color(0x26B2DFDB),
    warningBg: Color(0x26D1C4E9),
    tertiaryBg: Color(0x26D6CA96),
    secondaryContainer: Color(0xFF224E4B),
  );

  static AppPalette _active = lightPalette;

  static AppPalette get active => _active;

  static void useLight() => _active = lightPalette;

  static void useDark() => _active = darkPalette;

  static void useThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      useDark();
    } else {
      useLight();
    }
  }

  static Color get background => _active.background;
  static Color get surface => _active.surface;
  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;
  static Color get lavender => _active.lavender;
  static Color get mint => _active.mint;
  static Color get navBorder => _active.outlineVariant;
  static Color get buttonPrimary => _active.buttonPrimary;
  static Color get buttonPrimaryText => _active.buttonPrimaryText;
  static Color get error => _active.error;
  static Color get surfaceLowest => _active.surfaceLowest;
  static Color get surfaceLow => _active.surfaceLow;
  static Color get surfaceHigh => _active.surfaceHigh;
  static Color get surfaceHighest => _active.surfaceHighest;
  static Color get surfaceBright => _active.surfaceBright;
  static Color get outline => _active.outline;
  static Color get outlineVariant => _active.outlineVariant;
  static Color get tertiary => _active.tertiary;
  static Color get tertiaryContainer => _active.tertiaryContainer;
  static Color get tertiaryOnContainer => _active.tertiaryOnContainer;
  static Color get primaryContainer => _active.lavender;
  static Color get secondaryContainer => _active.secondaryContainer;

  static Color get accent => _active.mint;
  static Color get accentLight => _active.lavender;
  static Color get cardBackground => _active.surface;
  static Color get white => _active.textPrimary;
  static Color get textBlack => _active.buttonPrimaryText;
  static Color get sectionWhite => _active.surface;

  static Color get successBg => _active.successBg;
  static Color get successText => _active.mint;
  static Color get warningBg => _active.warningBg;
  static Color get warningText => _active.lavender;
  static Color get tertiaryBg => _active.tertiaryBg;
  static Color get greyBg => _active.surface;
  static Color get greyLight => _active.textSecondary;

  static Color get figmaBlue => _active.lavender;
  static Color get figmaGrayBg => _active.surface;
  static Color get figmaBlack => _active.textPrimary;
  static Color get figmaMuted => _active.textSecondary;

  static Color get primaryTeal => _active.mint;
  static Color get accentOrange => _active.lavender;
  static Color get darkText => _active.textSecondary;
}
