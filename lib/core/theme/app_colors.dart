import 'package:flutter/material.dart';

class AppColors {
  // --- NUEVO SISTEMA: Nocturne Minimalist ---
  static const Color background = Color(0xFF141315);
  static const Color surface = Color(0xFF201F21);
  static const Color textPrimary = Color(0xFFE6E1E4);
  static const Color textSecondary = Color(0xFFCAC4CD);
  static const Color lavender = Color(0xFFD1C4E9);
  static const Color mint = Color(0xFFB2DFDB);
  static const Color navBorder = Color(0xFF49454D);
  static const Color buttonPrimary = Color(0xFFB2DFDB);
  static const Color buttonPrimaryText = Color(0xFF053734);
  static const Color error = Color(0xFFFFB4AB);

  // --- Tonal layering (Nocturne tokens) ---
  static const Color surfaceLowest = Color(0xFF0F0E10);
  static const Color surfaceLow = Color(0xFF1C1B1D);
  static const Color surfaceHigh = Color(0xFF2B292C);
  static const Color surfaceHighest = Color(0xFF363437);
  static const Color surfaceBright = Color(0xFF3A383B);
  static const Color outline = Color(0xFF948F97);
  static const Color outlineVariant = Color(0xFF49454D);
  static const Color tertiary = Color(0xFFF3E6B0);
  static const Color tertiaryContainer = Color(0xFFD6CA96);
  static const Color tertiaryOnContainer = Color(0xFF5D552B);
  static const Color primaryContainer = Color(0xFFD1C4E9);
  static const Color secondaryContainer = Color(0xFF224E4B);

  // --- COMPATIBILIDAD: Colores antiguos mapeados al nuevo sistema ---
  // Estos se irán eliminando a medida que refactoricemos las vistas
  static const Color accent = mint;
  static const Color accentLight = lavender;
  static const Color cardBackground = surface;
  static const Color white = textPrimary;
  static const Color textBlack = buttonPrimaryText;
  static const Color sectionWhite = textPrimary;

  // Colores específicos para módulos antiguos (Psicóloga)
  static const Color successBg = Color(0x26B2DFDB); // 15% opacidad Mint
  static const Color successText = mint;
  static const Color warningBg = Color(0x26D1C4E9); // 15% opacidad Lavender
  static const Color warningText = lavender;
  static const Color tertiaryBg = Color(0x26D6CA96); // 15% opacidad Tertiary
  static const Color greyBg = surface;
  static const Color greyLight = textSecondary;

  static const Color figmaBlue = lavender;
  static const Color figmaGrayBg = surface;
  static const Color figmaBlack = textPrimary;
  static const Color figmaMuted = textSecondary;

  // Otros nombres usados en el código
  static const Color primaryTeal = mint;
  static const Color accentOrange =
      lavender; // Mapeado a lavender para evitar vibrantes
  static const Color darkText = textSecondary;
}
