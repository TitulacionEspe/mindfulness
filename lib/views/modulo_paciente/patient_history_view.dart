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
    final summary = viewModel.summary;

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
              _HistorySummaryCard(summary: summary),
              const SizedBox(height: 12),
              _RangeSelector(
                selectedDays: viewModel.selectedRangeDays,
                onChanged: (days) => viewModel.setRangeDays(days),
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
            label: Text('7 dias'),
          ),
          ButtonSegment<int>(
            value: 30,
            icon: Icon(Icons.calendar_month_rounded),
            label: Text('30 dias'),
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

class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({required this.summary});

  final HistorySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              icon: Icons.task_alt_rounded,
              value: '${summary.completedSessions}/${summary.totalSessions}',
              label: 'Sesiones',
              color: AppColors.mint,
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              icon: Icons.psychology_alt_outlined,
              value: '${summary.totalEmotionLogs}',
              label: 'Emociones',
              color: AppColors.lavender,
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              icon: Icons.edit_note_rounded,
              value: '${summary.totalThoughts}',
              label: 'Pensamientos',
              color: AppColors.tertiaryOnContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
          'No hay sesiones registradas en este rango. Completa una actividad desde Tareas para verla aqui.',
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
          title: 'Despues',
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
        ? 'Asignada por psicologia'
        : 'Sesion autoiniciada';
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
  if (value.isEmpty) return 'Sin emocion';
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
  });

  final String title;
  final String emotion;
  final int intensity;
  final Color accent;
  final IconData icon;
  final bool withIntensity;

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
            '$intensity/10',
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
