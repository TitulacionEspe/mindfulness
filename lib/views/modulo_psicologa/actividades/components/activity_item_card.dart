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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // Cuadro del Icono (Fondo gris + Emoji)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 15),
          // Info Central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.figmaBlack, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(category, style: const TextStyle(color: AppColors.figmaMuted, fontSize: 11)),
                const SizedBox(height: 10),
                // Fila de tiempo y reproducciones
                Row(
                  children: [
                    Text('⏱ $duration', style: const TextStyle(color: AppColors.figmaMuted, fontSize: 9.5, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 15),
                    Text(stats, style: const TextStyle(color: AppColors.figmaMuted, fontSize: 9.5, fontWeight: FontWeight.w700)),
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