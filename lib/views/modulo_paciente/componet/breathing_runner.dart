import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../models/routine_model.dart';
import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

enum _BreathPhase { inhale, holdIn, exhale, holdOut }

class BreathingRunner extends StatefulWidget {
  final BreathingPatternModel pattern;
  final VoidCallback onComplete;

  const BreathingRunner({
    super.key,
    required this.pattern,
    required this.onComplete,
  });

  @override
  State<BreathingRunner> createState() => _BreathingRunnerState();
}

class _BreathingRunnerState extends State<BreathingRunner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sphereController;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  _BreathPhase _phase = _BreathPhase.inhale;
  int _phaseElapsed = 0;
  int _cyclesCompleted = 0;

  @override
  void initState() {
    super.initState();
    _sphereController = AnimationController(vsync: this);
    _startRunner();
  }

  void _startRunner() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _updatePhaseUI();
  }

  void _tick() {
    if (!mounted) return;
    final duration = _getDurationFor(_phase, widget.pattern);

    setState(() {
      _phaseElapsed++;
      if (_phaseElapsed >= duration) {
        _advancePhase();
      }
    });
  }

  int _getDurationFor(_BreathPhase phase, BreathingPatternModel p) =>
      switch (phase) {
        _BreathPhase.inhale => p.inhaleSec,
        _BreathPhase.holdIn => p.holdInSec,
        _BreathPhase.exhale => p.exhaleSec,
        _BreathPhase.holdOut => p.holdOutSec,
      };

  void _advancePhase() {
    final phases = [
      _BreathPhase.inhale,
      _BreathPhase.holdIn,
      _BreathPhase.exhale,
      _BreathPhase.holdOut,
    ].where((ph) => _getDurationFor(ph, widget.pattern) > 0).toList();

    int currentIndex = phases.indexOf(_phase);
    if (currentIndex == phases.length - 1) {
      _cyclesCompleted++;
      if (_cyclesCompleted >= widget.pattern.cyclesRecommended) {
        _timer?.cancel();
        widget.onComplete();
        return;
      }
      _phase = phases[0];
    } else {
      _phase = phases[currentIndex + 1];
    }

    _phaseElapsed = 0;
    _playBell();
    _updatePhaseUI();
  }

  void _updatePhaseUI() {
    final duration = _getDurationFor(_phase, widget.pattern);
    _sphereController.duration = Duration(seconds: duration);
    if (_phase == _BreathPhase.inhale) _sphereController.forward(from: 0);
    if (_phase == _BreathPhase.exhale) _sphereController.reverse(from: 1);
  }

  Future<void> _playBell() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/bell.wav'), volume: 0.5);
    } catch (_) {}
  }

  String _getPhaseLabel() => switch (_phase) {
    _BreathPhase.inhale => 'Inhala',
    _BreathPhase.holdIn => 'Retén',
    _BreathPhase.exhale => 'Exhala',
    _BreathPhase.holdOut => 'Pausa',
  };

  @override
  Widget build(BuildContext context) {
    final duration = _getDurationFor(_phase, widget.pattern);
    final progress = duration > 0
        ? (_phaseElapsed / duration).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        const Spacer(),
        BreathingSphere(animation: _sphereController, label: _getPhaseLabel()),
        const Spacer(),
        PhaseProgressBar(
          label: _getPhaseLabel(),
          time: '${duration - _phaseElapsed}s',
          progress: progress,
        ),
        const SizedBox(height: 16),
        CycleSegmentsBar(
          total: widget.pattern.cyclesRecommended,
          completed: _cyclesCompleted,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sphereController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
