import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../models/self_assessment_model.dart';
import '../../viewmodels/routines_viewmodel.dart';
import '../../viewmodels/self_assessments_viewmodel.dart';
import 'routine_session_view.dart';

class PreSessionAssessmentView extends StatefulWidget {
  const PreSessionAssessmentView({
    super.key,
    required this.routine,
    this.assignmentId,
  });

  final RoutineModel routine;
  final String? assignmentId;

  @override
  State<PreSessionAssessmentView> createState() =>
      _PreSessionAssessmentViewState();
}

class _PreSessionAssessmentViewState extends State<PreSessionAssessmentView> {
  String? _emotionId;
  int _intensity = 5;

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
    final routinesViewModel = context.watch<RoutinesViewModel>();
    final assessmentsViewModel = context.watch<SelfAssessmentsViewModel>();
    final isBusy =
        routinesViewModel.isCompleting || assessmentsViewModel.isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: AppColors.outlineVariant),
                      backgroundColor: AppColors.surfaceLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Autopercepcion previa',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.routine.title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            SelfAssessmentFormCard(
              title: 'Como te sientes antes de iniciar?',
              selectedEmotion: _emotionId,
              intensity: _intensity,
              isSaving: isBusy,
              buttonLabel: 'Iniciar sesion',
              onEmotionSelected: (value) => setState(() => _emotionId = value),
              onIntensityChanged: (value) => setState(() => _intensity = value),
              onSubmit: _canSubmit && !isBusy ? _startSession : null,
            ),
            if (assessmentsViewModel.errorMessage != null) ...[
              const SizedBox(height: 12),
              _InlineMessage(
                text: assessmentsViewModel.errorMessage!,
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
                background: AppColors.tertiaryBg,
              ),
            ],
            if (routinesViewModel.errorMessage != null) ...[
              const SizedBox(height: 12),
              _InlineMessage(
                text: routinesViewModel.errorMessage!,
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
                background: AppColors.tertiaryBg,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _canSubmit => _emotionId != null && _emotionId!.trim().isNotEmpty;

  Future<void> _startSession() async {
    if (!_canSubmit) return;

    final startedAt = DateTime.now();
    final routinesViewModel = context.read<RoutinesViewModel>();
    final assessmentsViewModel = context.read<SelfAssessmentsViewModel>();

    final sessionId = await routinesViewModel.startSession(
      routine: widget.routine,
      startedAt: startedAt,
    );
    if (!mounted || sessionId == null) return;

    final savedPre = await assessmentsViewModel.createAssessment(
      sessionId: sessionId,
      context: AssessmentContext.preSession,
      emotionId: _emotionId!,
      intensity: _intensity,
    );
    if (!mounted || !savedPre) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RoutineSessionView(
          routine: widget.routine,
          sessionId: sessionId,
          assignmentId: widget.assignmentId,
        ),
      ),
    );
  }
}

class PostSessionAssessmentSheet extends StatefulWidget {
  const PostSessionAssessmentSheet({
    super.key,
    required this.sessionId,
    required this.routineTitle,
  });

  final String sessionId;
  final String routineTitle;

  @override
  State<PostSessionAssessmentSheet> createState() =>
      _PostSessionAssessmentSheetState();
}

class _PostSessionAssessmentSheetState
    extends State<PostSessionAssessmentSheet> {
  String? _emotionId;
  int _intensity = 5;

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
    final assessmentsViewModel = context.watch<SelfAssessmentsViewModel>();

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autopercepcion posterior',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.routineTitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                SelfAssessmentFormCard(
                  title: 'Como te sientes despues de la actividad?',
                  selectedEmotion: _emotionId,
                  intensity: _intensity,
                  isSaving: assessmentsViewModel.isSaving,
                  buttonLabel: 'Guardar y finalizar',
                  onEmotionSelected: (value) =>
                      setState(() => _emotionId = value),
                  onIntensityChanged: (value) =>
                      setState(() => _intensity = value),
                  onSubmit: _canSubmit && !assessmentsViewModel.isSaving
                      ? _savePostAssessment
                      : null,
                ),
                if (assessmentsViewModel.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _InlineMessage(
                    text: assessmentsViewModel.errorMessage!,
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error,
                    background: AppColors.tertiaryBg,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _canSubmit => _emotionId != null && _emotionId!.trim().isNotEmpty;

  Future<void> _savePostAssessment() async {
    if (!_canSubmit) return;

    final assessmentsViewModel = context.read<SelfAssessmentsViewModel>();
    final success = await assessmentsViewModel.createAssessment(
      sessionId: widget.sessionId,
      context: AssessmentContext.postSession,
      emotionId: _emotionId!,
      intensity: _intensity,
    );

    if (!mounted || !success) return;
    Navigator.of(context).pop(true);
  }
}

class SelfAssessmentFormCard extends StatelessWidget {
  const SelfAssessmentFormCard({
    super.key,
    required this.title,
    required this.selectedEmotion,
    required this.intensity,
    required this.isSaving,
    required this.buttonLabel,
    required this.onEmotionSelected,
    required this.onIntensityChanged,
    required this.onSubmit,
  });

  final String title;
  final String? selectedEmotion;
  final int intensity;
  final bool isSaving;
  final String buttonLabel;
  final ValueChanged<String> onEmotionSelected;
  final ValueChanged<int> onIntensityChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final emotions = SelfAssessmentsViewModel.emotionCatalog;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions.map((emotion) {
              final selected = selectedEmotion == emotion;
              return ChoiceChip(
                label: Text(_capitalize(emotion)),
                selected: selected,
                onSelected: isSaving ? null : (_) => onEmotionSelected(emotion),
                backgroundColor: AppColors.surfaceLow,
                selectedColor: AppColors.mint,
                side: BorderSide(
                  color: selected ? AppColors.mint : AppColors.outlineVariant,
                ),
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.buttonPrimaryText
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text(
            'Intensidad: $intensity/10',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$intensity',
            onChanged: isSaving
                ? null
                : (value) => onIntensityChanged(value.round()),
          ),
          const SizedBox(height: 6),
          Text(
            '1 leve - 10 muy intensa',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.buttonPrimaryText,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

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
