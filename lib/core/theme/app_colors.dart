import 'package:flutter/material.dart';

class AppColors {
  // --- NUEVO SISTEMA: Nocturne Minimalist ---
  static const Color background = Color(0xFF1E1A24);
  static const Color surface = Color(0xFF2A2532);
  static const Color textPrimary = Color(0xFFE6E1EB);
  static const Color textSecondary = Color(0xFF9E95A3);
  static const Color lavender = Color(0xFFD1C4E9);
  static const Color mint = Color(0xFFB2DFDB);
  static const Color navBorder = Color(0xFF362F3D);
  static const Color buttonPrimary = Color(0xFFB2DFDB);
  static const Color buttonPrimaryText = Color(0xFF1E1A24);
  static const Color error = Color(0xFFCF6679);

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
