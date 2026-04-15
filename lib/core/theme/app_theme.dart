import 'package:flutter/material.dart';

/// Global app theme with colors extracted from mockups.
/// Tone: Minimalist, zen, professional healthcare. Teal + white with minimal accent colors.
class AppTheme {
  // Primary brand colors from mockups
  static const Color primaryTeal = Color(0xFF1A4D5C); // Deep teal background
  static const Color primaryTealLight = Color(0xFF2A6B7D); // Lighter teal
  static const Color accentOrange = Color(
    0xFFE67E22,
  ); // Orange for activity/emphasis
  static const Color accentGreen = Color(
    0xFF27AE60,
  ); // Green for positive states

  // Neutral tones
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2C2C2C); // Near-black for text
  static const Color lightGray = Color(0xFFF5F5F5); // Light background
  static const Color borderGray = Color(0xFFE0E0E0);

  /// Light theme (primary, used in dark interface areas).
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryTeal,
      secondary: accentOrange,
      error: Color(0xFFE74C3C),
      surface: white,
      onPrimary: white,
      onSecondary: white,
    ),
    scaffoldBackgroundColor: primaryTeal,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryTeal,
      foregroundColor: white,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
      labelStyle: TextStyle(color: darkText, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkText,
        foregroundColor: white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: darkText,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        color: darkText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: darkText,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF757575),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
