import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/assigned_activity_model.dart';
import '../../../models/routine_model.dart';
import 'category_icon.dart';

class AssignedActivityCard extends StatelessWidget {
  const AssignedActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

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
              CategoryIcon(category: routine.category, size: 46),
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
                            routine.displayTitle,
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
                        AssignedStatusPill(
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

class AssignedStatusPill extends StatelessWidget {
  const AssignedStatusPill({
    super.key,
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

class _StatusStyle {
  const _StatusStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
