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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cuadro del Icono (Fondo suave + Emoji)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),

          // Info Central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // Fila de tiempo y reproducciones con iconos modernos
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: AppColors.mint),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 14,
                      color: AppColors.lavender,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stats.replaceAll('▶ ', '').replaceAll('👁 ', ''),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }
}
