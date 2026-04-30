import 'dart:async';
import 'package:flutter/material.dart';
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
        const Spacer(),
        BreathingSphere(animation: _animationController, label: ''),
        const Spacer(),
        PhaseProgressBar(
          label: 'Sesión en curso',
          time: '$minutes:${seconds.toString().padLeft(2, '0')}',
          progress: progress,
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
