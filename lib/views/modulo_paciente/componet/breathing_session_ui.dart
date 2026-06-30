import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

class BreathingSessionUI extends StatelessWidget {
  final String currentLabel;
  final String remainingTime;
  final double phaseProgress;
  final int completedCycles;
  final int totalCycles;
  final AnimationController animationController;
  final bool soundEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback onFinish;

  const BreathingSessionUI({
    super.key,
    required this.currentLabel,
    required this.remainingTime,
    required this.phaseProgress,
    required this.completedCycles,
    required this.totalCycles,
    required this.animationController,
    required this.soundEnabled,
    required this.onToggleSound,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Visualizador central + toggle de sonido ──
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Esfera de respiración
              BreathingSphere(
                animation: animationController,
                label: currentLabel,
              ),

              // Toggle sonido / vibración (esquina superior derecha)
              Positioned(
                top: 16,
                right: 24,
                child: _SoundToggle(
                  enabled: soundEnabled,
                  onTap: onToggleSound,
                ),
              ),
            ],
          ),
        ),

        // ── Panel inferior de controles y progreso ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        onPressed: onFinish,
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
}

// ─── Botón de toggle sonido / vibración ───────────────────────────────

class _SoundToggle extends StatelessWidget {
  const _SoundToggle({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: enabled
          ? 'Sonido activado. Toca para silenciar.'
          : 'Sonido desactivado. Vibración fuerte activa.',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: enabled ? AppColors.surfaceLow : AppColors.warningBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? AppColors.outlineVariant.withValues(alpha: 0.5)
                  : AppColors.lavender.withValues(alpha: 0.4),
            ),
          ),
          child: Icon(
            enabled ? Icons.volume_up_rounded : Icons.vibration_rounded,
            size: 20,
            color: enabled ? AppColors.textSecondary : AppColors.lavender,
          ),
        ),
      ),
    );
  }
}
