import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/routines_viewmodel.dart';
import 'category_routines_view.dart';
import 'componet/assigned_activity_card.dart';
import 'componet/category_filters.dart';
import 'componet/category_icon.dart';
import 'componet/emotional_dump_card.dart';
import 'componet/library_routine_card.dart';
import 'componet/quick_exercises_section.dart';
import 'componet/section_title.dart';
import 'componet/tasks_header.dart';
import 'routine_detail_view.dart';
import 'thought_entries_view.dart';

class RoutinesLibraryView extends StatefulWidget {
  const RoutinesLibraryView({super.key});

  @override
  State<RoutinesLibraryView> createState() => _RoutinesLibraryViewState();
}

class _RoutinesLibraryViewState extends State<RoutinesLibraryView> {
  String? _lastUserId;
  bool _showAsGrid = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _lastUserId = context.read<AuthViewModel>().currentUser?.id;
      context.read<RoutinesViewModel>().loadRoutines();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authViewModel = context.watch<AuthViewModel>();
    final currentUserId = authViewModel.currentUser?.id;

    if (currentUserId != null && currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<RoutinesViewModel>().loadRoutines(force: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoutinesViewModel>();
    final pendingActivities = viewModel.pendingAssignedActivities;

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
              const SliverToBoxAdapter(child: TasksHeader()),
              SliverToBoxAdapter(
                child: EmotionalDumpCard(
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
                child: SectionTitle(title: 'Mis actividades asignadas'),
              ),
              if (viewModel.isLoading && pendingActivities.isEmpty)
                const SliverToBoxAdapter(child: _LoadingBlock())
              else if (pendingActivities.isEmpty)
                const SliverToBoxAdapter(child: _EmptyAssignedState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      final activity = pendingActivities[index];
                      return AssignedActivityCard(
                        activity: activity,
                        onTap: () => _openRoutine(
                          context,
                          activity.routine,
                          assignmentId: activity.id,
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: pendingActivities.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              //const SliverToBoxAdapter(
              // child: SectionTitle(title: 'Cuestionario inicial'),
              //),
              //const SliverToBoxAdapter(child: QuestionnaireCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: 'Biblioteca de rutinas',
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mint.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          _showAsGrid
                              ? Icons.view_list_rounded
                              : Icons.grid_view_rounded,
                          key: ValueKey(_showAsGrid),
                          color: AppColors.mint,
                          size: 26,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showAsGrid = !_showAsGrid;
                        });
                      },
                      tooltip: _showAsGrid
                          ? 'Ver como lista'
                          : 'Ver como categorías',
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (!_showAsGrid)
                SliverToBoxAdapter(
                  child: CategoryFilters(
                    selectedCategory: viewModel.selectedCategory,
                    onSelected: viewModel.selectCategory,
                  ),
                ),
              if (viewModel.isLoading && viewModel.routines.isEmpty)
                const SliverToBoxAdapter(child: _LoadingBlock())
              else if (_showAsGrid)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final categories = RoutineCategory.values
                          .where((c) => c != RoutineCategory.all)
                          .toList();
                      final category = categories[index];
                      final count = viewModel.routines
                          .where(
                            (r) =>
                                r.category == category && r.createdBy == null,
                          )
                          .length;

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CategoryRoutinesView(category: category),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CategoryIcon(category: category, size: 40),
                              const Spacer(),
                              Text(
                                category.label,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$count rutinas',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: RoutineCategory.values.length - 1),
                  ),
                )
              else if (viewModel.filteredRoutines.isEmpty)
                const SliverToBoxAdapter(child: _EmptyLibraryState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      final routine = viewModel.filteredRoutines[index];
                      return LibraryRoutineCard(
                        routine: routine,
                        onTap: () => _openRoutine(context, routine),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: viewModel.filteredRoutines.length,
                  ),
                ),

              //nuevo catr
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 30.0,
                  ), // Un pequeño espacio al final
                  child: QuickExercisesSection(),
                ),
              ),

              //fin nuevo card
            ],
          ),
        ),
      ),
    );
  }

  void _openRoutine(
    BuildContext context,
    RoutineModel routine, {
    String? assignmentId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RoutineDetailView(routine: routine, assignmentId: assignmentId),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets de estado locales
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
        'Aún no tienes actividades asignadas por tu psicóloga. Esta sección queda lista para integrarse con asignaciones reales.',
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
