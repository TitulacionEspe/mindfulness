import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryFilters extends StatelessWidget {
  const CategoryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: TextStyle(
            color: AppColors.surfaceLowest,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8, // Espacio horizontal entre chips
          runSpacing: 10, // Espacio vertical si saltan de línea
          children: [
            _buildChip('Todas', true),
            _buildChip('Sueño', false),
            _buildChip('Respiración', false),
            _buildChip('Audios', false),
            _buildChip('Guías', false),
            _buildChip('Anti-estrés', false),
            _buildCreateButton(), // El botón negro del Figma
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.figmaBlack : AppColors.figmaGrayBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.surfaceLowest : AppColors.figmaBlack,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Crear',
        style: TextStyle(
          color: AppColors.surfaceLowest,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
