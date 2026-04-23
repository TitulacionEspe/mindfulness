import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientFilterRow extends StatelessWidget {
  const PatientFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Filtrar por",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        _buildFilterChip("Ultimos", true),
        const SizedBox(width: 10),
        _buildFilterChip("Nuevos", false),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
