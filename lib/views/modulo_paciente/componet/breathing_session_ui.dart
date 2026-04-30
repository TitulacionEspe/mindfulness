import 'package:flutter/material.dart';
import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

class BreathingSessionUI extends StatelessWidget {
  final String currentLabel;
  final String remainingTime;
  final double phaseProgress;
  final int completedCycles;
  final int totalCycles;
  final AnimationController animationController;
  final VoidCallback onFinish;

  const BreathingSessionUI({
    super.key,
    required this.currentLabel,
    required this.remainingTime,
    required this.phaseProgress,
    required this.completedCycles,
    required this.totalCycles,
    required this.animationController,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        BreathingSphere(animation: animationController, label: currentLabel),
        const Spacer(),
        PhaseProgressBar(
          label: currentLabel,
          time: remainingTime,
          progress: phaseProgress,
        ),
        const SizedBox(height: 16),
        CycleSegmentsBar(total: totalCycles, completed: completedCycles),
        const SizedBox(height: 32),
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
