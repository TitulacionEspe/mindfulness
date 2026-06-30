import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/models/routine_model.dart';
import 'package:mindfulness_app/moduloPsiquiatra/model_ps/routine_model.dart';
import 'package:mindfulness_app/views/modulo_paciente/componet/breathing_runner.dart';
import 'package:mindfulness_app/views/modulo_paciente/componet/view_audio_runner.dart';
import 'package:mindfulness_app/views/modulo_paciente/componet/viewtimed_runner.dart';

class RoutinePreviewScreen extends StatelessWidget {
  final RoutineTemplate routine;

  const RoutinePreviewScreen({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildPreviewBadge(),
              Expanded(child: _buildRunner(context)),
              _buildExitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cerrar vista previa',
          icon: Icon(Icons.close, color: AppColors.textPrimary),
        ),
        Expanded(
          child: Text(
            routine.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildPreviewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lavender.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lavender.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_outlined, size: 14, color: AppColors.lavender),
          const SizedBox(width: 6),
          Text(
            "MODO PREVISUALIZACIÓN",
            style: TextStyle(
              color: AppColors.lavender,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunner(BuildContext context) {
    final pattern = routine.breathingPattern;
    final audioUrl = routine.audioUrl;
    final categoryEnum = RoutineCategoryX.fromValue(routine.category);

    // 1. Prioridad: Respiración
    if (categoryEnum == RoutineCategory.breathing && pattern != null) {
      return BreathingRunner(
        pattern: pattern,
        onComplete: () => _showFinishDialog(context),
      );
    }

    // 2. Terapia de Sonido / Meditación
    if (audioUrl != null && audioUrl.isNotEmpty) {
      return AudioRunner(
        audioUrl: audioUrl,
        durationSeconds: routine.durationSeconds,
        category: categoryEnum,
        onComplete: () => _showFinishDialog(context),
      );
    }

    // 3. Temporizador Genérico
    return TimedRunner(
      durationSeconds: routine.durationSeconds,
      onComplete: () => _showFinishDialog(context),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          side: BorderSide(color: AppColors.error, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "SALIR DE PREVISUALIZACIÓN",
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  void _showFinishDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Previsualización completada con éxito."),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }
}
