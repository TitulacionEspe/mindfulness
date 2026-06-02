import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/self_assessment_model.dart';
import '../../viewmodels/self_assessments_viewmodel.dart';

/// ─── PostSessionLikertSheet ───────────────────────────────────────────
/// Bottom sheet minimalista con escala Likert de 5 caritas.
/// Reemplaza la antigua autopercepción densa (12 emociones + slider).
/// El usuario elige UNA carita → se guarda → se completa la sesión.
class PostSessionLikertSheet extends StatefulWidget {
  const PostSessionLikertSheet({
    super.key,
    required this.sessionId,
    required this.routineTitle,
  });

  final String sessionId;
  final String routineTitle;

  @override
  State<PostSessionLikertSheet> createState() =>
      _PostSessionLikertSheetState();
}

class _PostSessionLikertSheetState extends State<PostSessionLikertSheet> {
  int? _selectedScore;

  static const _faces = [
    _LikertFace(emoji: '😞', label: 'Muy mal',  score: 1, semantic: 'muy_mal'),
    _LikertFace(emoji: '😟', label: 'Mal',      score: 2, semantic: 'mal'),
    _LikertFace(emoji: '😐', label: 'Regular',  score: 3, semantic: 'regular'),
    _LikertFace(emoji: '😊', label: 'Bien',     score: 4, semantic: 'bien'),
    _LikertFace(emoji: '😍', label: 'Muy bien', score: 5, semantic: 'muy_bien'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SelfAssessmentsViewModel>().clearMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SelfAssessmentsViewModel>();

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Título ──
              Text(
                '¿Cómo te sientes después de la práctica?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.routineTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // ── 5 Caritas Likert ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _faces.map((face) {
                  final isSelected = _selectedScore == face.score;
                  return _LikertFaceButton(
                    face: face,
                    isSelected: isSelected,
                    enabled: !vm.isSaving,
                    onTap: () => setState(() => _selectedScore = face.score),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ── Label de la cara seleccionada ──
              AnimatedOpacity(
                opacity: _selectedScore != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _selectedScore != null
                      ? _faces[_selectedScore! - 1].label
                      : '',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Botón Guardar ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _selectedScore != null && !vm.isSaving
                          ? _saveLikert
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonPrimaryText,
                    disabledBackgroundColor:
                        AppColors.surfaceHigh,
                    disabledForegroundColor:
                        AppColors.textSecondary.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: vm.isSaving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.buttonPrimaryText,
                          ),
                        )
                      : const Text(
                          'Guardar y finalizar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              // ── Mensaje de error ──
              if (vm.errorMessage != null) ...[
                const SizedBox(height: 12),
                _InlineMessage(
                  text: vm.errorMessage!,
                  icon: Icons.error_outline_rounded,
                  color: AppColors.error,
                  background: AppColors.tertiaryBg,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLikert() async {
    if (_selectedScore == null) return;

    final vm = context.read<SelfAssessmentsViewModel>();
    final success = await vm.createAssessment(
      sessionId: widget.sessionId,
      context: AssessmentContext.postSession,
      emotionId: 'likert_scale',
      intensity: _selectedScore!,
    );

    if (!mounted || !success) return;
    Navigator.of(context).pop(true);
  }
}

// ─── Helpers privados ──────────────────────────────────────────────────

class _LikertFace {
  const _LikertFace({
    required this.emoji,
    required this.label,
    required this.score,
    required this.semantic,
  });

  final String emoji;
  final String label;
  final int score;
  final String semantic;
}

class _LikertFaceButton extends StatelessWidget {
  const _LikertFaceButton({
    required this.face,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final _LikertFace face;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${face.label}: ${face.semantic}',
      enabled: enabled,
      selected: isSelected,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 60,
          height: 84,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.mint.withValues(alpha: 0.15)
                : AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppColors.mint
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                face.emoji,
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                face.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.mint
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _InlineMessage (conservado del original) ─────────────────────────

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.text,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
