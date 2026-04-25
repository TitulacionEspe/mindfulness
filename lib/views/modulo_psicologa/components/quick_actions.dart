import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Acciones Rápidas",
          style: TextStyle(
            color: AppColors.surfaceLowest,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        _buildActionItem(
          "Asignar Nueva Actividad",
          Icons.arrow_forward,
          AppColors.surfaceLowest,
        ),
        _buildActionItem(
          "Revisar Cuestionarios (12)",
          Icons.arrow_forward,
          AppColors.surfaceLowest,
        ),
        _buildActionItem(
          "Atender Alertas (2)",
          Icons.arrow_forward,
          AppColors.tertiaryContainer,
          isAlert: true,
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    IconData icon,
    Color bgColor, {
    bool isAlert = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isAlert)
                Icon(Icons.warning, color: AppColors.tertiary, size: 20),
              if (isAlert) SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isAlert
                      ? AppColors.tertiaryOnContainer
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Icon(
            icon,
            color: isAlert ? AppColors.tertiary : AppColors.outlineVariant,
            size: 18,
          ),
        ],
      ),
    );
  }
}
