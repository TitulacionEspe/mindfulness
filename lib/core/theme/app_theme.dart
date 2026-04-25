import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static Color get primaryTeal => AppColors.mint;
  static Color get white => AppColors.textPrimary;
  static Color get accentOrange => AppColors.lavender;
  static Color get accentGreen => AppColors.mint;
  static Color get darkText => AppColors.textSecondary;

  static ThemeData get lightTheme => _buildTheme(
    palette: AppColors.lightPalette,
    brightness: Brightness.light,
  );

  static ThemeData get darkTheme =>
      _buildTheme(palette: AppColors.darkPalette, brightness: Brightness.dark);

  static ThemeData _buildTheme({
    required AppPalette palette,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.mint,
      brightness: brightness,
      primary: palette.mint,
      onPrimary: palette.buttonPrimaryText,
      secondary: palette.lavender,
      tertiary: palette.tertiary,
      error: palette.error,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      outline: palette.outline,
      outlineVariant: palette.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.mint,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      textTheme: _textTheme(palette),
      appBarTheme: AppBarThemeData(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.3,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        contentTextStyle: TextStyle(
          color: palette.textSecondary,
          fontSize: 16,
          height: 1.5,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceHighest,
        contentTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: palette.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: palette.textSecondary, size: 24),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.mint),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: palette.textSecondary, fontSize: 16),
        hintStyle: TextStyle(color: palette.textSecondary, fontSize: 16),
        prefixIconColor: palette.mint,
        suffixIconColor: palette.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.mint, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.buttonPrimary,
          foregroundColor: palette.buttonPrimaryText,
          disabledBackgroundColor: palette.surfaceHighest,
          disabledForegroundColor: palette.textSecondary,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.lavender,
          side: BorderSide(color: palette.lavender),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.mint,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.mint;
          return palette.surfaceHighest;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.successBg;
          return palette.surfaceHigh;
        }),
        trackOutlineColor: WidgetStateProperty.all(palette.outlineVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceLow,
        selectedColor: palette.successBg,
        disabledColor: palette.surfaceHigh,
        labelStyle: TextStyle(color: palette.textPrimary, fontSize: 14),
        secondaryLabelStyle: TextStyle(
          color: palette.buttonPrimaryText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: palette.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.background,
        selectedItemColor: palette.mint,
        unselectedItemColor: palette.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: palette.surface,
        hourMinuteColor: palette.surfaceHigh,
        hourMinuteTextColor: palette.textPrimary,
        dayPeriodColor: palette.surfaceHigh,
        dayPeriodTextColor: palette.textPrimary,
        dialBackgroundColor: palette.surfaceLow,
        dialHandColor: palette.mint,
        dialTextColor: palette.textPrimary,
        entryModeIconColor: palette.mint,
        helpTextStyle: TextStyle(color: palette.textSecondary),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(48, 48)),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.buttonPrimaryText;
            }
            return palette.textSecondary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.buttonPrimary;
            }
            return palette.surfaceLow;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: palette.outlineVariant),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(AppPalette palette) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.2,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.25,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.3,
        fontFamily: 'Inter',
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
        height: 1.4,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
        height: 1.5,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: palette.textSecondary,
        height: 1.45,
        fontFamily: 'Inter',
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.buttonPrimaryText,
        fontFamily: 'Inter',
      ),
    );
  }
}
