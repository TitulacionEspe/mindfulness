import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CuestionarioSearch extends StatelessWidget {
  const CuestionarioSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: AppColors.surfaceLowest),
      decoration: InputDecoration(
        hintText: "Buscar test psicológico...",
        hintStyle: TextStyle(color: AppColors.textSecondary),
        suffixIcon: Icon(Icons.search, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.cardBackground, // Tu azul oscuro de componentes
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
