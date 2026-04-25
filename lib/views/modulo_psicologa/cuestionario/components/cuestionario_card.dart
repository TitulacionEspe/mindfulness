import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CuestionarioCard extends StatelessWidget {
  final String title;
  final String duration;
  final String questions;
  final VoidCallback onTap;

  const CuestionarioCard({
    super.key,
    required this.title,
    required this.duration,
    required this.questions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: AppColors.mint, size: 16),
                  SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.assignment_outlined,
                    color: AppColors.mint,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    questions,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
