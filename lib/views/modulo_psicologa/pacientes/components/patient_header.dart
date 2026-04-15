import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientHeader extends StatelessWidget {
  const PatientHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Pacientes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Avatar pequeño de la esquina superior derecha
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.cardBackground,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Lista de pacientes para asignar una nueva actividad o cuestionario",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}