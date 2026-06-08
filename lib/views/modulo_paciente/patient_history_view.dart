import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/patient_history_model.dart';
import '../../viewmodels/patient_history_viewmodel.dart';

class PatientHistoryView extends StatefulWidget {
  const PatientHistoryView({super.key});

  @override
  State<PatientHistoryView> createState() => _PatientHistoryViewState();
}

class _PatientHistoryViewState extends State<PatientHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PatientHistoryViewModel>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PatientHistoryViewModel>();
    final metrics = viewModel.historyMetrics;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Historial personal',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: 'Actualizar historial',
                        onPressed: viewModel.isLoading
                            ? null
                            : () => viewModel.loadHistory(force: true),
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _ProgressMetricsCard(
                metrics: metrics,
                selectedRangeDays: viewModel.selectedRangeDays,
              ),
              const SizedBox(height: 12),
              _RangeSelector(
                selectedDays: viewModel.selectedRangeDays,
                onChanged: (days) => viewModel.setRangeDays(days),
              ),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _InlineFeedback(
                    text: viewModel.errorMessage!,
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error,
                    background: AppColors.tertiaryBg,
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: TabBar(
                  labelColor: AppColors.buttonPrimaryText,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicator: BoxDecoration(
                    color: AppColors.buttonPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: AppColors.surfaceLow,
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'Sesiones'),
                    Tab(text: 'Pensamientos'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: [
                    _SessionsTab(viewModel: viewModel),
                    _ThoughtsTab(viewModel: viewModel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedDays, required this.onChanged});

  final int selectedDays;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<int>(
            value: 7,
            icon: Icon(Icons.calendar_view_week_rounded),
            label: Text('7 días'),
          ),
          ButtonSegment<int>(
            value: 30,
            icon: Icon(Icons.calendar_month_rounded),
            label: Text('30 días'),
          ),
        ],
        selected: {selectedDays},
        onSelectionChanged: (selection) {
          if (selection.isEmpty) return;
          onChanged(selection.first);
        },
      ),
    );
  }
}

class _ProgressMetricsCard extends StatelessWidget {
  const _ProgressMetricsCard({
    required this.metrics,
    required this.selectedRangeDays,
  });

  final ProgressMetrics metrics;
  final int selectedRangeDays;

  @override
  Widget build(BuildContext context) {
    final frequencyProgress = selectedRangeDays <= 0
        ? 0.0
        : (metrics.activeDaysInRange / selectedRangeDays).clamp(0.0, 1.0);
    final weeklyProgress = metrics.weeklyTargetDays <= 0
        ? 0.0
        : (metrics.weeklyActiveDays / metrics.weeklyTargetDays).clamp(0.0, 1.0);
    final sessionsProgress = selectedRangeDays <= 0
        ? 0.0
        : (metrics.completedSessionsInRange / selectedRangeDays).clamp(
            0.0,
            1.0,
          );
    final hasPerceptionData = metrics.assessableSessions > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas iniciales',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _MetricProgressRow(
            icon: Icons.calendar_today_outlined,
            title: 'Frecuencia de uso',
            value:
                '${metrics.activeDaysInRange} de $selectedRangeDays días activos',
            progress: frequencyProgress,
            color: AppColors.lavender,
          ),
          const SizedBox(height: 12),
          _MetricProgressRow(
            icon: Icons.task_alt_rounded,
            title: 'Sesiones completadas',
            value: '${metrics.completedSessionsInRange}',
            progress: sessionsProgress,
            color: AppColors.mint,
          ),
          const SizedBox(height: 12),
          _MetricProgressRow(
            icon: Icons.local_fire_department_outlined,
            title: 'Constancia semanal',
            value: '${metrics.weeklyActiveDays}/${metrics.weeklyTargetDays}',
            progress: weeklyProgress,
            color: AppColors.tertiaryOnContainer,
          ),
          const SizedBox(height: 12),
          if (hasPerceptionData)
            _MetricProgressRow(
              icon: Icons.psychology_alt_outlined,
              title: 'Percepción general',
              value:
                  '${(metrics.improvementRate * 100).round()}% de sesiones con mejora',
              progress: metrics.improvementRate.clamp(0.0, 1.0),
              color: AppColors.mint,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_alt_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Percepción general: sin datos suficientes',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricProgressRow extends StatelessWidget {
  const _MetricProgressRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab({required this.viewModel});

  final PatientHistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final emotionsBySessionId = <String, HistoryEmotionItem>{};
    for (final emotion in viewModel.emotions) {
      final sessionId = emotion.sessionId;
      if (sessionId == null || sessionId.isEmpty) continue;
      emotionsBySessionId[sessionId] = emotion;
    }

    return _HistoryTabBody(
      isLoading: viewModel.isLoading,
      errorMessage: viewModel.errorMessage,
      isEmpty: viewModel.sessions.isEmpty,
      emptyMessage:
          'No hay sesiones registradas en este rango. Completa una actividad desde Tareas para verla aquí.',
      onRefresh: () => viewModel.loadHistory(force: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: viewModel.sessions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final session = viewModel.sessions[index];
          return _SessionCard(
            session: session,
            emotion: emotionsBySessionId[session.id],
          );
        },
      ),
    );
  }
}

class _ThoughtsTab extends StatelessWidget {
  const _ThoughtsTab({required this.viewModel});

  final PatientHistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _HistoryTabBody(
      isLoading: viewModel.isLoading,
      errorMessage: viewModel.errorMessage,
      isEmpty: viewModel.thoughts.isEmpty,
      emptyMessage:
          'No hay pensamientos registrados en este rango. Puedes escribirlos desde Home o Tareas.',
      onRefresh: () => viewModel.loadHistory(force: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: viewModel.thoughts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final thought = viewModel.thoughts[index];
          return _ThoughtCard(thought: thought);
        },
      ),
    );
  }
}

class _HistoryTabBody extends StatelessWidget {
  const _HistoryTabBody({
    required this.isLoading,
    required this.errorMessage,
    required this.isEmpty,
    required this.emptyMessage,
    required this.onRefresh,
    required this.child,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading && isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.mint));
    }

    if (errorMessage != null && isEmpty) {
      return RefreshIndicator(
        color: AppColors.mint,
        backgroundColor: AppColors.surface,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _InlineFeedback(
              text: errorMessage!,
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              background: AppColors.tertiaryBg,
            ),
          ],
        ),
      );
    }

    if (isEmpty) {
      return RefreshIndicator(
        color: AppColors.mint,
        backgroundColor: AppColors.surface,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [_EmptyState(message: emptyMessage)],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.mint,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: child,
        ),
        if (errorMessage != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: _InlineFeedback(
              text: errorMessage!,
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              background: AppColors.tertiaryBg,
            ),
          ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.emotion});

  final HistorySessionItem session;
  final HistoryEmotionItem? emotion;

  @override
  Widget build(BuildContext context) {
    final dateText = _formatLongDate(session.startedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.routineTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _SessionStatusChip(status: session.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dateText,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _AssignmentContextChip(contextValue: session.assignmentContext),
          if (emotion != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _SessionEmotionSummary(emotion: emotion!),
          ],
        ],
      ),
    );
  }
}

class _SessionEmotionSummary extends StatelessWidget {
  const _SessionEmotionSummary({required this.emotion});

  final HistoryEmotionItem emotion;

  @override
  Widget build(BuildContext context) {
    final isLikert = emotion.preEmotion == 'likert_scale' || emotion.postEmotion == 'likert_scale';
    if (isLikert) {
      final score = emotion.postIntensity ?? emotion.preIntensity;
      final (emoji, label) = _getLikertDetails(score);
      return _EmotionRow(
        title: 'Autopercepción',
        emotion: '$emoji $label',
        intensity: score,
        accent: AppColors.mint,
        icon: Icons.emoji_emotions_outlined,
        maxScore: 5,
      );
    }

    return Column(
      children: [
        _EmotionRow(
          title: 'Antes',
          emotion: _humanizeEmotion(emotion.preEmotion),
          intensity: emotion.preIntensity,
          accent: AppColors.lavender,
          icon: Icons.wb_twilight_rounded,
        ),
        const SizedBox(height: 8),
        _EmotionRow(
          title: 'Después',
          emotion: emotion.hasPost
              ? _humanizeEmotion(emotion.postEmotion!)
              : 'Sin registro',
          intensity: emotion.postIntensity ?? 0,
          accent: emotion.hasPost ? AppColors.mint : AppColors.textSecondary,
          icon: emotion.hasPost
              ? Icons.wb_sunny_outlined
              : Icons.history_toggle_off_rounded,
          withIntensity: emotion.hasPost,
        ),
      ],
    );
  }

  (String, String) _getLikertDetails(int score) {
    return switch (score) {
      1 => ('😞', 'Muy mal'),
      2 => ('😟', 'Mal'),
      3 => ('😐', 'Regular'),
      4 => ('😊', 'Bien'),
      5 => ('😍', 'Muy bien'),
      _ => ('😐', 'Regular'),
    };
  }
}

class _SessionStatusChip extends StatelessWidget {
  const _SessionStatusChip({required this.status});

  final HistorySessionStatus status;

  @override
  Widget build(BuildContext context) {
    final style = switch (status) {
      HistorySessionStatus.completed => _StatusStyle(
        label: 'Completada',
        icon: Icons.check_circle_outline_rounded,
        background: AppColors.successBg,
        foreground: AppColors.mint,
      ),
      HistorySessionStatus.interrupted => _StatusStyle(
        label: 'Interrumpida',
        icon: Icons.pause_circle_outline_rounded,
        background: AppColors.warningBg,
        foreground: AppColors.lavender,
      ),
      HistorySessionStatus.skipped => _StatusStyle(
        label: 'Omitida',
        icon: Icons.remove_circle_outline_rounded,
        background: AppColors.tertiaryBg,
        foreground: AppColors.tertiaryOnContainer,
      ),
      HistorySessionStatus.unknown => _StatusStyle(
        label: 'Sin estado',
        icon: Icons.help_outline_rounded,
        background: AppColors.surfaceLow,
        foreground: AppColors.textSecondary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.foreground.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.foreground),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: TextStyle(
              color: style.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentContextChip extends StatelessWidget {
  const _AssignmentContextChip({required this.contextValue});

  final String contextValue;

  @override
  Widget build(BuildContext context) {
    final isAssigned = contextValue == 'assigned';
    final label = isAssigned
        ? 'Asignada por psicología'
        : 'Sesión autoiniciada';
    final icon = isAssigned ? Icons.groups_rounded : Icons.self_improvement;
    final color = isAssigned ? AppColors.lavender : AppColors.mint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _humanizeEmotion(String value) {
  if (value == 'likert_scale') return 'Autopercepción';
  if (value.isEmpty) return 'Sin emoción';
  final text = value.replaceAll('_', ' ');
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

class _EmotionRow extends StatelessWidget {
  const _EmotionRow({
    required this.title,
    required this.emotion,
    required this.intensity,
    required this.accent,
    required this.icon,
    this.withIntensity = true,
    this.maxScore = 10,
  });

  final String title;
  final String emotion;
  final int intensity;
  final Color accent;
  final IconData icon;
  final bool withIntensity;
  final int maxScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$title: $emotion',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (withIntensity)
          Text(
            '$intensity/$maxScore',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _ThoughtCard extends StatelessWidget {
  const _ThoughtCard({required this.thought});

  final HistoryThoughtItem thought;

  @override
  Widget build(BuildContext context) {
    final dateText = _formatLongDate(thought.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateText,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            thought.preview,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}

class _InlineFeedback extends StatelessWidget {
  const _InlineFeedback({
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
        border: Border.all(color: color.withValues(alpha: 0.35)),
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

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}

String _formatLongDate(DateTime value) {
  final text = DateFormat(
    "EEEE d 'de' MMMM 'del' y, HH:mm",
    'es',
  ).format(value.toLocal());
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1)}';
}
