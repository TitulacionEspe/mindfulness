import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/routine_model.dart';
import '../../../../moduloPsiquiatra/model_ps/routine_model.dart';
import '../routine_preview_screen.dart';

class ActivityItemCard extends StatelessWidget {
  final RoutineTemplate routine;

  const ActivityItemCard({super.key, required this.routine});

  IconData get _icon {
    final category = RoutineCategoryX.fromValue(routine.category);
    return switch (category) {
      RoutineCategory.breathing => Icons.air_rounded,
      RoutineCategory.relaxation => Icons.spa_rounded,
      RoutineCategory.sleepInduction => Icons.dark_mode_rounded,
      RoutineCategory.soundscape => Icons.graphic_eq_rounded,
      RoutineCategory.terapiaSonido => Icons.music_note_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }

  String get _durationLabel {
    final minutes = (routine.durationSeconds / 60).ceil();
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final category = RoutineCategoryX.fromValue(routine.category);

    final categoryColor = switch (category) {
      RoutineCategory.breathing => AppColors.mint,
      RoutineCategory.relaxation => AppColors.lavender,
      RoutineCategory.sleepInduction => AppColors.secondaryContainer,
      RoutineCategory.soundscape => AppColors.tertiary,
      RoutineCategory.terapiaSonido => AppColors.error,
      _ => AppColors.outline,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.outlineVariant.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoutinePreviewScreen(routine: routine),
                ),
              );
            },
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Indicador lateral de color
                  Container(width: 6, color: categoryColor),
                  const SizedBox(width: 16),

                  // Icono con contenedor estilizado
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(_icon, color: categoryColor, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.title,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category.label.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Badges de información
                          Row(
                            children: [
                              _buildInfoBadge(
                                icon: Icons.timer_rounded,
                                label: _durationLabel,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              _buildInfoBadge(
                                icon: Icons.remove_red_eye_rounded,
                                label: "Vista",
                                color: AppColors.lavender,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botón de acción minimalista
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
