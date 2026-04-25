import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';

class CuestionarioStats extends StatelessWidget {
  const CuestionarioStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatBox('🔄', 'Respuestas Recientes', '(5)'),
        SizedBox(width: 15),
        _buildStatBox('⌛', 'Pendientes', '(12)'),
      ],
    );
  }

  Widget _buildStatBox(String emoji, String title, String count) {
    return Expanded(
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              count,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
