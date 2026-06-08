import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/routine_model.dart';
import 'breathing_session_ui.dart';

/// BreathingRunner: Gestiona el tiempo de inhalar/exhalar.
/// No tiene interfaz propia, solo le pasa los datos al BreathingSessionUI.
///
/// Sonido: solo suena en las transiciones Inhala / Exhala.
/// Si el usuario silencia el sonido, se usa vibración háptica en su lugar.

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

  // ── Toggle sonido / vibración ──
  bool _soundEnabled = true;

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
    _onPhaseTransition(); // ← solo Inhala / Exhala
    _updatePhaseUI();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Notificación de transición: sonido o vibración
  // ─────────────────────────────────────────────────────────────────────

  void _onPhaseTransition() {
    if (_soundEnabled) {
      _playSoundForPhase();
    } else {
      _vibrate();
    }
  }

  Future<void> _playSoundForPhase() async {
    try {
      final soundPath = switch (_phase) {
        _BreathPhase.inhale => widget.pattern.inhaleSound,
        _BreathPhase.holdIn => widget.pattern.holdInSound,
        _BreathPhase.exhale => widget.pattern.exhaleSound,
        _BreathPhase.holdOut => widget.pattern.holdOutSound,
      };

      // Ensure that if a phase is skipped (duration 0) we shouldn't be here,
      // but if the sound is configured to empty we don't play.
      if (soundPath.isNotEmpty) {
        await _audioPlayer.play(AssetSource(soundPath), volume: 0.5);
      }
    } catch (_) {}
  }

  void _vibrate() {
    // Doble pulso heavy: más fuerte y perceptible que un solo impacto.
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
  }

  void _toggleSound() {
    setState(() => _soundEnabled = !_soundEnabled);
  }

  // ─────────────────────────────────────────────────────────────────────
  // UI helpers
  // ─────────────────────────────────────────────────────────────────────

  void _updatePhaseUI() {
    final duration = _getDurationFor(_phase, widget.pattern);
    _sphereController.duration = Duration(seconds: duration);
    if (_phase == _BreathPhase.inhale) _sphereController.forward(from: 0);
    if (_phase == _BreathPhase.exhale) _sphereController.reverse(from: 1);
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

    return BreathingSessionUI(
      currentLabel: _getPhaseLabel(),
      remainingTime: '${duration - _phaseElapsed}s',
      phaseProgress: progress,
      completedCycles: _cyclesCompleted,
      totalCycles: widget.pattern.cyclesRecommended,
      animationController: _sphereController,
      soundEnabled: _soundEnabled,
      onToggleSound: _toggleSound,
      onFinish: () {
        _timer?.cancel();
        widget.onComplete();
      },
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
