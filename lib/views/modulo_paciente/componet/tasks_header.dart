import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../reminders_view.dart';

class TasksHeader extends StatelessWidget {
  const TasksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tus actividades',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Asignadas por tu psicóloga y rutinas para tu descanso nocturno.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 46,
            height: 46,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RemindersView()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.surfaceLowest,
                side: BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.lavender,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
