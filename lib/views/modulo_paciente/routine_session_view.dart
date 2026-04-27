import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routines_viewmodel.dart';
import '../../viewmodels/self_assessments_viewmodel.dart';
import 'self_assessment_flow.dart';

// ─────────────────────────────────────────────
// Modelo de fase de respiración
// ─────────────────────────────────────────────

enum _BreathPhase { inhale, holdIn, exhale, holdOut }

extension _BreathPhaseLabel on _BreathPhase {
  String label(int seconds) {
    return switch (this) {
      _BreathPhase.inhale => 'Inhala\n$seconds segundos',
      _BreathPhase.holdIn => 'Retén\n$seconds segundos',
      _BreathPhase.exhale => 'Exhala\n$seconds segundos',
      _BreathPhase.holdOut => 'Pausa\n$seconds segundos',
    };
  }

  String get shortLabel => switch (this) {
    _BreathPhase.inhale => 'Inhala',
    _BreathPhase.holdIn => 'Retén',
    _BreathPhase.exhale => 'Exhala',
    _BreathPhase.holdOut => 'Pausa',
  };
}

// ─────────────────────────────────────────────
// Estado de la sesión de respiración
// ─────────────────────────────────────────────

class _SessionState {
  _SessionState({
    required this.phase,
    required this.phaseElapsed,
    required this.phaseDuration,
    required this.cyclesCompleted,
    required this.totalCycles,
  });

  final _BreathPhase phase;
  final int phaseElapsed; // segundos transcurridos en esta fase
  final int phaseDuration; // duración total de la fase en segundos
  final int cyclesCompleted;
  final int totalCycles;

  double get phaseProgress =>
      phaseDuration > 0 ? (phaseElapsed / phaseDuration).clamp(0.0, 1.0) : 0.0;

  double get phaseRemaining => (phaseDuration - phaseElapsed).toDouble();
}

// ─────────────────────────────────────────────
// Controlador de lógica de sesión
// ─────────────────────────────────────────────

class _SessionController {
  _SessionController({
    required BreathingPatternModel pattern,
    required VoidCallback onTick,
    required VoidCallback onCycleComplete,
    required VoidCallback onPhaseChange,
    required VoidCallback onSessionEnd,
  }) : _pattern = pattern,
       _onTick = onTick,
       _onCycleComplete = onCycleComplete,
       _onPhaseChange = onPhaseChange,
       _onSessionEnd = onSessionEnd;

  final BreathingPatternModel _pattern;
  final VoidCallback _onTick;
  final VoidCallback _onCycleComplete;
  final VoidCallback _onPhaseChange;
  final VoidCallback _onSessionEnd;

  Timer? _timer;
  _BreathPhase _phase = _BreathPhase.inhale;
  int _phaseElapsed = 0;
  int _cyclesCompleted = 0;
  bool _disposed = false;

  _BreathPhase get currentPhase => _phase;
  int get cyclesCompleted => _cyclesCompleted;

  int _durationFor(_BreathPhase p) => switch (p) {
    _BreathPhase.inhale => _pattern.inhaleSec,
    _BreathPhase.holdIn => _pattern.holdInSec,
    _BreathPhase.exhale => _pattern.exhaleSec,
    _BreathPhase.holdOut => _pattern.holdOutSec,
  };

  List<_BreathPhase> get _activePhases => [
    if (_pattern.inhaleSec > 0) _BreathPhase.inhale,
    if (_pattern.holdInSec > 0) _BreathPhase.holdIn,
    if (_pattern.exhaleSec > 0) _BreathPhase.exhale,
    if (_pattern.holdOutSec > 0) _BreathPhase.holdOut,
  ];

  _SessionState get state => _SessionState(
    phase: _phase,
    phaseElapsed: _phaseElapsed,
    phaseDuration: _durationFor(_phase),
    cyclesCompleted: _cyclesCompleted,
    totalCycles: _pattern.cyclesRecommended,
  );

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
  }

  void _tick() {
    if (_disposed) return;
    _phaseElapsed++;
    final duration = _durationFor(_phase);

    if (_phaseElapsed >= duration) {
      _advancePhase();
    } else {
      _onTick();
    }
  }

  void _advancePhase() {
    final phases = _activePhases;
    final currentIndex = phases.indexOf(_phase);
    final isLastPhase = currentIndex == phases.length - 1;

    if (isLastPhase) {
      _cyclesCompleted++;
      if (_cyclesCompleted >= _pattern.cyclesRecommended) {
        _onCycleComplete();
        _onSessionEnd();
        return;
      }
      _onCycleComplete();
    }

    final nextIndex = isLastPhase ? 0 : currentIndex + 1;
    _phase = phases[nextIndex];
    _phaseElapsed = 0;
    _onPhaseChange();
    _onTick();
  }
}

// ─────────────────────────────────────────────
// Widget de cuenta regresiva
// ─────────────────────────────────────────────

class _CountdownOverlay extends StatefulWidget {
  const _CountdownOverlay({
    required this.onComplete,
    required this.routineTitle,
  });

  final VoidCallback onComplete;
  final String routineTitle;

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay>
    with SingleTickerProviderStateMixin {
  int _count = 3;
  Timer? _timer;
  bool _started = false;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(
      begin: 1.4,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_started) return;
    setState(() => _started = true);
    _scaleController.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_count <= 1) {
        _timer?.cancel();
        widget.onComplete();
        return;
      }
      setState(() => _count--);
      _scaleController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: AppColors.textPrimary),
                padding: EdgeInsets.zero,
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Text(
                      _started
                          ? 'Comienza en'
                          : 'Encuentra una posición cómoda',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_started)
                      AnimatedBuilder(
                        animation: _scaleAnim,
                        builder: (_, __) => Transform.scale(
                          scale: _scaleAnim.value,
                          child: Text(
                            '$_count',
                            style: TextStyle(
                              color: AppColors.mint,
                              fontSize: 96,
                              fontWeight: FontWeight.w300,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    if (!_started)
                      Text(
                        widget.routineTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Encuentra una posición cómoda y relaja los hombros.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _started ? null : _startCountdown,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(_started ? 'Preparándose...' : 'Comenzar Ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonPrimaryText,
                    disabledBackgroundColor: AppColors.surfaceHigh,
                    disabledForegroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────

class RoutineSessionView extends StatefulWidget {
  const RoutineSessionView({
    super.key,
    required this.routine,
    required this.sessionId,
  });

  final RoutineModel routine;
  final String sessionId;

  @override
  State<RoutineSessionView> createState() => _RoutineSessionViewState();
}

class _RoutineSessionViewState extends State<RoutineSessionView>
    with SingleTickerProviderStateMixin {
  // Cuenta regresiva inicial
  bool _countdownDone = false;

  // Animación de la esfera
  late final AnimationController _sphereController;

  // Controlador de sesión (solo para rutinas de respiración)
  _SessionController? _sessionController;

  // Timer simple para rutinas sin patrón de respiración
  Timer? _simpleTimer;
  int _remainingSeconds = 0;

  // Estado de la sesión de respiración
  _SessionState? _sessionState;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _sessionEnded = false;
  bool _finishRequested = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.routine.durationSeconds;

    _sphereController = AnimationController(
      vsync: this,
      duration: _sphereDuration(),
    )..repeat(reverse: true);
  }

  void _onCountdownComplete() {
    setState(() => _countdownDone = true);
    final pattern = widget.routine.breathingPattern;
    if (pattern != null &&
        widget.routine.category == RoutineCategory.breathing) {
      _initBreathingSession(pattern);
    } else {
      _initSimpleSession();
    }
  }

  // ── Inicialización ────────────────────────

  void _initBreathingSession(BreathingPatternModel pattern) {
    _sessionController = _SessionController(
      pattern: pattern,
      onTick: () {
        if (!mounted) return;
        setState(() => _sessionState = _sessionController!.state);
      },
      onCycleComplete: () {
        if (!mounted) return;
        setState(() => _sessionState = _sessionController!.state);
      },
      onPhaseChange: () {
        _playBellSound();
        _updateSphereAnimationForPhase();
      },
      onSessionEnd: () {
        if (!mounted) return;
        setState(() {
          _sessionState = _sessionController!.state;
          _sessionEnded = true;
        });
        _finishSession();
      },
    );
    _sessionState = _sessionController!.state;
    _sessionController!.start();
  }

  void _initSimpleSession() {
    _simpleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _finishSession();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  Duration _sphereDuration() {
    final pattern = widget.routine.breathingPattern;
    if (pattern == null) return const Duration(seconds: 5);
    return Duration(seconds: pattern.inhaleSec > 0 ? pattern.inhaleSec : 4);
  }

  // ── Audio ─────────────────────────────────

  Future<void> _playBellSound() async {
    try {
      // Usa un asset de audio tipo campana suave
      // Asegúrate de tener el archivo en assets/sounds/bell.mp3
      await _audioPlayer.setVolume(0.6);
      await _audioPlayer.play(AssetSource('sounds/bell.wav'));
    } catch (_) {
      // Silencioso si falla — no interrumpir la sesión
    }
  }

  // ── Animación de esfera ───────────────────

  void _updateSphereAnimationForPhase() {
    if (!mounted) return;
    final phase = _sessionController?.currentPhase;
    final pattern = widget.routine.breathingPattern;
    if (pattern == null) return;

    final duration = switch (phase) {
      _BreathPhase.inhale => Duration(seconds: pattern.inhaleSec),
      _BreathPhase.holdIn => Duration(
        seconds: pattern.holdInSec > 0 ? pattern.holdInSec : 1,
      ),
      _BreathPhase.exhale => Duration(seconds: pattern.exhaleSec),
      _BreathPhase.holdOut => Duration(
        seconds: pattern.holdOutSec > 0 ? pattern.holdOutSec : 1,
      ),
      null => const Duration(seconds: 4),
    };

    _sphereController.duration = duration;

    if (phase == _BreathPhase.inhale) {
      _sphereController.forward(from: 0);
    } else if (phase == _BreathPhase.exhale) {
      _sphereController.reverse(from: 1);
    }
    // En hold: la esfera se queda estática (no repeat)
  }

  // ── Formateo ──────────────────────────────

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _guidanceText() {
    return switch (widget.routine.category) {
      RoutineCategory.breathing =>
        'Sigue el ritmo visual. No fuerces la respiración; la comodidad es la prioridad.',
      RoutineCategory.relaxation =>
        'Recorre el cuerpo con calma. Tensa muy suave y suelta cada zona.',
      RoutineCategory.sleepInduction =>
        'Deja pasar los pensamientos sin perseguirlos. Vuelve al cuerpo cuando te distraigas.',
      RoutineCategory.soundscape =>
        'Usa este espacio como una pausa silenciosa antes de dormir.',
      RoutineCategory.all => 'Mantente presente unos minutos.',
    };
  }

  // ── Finalización ─────────────────────────

  Future<void> _finishSession() async {
    if (_finishRequested) return;
    _finishRequested = true;
    _simpleTimer?.cancel();
    _sessionController?.dispose();
    if (!mounted) return;

    final postRecorded = await _requestPostAssessment();
    if (!mounted || !postRecorded) {
      _finishRequested = false;
      if (!_sessionEnded) _initSimpleSession();
      return;
    }

    final viewModel = context.read<RoutinesViewModel>();
    final saved = await viewModel.completeSession(sessionId: widget.sessionId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: saved ? AppColors.surface : AppColors.error,
        content: Text(
          saved ? 'Sesión registrada correctamente.' : viewModel.errorMessage!,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool> _requestPostAssessment() async {
    final response = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PostSessionAssessmentSheet(
        sessionId: widget.sessionId,
        routineTitle: widget.routine.title,
      ),
    );

    return response == true;
  }

  @override
  void dispose() {
    _simpleTimer?.cancel();
    _sessionController?.dispose();
    _sphereController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Pantalla de cuenta regresiva primero
    if (!_countdownDone) {
      return _CountdownOverlay(
        routineTitle: widget.routine.title,
        onComplete: _onCountdownComplete,
      );
    }

    final viewModel = context.watch<RoutinesViewModel>();
    final assessmentsViewModel = context.watch<SelfAssessmentsViewModel>();
    final isBusy = viewModel.isCompleting || assessmentsViewModel.isSaving;
    final isBreathing = _sessionState != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isBusy),
              const SizedBox(height: 14),
              _buildTitle(),
              const SizedBox(height: 8),
              if (!isBreathing) _buildSimpleTimer(),
              const Spacer(),
              _buildSphere(isBreathing),
              const Spacer(),
              if (isBreathing) ...[
                _buildPhaseBar(_sessionState!),
                const SizedBox(height: 16),
                _buildCyclesBar(_sessionState!),
                const SizedBox(height: 20),
              ] else ...[
                _buildGuidanceText(),
                const SizedBox(height: 24),
              ],
              _buildFinishButton(isBusy, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  // ── Subwidgets ────────────────────────────

  Widget _buildHeader(bool isBusy) {
    return IconButton(
      onPressed: isBusy ? null : () => Navigator.of(context).pop(),
      icon: Icon(Icons.close, color: AppColors.textPrimary),
      tooltip: 'Salir de la sesión',
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.routine.title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
    );
  }

  Widget _buildSimpleTimer() {
    return Text(
      'Tiempo restante ${_formatTime(_remainingSeconds)}',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
    );
  }

  Widget _buildSphere(bool isBreathing) {
    return Center(
      child: AnimatedBuilder(
        animation: _sphereController,
        builder: (context, _) {
          final scale = 0.78 + (_sphereController.value * 0.22);
          final phaseText = _phaseText(isBreathing);
          return Transform.scale(
            scale: scale,
            child: _SphereWidget(
              size: math.min(MediaQuery.sizeOf(context).width * 0.62, 240),
              label: phaseText,
              color: AppColors.successBg,
              textColor: AppColors.textPrimary,
            ),
          );
        },
      ),
    );
  }

  String _phaseText(bool isBreathing) {
    if (isBreathing && _sessionState != null) {
      return _sessionState!.phase.label(_sessionState!.phaseDuration);
    }
    return switch (widget.routine.category) {
      RoutineCategory.breathing =>
        _sphereController.value < 0.5 ? 'Inhala' : 'Exhala',
      RoutineCategory.relaxation => 'Suelta tensión',
      RoutineCategory.sleepInduction => 'Observa y descansa',
      RoutineCategory.soundscape => 'Permanece en calma',
      RoutineCategory.all => 'Respira',
    };
  }

  /// Barra de progreso de la fase actual (Inhala/Exhala)
  Widget _buildPhaseBar(_SessionState state) {
    final remaining = state.phaseDuration - state.phaseElapsed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.phase.shortLabel,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${remaining}s',
              style: TextStyle(
                color: AppColors.mint ?? const Color(0xFF4DB6AC),
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
            value: state.phaseProgress,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.mint ?? const Color(0xFF4DB6AC),
            ),
          ),
        ),
      ],
    );
  }

  /// Barra de ciclos: segmentos discretos como en las imágenes
  Widget _buildCyclesBar(_SessionState state) {
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
              '${state.cyclesCompleted}/${state.totalCycles} Ciclos',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _CycleSegmentsBar(
          total: state.totalCycles,
          completed: state.cyclesCompleted,
          activeColor: AppColors.mint ?? const Color(0xFF4DB6AC),
          inactiveColor: AppColors.surface,
        ),
      ],
    );
  }

  Widget _buildGuidanceText() {
    return Text(
      _guidanceText(),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16,
        height: 1.45,
      ),
    );
  }

  Widget _buildFinishButton(bool isBusy, RoutinesViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isBusy ? null : _finishSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonPrimaryText,
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          viewModel.isCompleting ? 'Guardando...' : 'Finalizar',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget reutilizable: esfera animada
// ─────────────────────────────────────────────

class _SphereWidget extends StatelessWidget {
  const _SphereWidget({
    required this.size,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final double size;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget reutilizable: barra de ciclos con segmentos
// ─────────────────────────────────────────────

class _CycleSegmentsBar extends StatelessWidget {
  const _CycleSegmentsBar({
    required this.total,
    required this.completed,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int total;
  final int completed;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 4.0;
        final segmentWidth = (constraints.maxWidth - gap * (total - 1)) / total;
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
                  color: isDone ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
