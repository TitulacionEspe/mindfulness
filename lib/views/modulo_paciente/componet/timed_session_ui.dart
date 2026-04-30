import 'package:flutter/material.dart';
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
          label: 'Sesión en curso',
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
          backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
          side: const BorderSide(color: Colors.cyanAccent, width: 1),
        ),
        child: const Text(
          "FINALIZAR",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
