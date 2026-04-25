import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ActivityItemCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String category;
  final String duration;
  final String stats;

  const ActivityItemCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.category,
    required this.duration,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cuadro del Icono (Fondo gris + Emoji)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          SizedBox(width: 15),
          // Info Central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.figmaBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  category,
                  style: TextStyle(color: AppColors.figmaMuted, fontSize: 11),
                ),
                SizedBox(height: 10),
                // Fila de tiempo y reproducciones
                Row(
                  children: [
                    Text(
                      '⏱ $duration',
                      style: TextStyle(
                        color: AppColors.figmaMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      stats,
                      style: TextStyle(
                        color: AppColors.figmaMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
