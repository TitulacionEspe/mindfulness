import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/models/assigned_activity_model.dart';
import 'package:mindfulness_app/models/routine_model.dart';
import 'package:mindfulness_app/viewmodels/viewmodels_psicologa/assignments_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../models/model_psicologa/assignment_group_model.dart';

class Asignarconten extends StatefulWidget {
  const Asignarconten({super.key});

  @override
  State<Asignarconten> createState() => _AsignarcontenState();
}

class _AsignarcontenState extends State<Asignarconten> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentsViewModel>().loadAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AssignmentsViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Asignaciones de alumnos',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        color: AppColors.mint,
        child: Column(
          children: [
            _buildSearchBar(viewModel),
            Expanded(child: _buildContent(viewModel, textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AssignmentsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.outlineVariant.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => viewModel.updateSearch(v),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre del alumno...',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.mint),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AssignmentsViewModel viewModel, TextTheme textTheme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    if (viewModel.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_ind_outlined,
              size: 64,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              "No hay asignaciones registradas",
              style: textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: viewModel.groups.length,
      itemBuilder: (context, index) {
        final group = viewModel.groups[index];
        return _PatientAssignmentCard(group: group);
      },
    );
  }
}

class _PatientAssignmentCard extends StatelessWidget {
  final PatientAssignmentGroup group;

  const _PatientAssignmentCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.outlineVariant.withValues(alpha: 0.16),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                group.patientName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          title: Text(
            group.patientName,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Row(
            children: [
              Text(
                "${group.completedTasks}/${group.totalTasks} completadas",
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: group.progress,
                    backgroundColor: AppColors.surfaceLow,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      group.progress == 1.0
                          ? AppColors.mint
                          : AppColors.lavender,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  const Divider(),
                  ...group.assignments.map(
                    (assignment) => _AssignmentItem(assignment: assignment),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentItem extends StatelessWidget {
  final PatientAssignmentDetail assignment;

  const _AssignmentItem({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompleted = assignment.status == AssignmentStatus.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.mint.withValues(alpha: 0.1)
                  : AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
              size: 18,
              color: isCompleted ? AppColors.mint : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.routineTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  assignment.category.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${assignment.assignedAt.day}/${assignment.assignedAt.month}",
            style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
