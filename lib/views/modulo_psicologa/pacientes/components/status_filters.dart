import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/viewmodels_psicologa/patients_viewmodel.dart';

class StatusFilters extends StatelessWidget {
  const StatusFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PatientsViewModel>();

    return Row(
      children: [
        _filterChip(context, "Todos", viewModel.statusFilter == 'all', 'all'),
        const SizedBox(width: 10),
        _filterChip(context, "Realizados", viewModel.statusFilter == 'completed', 'completed'),
        const SizedBox(width: 10),
        _filterChip(context, "No realizados", viewModel.statusFilter == 'pending', 'pending'),
      ],
    );
  }

  Widget _filterChip(BuildContext context, String label, bool isSelected, String value) {
    return GestureDetector(
      onTap: () {
        context.read<PatientsViewModel>().setStatusFilter(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.buttonPrimaryText : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
