import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
