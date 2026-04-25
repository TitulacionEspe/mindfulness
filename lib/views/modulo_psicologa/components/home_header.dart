import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola Buenos Dias!",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              userName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "\"Un dia a la vez...\"",
              style: TextStyle(
                color: AppColors.lavender,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Icon(
              Icons.notifications_none,
              color: AppColors.textPrimary,
              size: 30,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
