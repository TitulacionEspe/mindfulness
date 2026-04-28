import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/tareas_main_hub.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/patient_history_viewmodel.dart';
import 'thought_entries_view.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PatientHistoryViewModel>().loadHomeMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyViewModel = context.watch<PatientHistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'Inicio',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accesos rapidos para tus rutinas de descanso y regulacion emocional.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            _HomeProgressSummaryCard(viewModel: historyViewModel),
            const SizedBox(height: 16),
            _HomeQuickCard(
              icon: Icons.edit_note_rounded,
              title: 'Descarga emocional',
              subtitle: 'Registra pensamientos privados antes de dormir.',
              accent: AppColors.lavender,
              buttonLabel: 'Abrir registro',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ThoughtEntriesView()),
                );
              },
            ),
            const SizedBox(height: 12),
            _HomeQuickCard(
              icon: Icons.task_alt_rounded,
              title: 'Tareas de bienestar',
              subtitle: 'Revisa actividades asignadas y rutinas disponibles.',
              accent: AppColors.mint,
              buttonLabel: 'Ir a Tareas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TareasMainHub(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProgressSummaryCard extends StatelessWidget {
  const _HomeProgressSummaryCard({required this.viewModel});

  final PatientHistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final metrics = viewModel.homeMetrics;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso reciente (7 dias)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (viewModel.isLoadingHomeMetrics)
            Center(child: CircularProgressIndicator(color: AppColors.mint))
          else ...[
            if (viewModel.homeMetricsErrorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.homeMetricsErrorMessage!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: _HomeMetricPill(
                    icon: Icons.calendar_today_outlined,
                    label: 'Frecuencia',
                    value: '${metrics.activeDaysInRange} dias',
                    color: AppColors.lavender,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HomeMetricPill(
                    icon: Icons.task_alt_rounded,
                    label: 'Completadas',
                    value: '${metrics.completedSessionsInRange}',
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HomeMetricPill(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Constancia',
                    value: '${metrics.weeklyActiveDays}/7',
                    color: AppColors.tertiaryOnContainer,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeMetricPill extends StatelessWidget {
  const _HomeMetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeQuickCard extends StatelessWidget {
  const _HomeQuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.buttonPrimaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
