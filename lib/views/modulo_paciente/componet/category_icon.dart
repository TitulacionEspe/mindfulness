import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/routine_model.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 44});

  final RoutineCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = styleForCategory(category);
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

class CategoryIconStyle {
  const CategoryIconStyle({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
}

CategoryIconStyle styleForCategory(RoutineCategory category) {
  return switch (category) {
    RoutineCategory.breathing => CategoryIconStyle(
      icon: Icons.air_rounded,
      background: AppColors.successBg,
      iconColor: AppColors.mint,
    ),
    RoutineCategory.relaxation => CategoryIconStyle(
      icon: Icons.spa_outlined,
      background: AppColors.warningBg,
      iconColor: AppColors.lavender,
    ),
    RoutineCategory.sleepInduction => CategoryIconStyle(
      icon: Icons.dark_mode_outlined,
      background: AppColors.secondaryContainer,
      iconColor: AppColors.mint,
    ),
    RoutineCategory.soundscape => CategoryIconStyle(
      icon: Icons.music_note_rounded,
      background: AppColors.warningBg,
      iconColor: AppColors.lavender,
    ),
    RoutineCategory.terapiaSonido => CategoryIconStyle(
      icon: Icons.graphic_eq_rounded,
      background: AppColors.tertiaryBg,
      iconColor: AppColors.tertiary,
    ),
    RoutineCategory.all => CategoryIconStyle(
      icon: Icons.checklist_rounded,
      background: AppColors.surfaceHigh,
      iconColor: AppColors.textSecondary,
    ),
  };
}
