import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';

import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

class TimedRunner extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onComplete;

  const TimedRunner({
    super.key,
    required this.durationSeconds,
    required this.onComplete,
  });

  @override
  State<TimedRunner> createState() => _TimedRunnerState();
}

class _TimedRunnerState extends State<TimedRunner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed++;
        if (_elapsed >= widget.durationSeconds) {
          _timer?.cancel();
          widget.onComplete();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.durationSeconds - _elapsed;
    final minutes = (remaining / 60).floor();
    final seconds = remaining % 60;
    final progress = (_elapsed / widget.durationSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        // ── Área visual principal ──
        Expanded(
          child: Center(
            child: SizedBox(
              height: 300,
              child: BreathingSphere(
                animation: _animationController,
                label: '',
              ),
            ),
          ),
        ),

        // ── Panel inferior de controles y progreso ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhaseProgressBar(
                label: 'Sesión en curso',
                time: '$minutes:${seconds.toString().padLeft(2, '0')}',
                progress: progress,
              ),
              const SizedBox(height: 32),
              _buildFinishButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: widget.onComplete,
        icon: const Icon(Icons.check_circle_outline_rounded),
        label: const Text(
          "Finalizar sesión",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lavender.withValues(alpha: 0.15),
          foregroundColor: AppColors.lavender,
          elevation: 0,
          side: BorderSide(color: AppColors.lavender.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
