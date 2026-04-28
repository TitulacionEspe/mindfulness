import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PhaseProgressBar extends StatelessWidget {
  final String label;
  final String time;
  final double progress;

  const PhaseProgressBar({
    super.key,
    required this.label,
    required this.time,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mint),
          ),
        ),
      ],
    );
  }
}

class CycleSegmentsBar extends StatelessWidget {
  final int total;
  final int completed;

  const CycleSegmentsBar({
    super.key,
    required this.total,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de la Sesión',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$completed/$total Ciclos',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 4.0;
            final segmentWidth =
                (constraints.maxWidth - gap * (total - 1)) / total;
            return Row(
              children: List.generate(total, (i) {
                final isDone = i < completed;
                return Padding(
                  padding: EdgeInsets.only(right: i < total - 1 ? gap : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: segmentWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.mint : AppColors.surface,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
