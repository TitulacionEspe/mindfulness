import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CategoryFilters extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const Map<String, String> categoryLabels = {
    'Todas': 'Todas',
    'breathing': 'Respiración',
    'relaxation': 'Relajación',
    'sleep_induction': 'Sueño',
    'soundscape': 'Paisajes',
    'terapia_sonido': 'Terapia',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'FILTRO DE CATEGORÍAS',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...categoryLabels.entries.map((entry) {
                final isActive = selectedCategory == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => onCategorySelected(entry.key),
                    child: _buildChip(entry.value, isActive),
                  ),
                );
              }),
              _buildCreateButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.mint : AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.mint
              : AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.mint.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.buttonPrimaryText : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.add_rounded,
        color: AppColors.buttonPrimaryText,
        size: 22,
      ),
    );
  }
}
