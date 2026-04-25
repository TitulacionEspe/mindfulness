import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientCard extends StatelessWidget {
  final String name;
  final String condition;
  final double progress;

  const PatientCard({
    super.key,
    required this.name,
    required this.condition,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icono/Imagen circular del paciente
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            child: Icon(Icons.person, color: AppColors.accent),
          ),
          SizedBox(width: 16),
          // Info Central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  condition,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 12),
                // Barra de progreso delgada
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.textPrimary.withValues(
                      alpha: 0.05,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mint),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          // Indicador de porcentaje y check
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Icon(Icons.check_circle, color: AppColors.mint, size: 22),
            ],
          ),
        ],
      ),
    );
  }
}
