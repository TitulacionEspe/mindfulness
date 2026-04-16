import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CuestionarioSearch extends StatelessWidget {
  const CuestionarioSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Buscar test psicológico...",
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        suffixIcon: const Icon(Icons.search, color: AppColors.accent),
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