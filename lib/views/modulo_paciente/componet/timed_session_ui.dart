import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

class TimedSessionUI extends StatelessWidget {
  final String title;
  final int elapsedSeconds;
  final int totalSeconds;
  final AnimationController animationController;
  final VoidCallback onFinish;

  const TimedSessionUI({
    super.key,
    required this.title,
    required this.elapsedSeconds,
    required this.totalSeconds,
    required this.animationController,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalSeconds - elapsedSeconds;
    final minutes = (remaining / 60).floor();
    final seconds = remaining % 60;
    final progress = (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        const Spacer(),
        // Animación tranquila pulsante
        BreathingSphere(animation: animationController, label: ''),
        const Spacer(),
        PhaseProgressBar(
          label: 'Sesión de respaldo activa',
          time: '$minutes:${seconds.toString().padLeft(2, '0')}',
          progress: progress,
        ),
        const SizedBox(height: 48),
        _buildFinishButton(),
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onFinish,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successBg,
          side: BorderSide(color: AppColors.mint, width: 1),
        ),
        child: Text(
          'Finalizar',
          style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
