import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routines_viewmodel.dart';
import 'componet/library_routine_card.dart';
import 'routine_detail_view.dart';

class CategoryRoutinesView extends StatelessWidget {
  const CategoryRoutinesView({super.key, required this.category});

  final RoutineCategory category;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoutinesViewModel>();

    // Filter the routines locally based on the passed category
    final categoryRoutines = viewModel.routines
        .where(
          (routine) =>
              routine.category == category && routine.createdBy == null,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          category.label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: categoryRoutines.isEmpty
            ? Center(
                child: Text(
                  'No hay rutinas disponibles en esta categoría.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemBuilder: (context, index) {
                  final routine = categoryRoutines[index];
                  return LibraryRoutineCard(
                    routine: routine,
                    onTap: () => _openRoutine(context, routine),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemCount: categoryRoutines.length,
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
