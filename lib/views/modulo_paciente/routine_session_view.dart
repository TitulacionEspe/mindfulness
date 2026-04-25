import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routines_viewmodel.dart';

class RoutineSessionView extends StatefulWidget {
  const RoutineSessionView({super.key, required this.routine});

  final RoutineModel routine;

  @override
  State<RoutineSessionView> createState() => _RoutineSessionViewState();
}

class _RoutineSessionViewState extends State<RoutineSessionView>
    with SingleTickerProviderStateMixin {
  late final DateTime _startedAt;
  late final AnimationController _breathingController;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _finishRequested = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _remainingSeconds = widget.routine.durationSeconds;
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _cycleDuration(widget.routine)),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _finishSession();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoutinesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: viewModel.isCompleting
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: AppColors.textPrimary),
                tooltip: 'Salir de la sesion',
              ),
              SizedBox(height: 14),
              Text(
                widget.routine.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tiempo restante ${_formatTime(_remainingSeconds)}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const Spacer(),
              Center(
                child: AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    final scale = 0.78 + (_breathingController.value * 0.22);
                    final phaseText = _phaseText(widget.routine);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: math.min(
                          MediaQuery.sizeOf(context).width * 0.62,
                          240,
                        ),
                        height: math.min(
                          MediaQuery.sizeOf(context).width * 0.62,
                          240,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Text(
                            phaseText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Spacer(),
              Text(
                _guidanceText(widget.routine),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: viewModel.isCompleting ? null : _finishSession,
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
                    style: const TextStyle(
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

  int _cycleDuration(RoutineModel routine) {
    final pattern = routine.breathingPattern;
    if (pattern == null) return 5;
    return pattern.inhaleSec +
        pattern.holdInSec +
        pattern.exhaleSec +
        pattern.holdOutSec;
  }

  String _phaseText(RoutineModel routine) {
    if (routine.category == RoutineCategory.breathing) {
      return _breathingController.value < 0.5 ? 'Inhala' : 'Exhala';
    }
    return switch (routine.category) {
      RoutineCategory.relaxation => 'Suelta tension',
      RoutineCategory.sleepInduction => 'Observa y descansa',
      RoutineCategory.soundscape => 'Permanece en calma',
      RoutineCategory.all => 'Respira',
      RoutineCategory.breathing => 'Respira',
    };
  }

  String _guidanceText(RoutineModel routine) {
    return switch (routine.category) {
      RoutineCategory.breathing =>
        'Sigue el ritmo visual. No fuerces la respiracion; la comodidad es la prioridad.',
      RoutineCategory.relaxation =>
        'Recorre el cuerpo con calma. Tensa muy suave y suelta cada zona.',
      RoutineCategory.sleepInduction =>
        'Deja pasar los pensamientos sin perseguirlos. Vuelve al cuerpo cuando te distraigas.',
      RoutineCategory.soundscape =>
        'Usa este espacio como una pausa silenciosa antes de dormir.',
      RoutineCategory.all => 'Mantente presente unos minutos.',
    };
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  Future<void> _finishSession() async {
    if (_finishRequested) return;
    _finishRequested = true;
    _timer?.cancel();
    if (!mounted) return;

    final viewModel = context.read<RoutinesViewModel>();
    final saved = await viewModel.completeSession(
      routine: widget.routine,
      startedAt: _startedAt,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: saved ? AppColors.surface : AppColors.error,
        content: Text(
          saved ? 'Sesion registrada correctamente.' : viewModel.errorMessage!,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
