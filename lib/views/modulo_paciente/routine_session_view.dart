import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../moduloTareas/viewmodels/tasks_viewmodel.dart';
import '../../viewmodels/routines_viewmodel.dart';
import 'componet/breathing_sphere.dart';
import 'componet/session_progress_widgets.dart';
import 'self_assessment_flow.dart';

// ─────────────────────────────────────────────
// Lógica de Estado y Control de Sesión
// ─────────────────────────────────────────────

enum _BreathPhase { inhale, holdIn, exhale, holdOut }

class _SessionState {
  final _BreathPhase phase;
  final int phaseElapsed;
  final int phaseDuration;
  final int cyclesCompleted;
  final int totalCycles;

  _SessionState({
    required this.phase,
    required this.phaseElapsed,
    required this.phaseDuration,
    required this.cyclesCompleted,
    required this.totalCycles,
  });

  double get progress =>
      phaseDuration > 0 ? (phaseElapsed / phaseDuration).clamp(0.0, 1.0) : 0.0;
  String get label => switch (phase) {
    _BreathPhase.inhale => 'Inhala',
    _BreathPhase.holdIn => 'Retén',
    _BreathPhase.exhale => 'Exhala',
    _BreathPhase.holdOut => 'Pausa',
  };
}

// ─────────────────────────────────────────────
// VISTA PRINCIPAL
// ─────────────────────────────────────────────

class RoutineSessionView extends StatefulWidget {
  final RoutineModel routine;
  final String sessionId;
  final String? assignmentId;

  const RoutineSessionView({
    super.key,
    required this.routine,
    required this.sessionId,
    this.assignmentId,
  });

  @override
  State<RoutineSessionView> createState() => _RoutineSessionViewState();
}

class _RoutineSessionViewState extends State<RoutineSessionView>
    with SingleTickerProviderStateMixin {
  bool _countdownDone = false;
  bool _finishRequested = false;
  late final AnimationController _sphereController;

  Timer? _timer;
  _BreathPhase _phase = _BreathPhase.inhale;
  int _phaseElapsed = 0;
  int _cyclesCompleted = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _sphereController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _startSession() {
    setState(() => _countdownDone = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _updatePhaseUI();
  }

  void _tick() {
    if (!mounted) return;
    final p = widget.routine.breathingPattern!;
    final duration = _getDurationFor(_phase, p);

    setState(() {
      _phaseElapsed++;
      if (_phaseElapsed >= duration) {
        _advancePhase(p);
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

  void _advancePhase(BreathingPatternModel p) {
    final phases = [
      _BreathPhase.inhale,
      _BreathPhase.holdIn,
      _BreathPhase.exhale,
      _BreathPhase.holdOut,
    ].where((ph) => _getDurationFor(ph, p) > 0).toList();

    int currentIndex = phases.indexOf(_phase);
    if (currentIndex == phases.length - 1) {
      _cyclesCompleted++;
      if (_cyclesCompleted >= p.cyclesRecommended) {
        _finishSession();
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
    final p = widget.routine.breathingPattern!;
    _sphereController.duration = Duration(seconds: _getDurationFor(_phase, p));
    if (_phase == _BreathPhase.inhale) _sphereController.forward(from: 0);
    if (_phase == _BreathPhase.exhale) _sphereController.reverse(from: 1);
  }

  Future<void> _playBell() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/bell.wav'), volume: 0.5);
    } catch (_) {}
  }

  Future<void> _finishSession() async {
    if (_finishRequested) return;
    _finishRequested = true;
    _timer?.cancel();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      builder: (_) => PostSessionAssessmentSheet(
        sessionId: widget.sessionId,
        routineTitle: widget.routine.title,
      ),
    );

    if (ok == true && mounted) {
      await context.read<RoutinesViewModel>().completeSession(
        sessionId: widget.sessionId,
      );

      if (!mounted) return;

      if (widget.assignmentId != null) {
        await context.read<TasksViewModel>().markAsDone(
          widget.sessionId,
          widget.assignmentId!,
        );
      }

      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } else {
      _finishRequested = false;
      _startSession(); // Reanudar si cancela
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_countdownDone) return _buildCountdown();

    final p = widget.routine.breathingPattern!;
    final state = _SessionState(
      phase: _phase,
      phaseElapsed: _phaseElapsed,
      phaseDuration: _getDurationFor(_phase, p),
      cyclesCompleted: _cyclesCompleted,
      totalCycles: p.cyclesRecommended,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              BreathingSphere(animation: _sphereController, label: state.label),
              const Spacer(),
              PhaseProgressBar(
                label: state.label,
                time: '${state.phaseDuration - state.phaseElapsed}s',
                progress: state.progress,
              ),
              const SizedBox(height: 16),
              CycleSegmentsBar(
                total: state.totalCycles,
                completed: state.cyclesCompleted,
              ),
              const SizedBox(height: 32),
              _buildFinishButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.routine.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startSession,
              child: const Text("Comenzar Ahora"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
        Text(
          widget.routine.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _finishSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
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

  @override
  void dispose() {
    _timer?.cancel();
    _sphereController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
