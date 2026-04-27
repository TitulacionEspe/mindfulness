import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/assigned_activity_model.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routines_viewmodel.dart';
import 'routine_detail_view.dart';
import 'thought_entries_view.dart';

class RoutinesLibraryView extends StatefulWidget {
  const RoutinesLibraryView({super.key});

  @override
  State<RoutinesLibraryView> createState() => _RoutinesLibraryViewState();
}

class _RoutinesLibraryViewState extends State<RoutinesLibraryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RoutinesViewModel>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoutinesViewModel>();
    final assignedActivities = viewModel.assignedActivities;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.mint,
          backgroundColor: AppColors.surface,
          onRefresh: () => viewModel.loadRoutines(force: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _TasksHeader()),
              SliverToBoxAdapter(
                child: _EmotionalDumpCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ThoughtEntriesView(),
                      ),
                    );
                  },
                ),
              ),
              if (viewModel.errorMessage != null)
                SliverToBoxAdapter(
                  child: _InlineMessage(message: viewModel.errorMessage!),
                ),
              const SliverToBoxAdapter(
                child: _SectionTitle(title: 'Mis actividades asignadas'),
              ),
              if (viewModel.isLoading && assignedActivities.isEmpty)
                const SliverToBoxAdapter(child: _LoadingBlock())
              else if (assignedActivities.isEmpty)
                const SliverToBoxAdapter(child: _EmptyAssignedState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      final activity = assignedActivities[index];
                      return _AssignedActivityCard(
                        activity: activity,
                        onTap: () => _openRoutine(context, activity.routine),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: assignedActivities.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              const SliverToBoxAdapter(
                child: _SectionTitle(title: 'Cuestionario inicial'),
              ),
              const SliverToBoxAdapter(child: _QuestionnaireCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              const SliverToBoxAdapter(
                child: _SectionTitle(title: 'Biblioteca de rutinas'),
              ),
              SliverToBoxAdapter(
                child: _CategoryFilters(
                  selectedCategory: viewModel.selectedCategory,
                  onSelected: viewModel.selectCategory,
                ),
              ),
              if (viewModel.isLoading)
                const SliverToBoxAdapter(child: _LoadingBlock())
              else if (viewModel.filteredRoutines.isEmpty)
                const SliverToBoxAdapter(child: _EmptyLibraryState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      final routine = viewModel.filteredRoutines[index];
                      return _LibraryRoutineCard(
                        routine: routine,
                        onTap: () => _openRoutine(context, routine),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: viewModel.filteredRoutines.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRoutine(BuildContext context, RoutineModel routine) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoutineDetailView(routine: routine)),
    );
  }
}

// ─────────────────────────────────────────────
// Modelo de estilo de ícono por categoría
// ─────────────────────────────────────────────

class _CategoryIconStyle {
  const _CategoryIconStyle({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
}

/// Devuelve el estilo visual (ícono + colores) según la categoría.
/// Inspirado en la referencia: fondos pastel con ícono del mismo tono.
_CategoryIconStyle _styleForCategory(RoutineCategory category) {
  return switch (category) {
    RoutineCategory.breathing => const _CategoryIconStyle(
      icon: Icons.air_rounded,
      background: Color(0xFFCCF0EC), // teal claro
      iconColor: Color(0xFF006B63), // teal oscuro (mint)
    ),
    RoutineCategory.relaxation => const _CategoryIconStyle(
      icon: Icons.spa_outlined,
      background: Color(0xFFD6EAD0), // verde claro
      iconColor: Color(0xFF2E7D32), // verde oscuro
    ),
    RoutineCategory.sleepInduction => const _CategoryIconStyle(
      icon: Icons.dark_mode_outlined,
      background: Color(0xFFD5E8F5), // azul claro
      iconColor: Color(0xFF1565C0), // azul oscuro
    ),
    RoutineCategory.soundscape => const _CategoryIconStyle(
      icon: Icons.music_note_rounded,
      background: Color(0xFFE8D5F5), // morado claro
      iconColor: Color(0xFF6A1B9A), // morado oscuro
    ),
    RoutineCategory.all => const _CategoryIconStyle(
      icon: Icons.checklist_rounded,
      background: Color(0xFFFFF3CC), // amarillo claro
      iconColor: Color(0xFFF57F17), // amarillo oscuro
    ),
  };
}

// ─────────────────────────────────────────────
// Widget reutilizable: ícono de categoría con color
// ─────────────────────────────────────────────

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category, this.size = 44});

  final RoutineCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = _styleForCategory(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Icon(style.icon, color: style.iconColor, size: size * 0.50),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets de la vista
// ─────────────────────────────────────────────

class _TasksHeader extends StatelessWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tus actividades',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Asignadas por tu psicologa y rutinas para tu descanso nocturno.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 46,
            height: 46,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.surfaceLowest,
                side: BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.lavender,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionalDumpCard extends StatelessWidget {
  const _EmotionalDumpCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFF57F17),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Descarga emocional',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Registra pensamientos privados para reducir rumiacion nocturna.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Abrir registro privado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonPrimaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedStatusPill extends StatelessWidget {
  const _AssignedStatusPill({
    required this.status,
    required this.background,
    required this.foreground,
  });

  final String status;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AssignedActivityCard extends StatelessWidget {
  const _AssignedActivityCard({required this.activity, required this.onTap});

  final AssignedActivityModel activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _styleForStatus(activity.status);
    final dueText = _formatDue(activity.targetCompletion);
    final routine = activity.routine;

    return Material(
      color: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ícono con color de categoría ──
              _CategoryIcon(category: routine.category, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            routine.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              decoration:
                                  activity.status == AssignmentStatus.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _AssignedStatusPill(
                          status: activity.status.label,
                          background: style.background,
                          foreground: style.foreground,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          routine.durationLabel,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '|',
                          style: TextStyle(
                            color: AppColors.navBorder,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          routine.category.label,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (dueText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        dueText,
                        style: TextStyle(
                          color: style.foreground,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusStyle _styleForStatus(AssignmentStatus status) {
    return switch (status) {
      AssignmentStatus.pending => _StatusStyle(
        background: AppColors.warningBg,
        foreground: AppColors.lavender,
      ),
      AssignmentStatus.completed => _StatusStyle(
        background: AppColors.successBg,
        foreground: AppColors.mint,
      ),
      AssignmentStatus.expired => _StatusStyle(
        background: AppColors.tertiaryBg,
        foreground: AppColors.tertiaryOnContainer,
      ),
    };
  }

  String? _formatDue(DateTime? dueDate) {
    if (dueDate == null) return null;
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');
    final year = dueDate.year.toString();
    return 'Fecha objetivo: $day/$month/$year';
  }
}

class _QuestionnaireCard extends StatelessWidget {
  const _QuestionnaireCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completa el formulario para que la psicologa asigne rutinas personalizadas.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surface,
                    content: Text(
                      'Flujo de cuestionario disponible en el siguiente ticket.',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text(
                'Iniciar cuestionario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonPrimaryText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selectedCategory,
    required this.onSelected,
  });

  final RoutineCategory selectedCategory;
  final ValueChanged<RoutineCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = RoutineCategory.values;

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == selectedCategory;
          final style = _styleForCategory(category);
          return ChoiceChip(
            label: Text(category.label),
            selected: selected,
            onSelected: (_) => onSelected(category),
            avatar: Icon(
              style.icon,
              size: 16,
              color: selected ? AppColors.buttonPrimaryText : style.iconColor,
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            showCheckmark: false,
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }
}

class _LibraryRoutineCard extends StatelessWidget {
  const _LibraryRoutineCard({required this.routine, required this.onTap});

  final RoutineModel routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Ícono con color de categoría ──
              _CategoryIcon(category: routine.category, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${routine.durationLabel} | ${routine.category.label}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.lavender,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets de estado
// ─────────────────────────────────────────────

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: AppColors.lavender,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator(color: AppColors.mint)),
    );
  }
}

class _EmptyAssignedState extends StatelessWidget {
  const _EmptyAssignedState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        'Aun no tienes actividades asignadas por tu psicologa. Esta seccion queda lista para integrarse con asignaciones reales.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          height: 1.35,
        ),
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      child: Text(
        'No hay rutinas para el filtro seleccionado.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────

class _StatusStyle {
  const _StatusStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
