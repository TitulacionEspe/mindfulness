import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BreathingCyclesInfo extends StatelessWidget {
  final int inhale;
  final int holdIn;
  final int exhale;
  final int holdOut;
  final int durationMinutes;

  const BreathingCyclesInfo({
    super.key,
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final int cycleTime = inhale + holdIn + exhale + holdOut;
    final int totalSeconds = durationMinutes * 60;
    final int cycles = cycleTime > 0 ? (totalSeconds / cycleTime).floor() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tiempo por ciclo:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("$cycleTime seg"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ciclos totales estimadas:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "$cycles",
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Se realizarán $cycles ciclos completos en $durationMinutes min.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
