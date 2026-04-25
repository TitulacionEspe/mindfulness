import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StatusFilters extends StatelessWidget {
  const StatusFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _filterChip("Realizados", true),
        SizedBox(width: 10),
        _filterChip("No realizados", false),
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : AppColors.sectionWhite,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
