import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/componet/view_audio_runner.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../moduloTareas/viewmodels/tasks_viewmodel.dart';
import '../../viewmodels/routines_viewmodel.dart';
import 'componet/breathing_runner.dart';
import 'componet/relaxation_runner.dart';
import 'componet/viewtimed_runner.dart';
import 'self_assessment_flow.dart';

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

class _RoutineSessionViewState extends State<RoutineSessionView> {
  bool _countdownDone = false;
  bool _finishRequested = false;

  void _startSession() {
    setState(() => _countdownDone = true);
  }

  Future<void> _onSessionFinished() async {
    if (_finishRequested) return;
    _finishRequested = true;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      builder: (_) => PostSessionLikertSheet(
        sessionId: widget.sessionId,
        routineTitle: widget.routine.title,
      ),
    );

    if (ok == true && mounted) {
      await context.read<RoutinesViewModel>().completeSession(
        sessionId: widget.sessionId,
      );

      if (widget.assignmentId != null && mounted) {
        await context.read<TasksViewModel>().markAsDone(
          widget.sessionId,
          widget.assignmentId!,
        );
      }

      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } else {
      _finishRequested = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_countdownDone) return _buildCountdown();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildHeader(),
            ),
            Expanded(
              child: _buildRunner(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunner() {
    final pattern = widget.routine.breathingPattern;
    final audioUrl = widget.routine.audioUrl;

    if (pattern != null) {
      return BreathingRunner(pattern: pattern, onComplete: _onSessionFinished);
    }

    if (audioUrl != null && audioUrl.isNotEmpty) {
      return AudioRunner(
        audioUrl: audioUrl,
        durationSeconds: widget.routine.durationSeconds,
        category: widget.routine.category,
        onComplete: _onSessionFinished,
      );
    }

    if (widget.routine.category == RoutineCategory.relaxation) {
      return RelaxationRunner(
        durationSeconds: widget.routine.durationSeconds,
        onComplete: _onSessionFinished,
      );
    }

    return TimedRunner(
      durationSeconds: widget.routine.durationSeconds,
      onComplete: _onSessionFinished,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: AppColors.textPrimary.withValues(alpha: 0.5),
          ),
        ),
        Expanded(
          child: Text(
            widget.routine.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
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
            const SizedBox(height: 12),
            Text(
              widget.routine.category.label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: AppColors.buttonPrimaryText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Comenzar Ahora"),
            ),
          ],
        ),
      ),
    );
  }
}
