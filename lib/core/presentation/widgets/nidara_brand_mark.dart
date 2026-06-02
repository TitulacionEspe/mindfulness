import 'package:flutter/material.dart';

import '../../constants/app_brand.dart';
import '../../theme/app_colors.dart';

class NidaraBrandMark extends StatelessWidget {
  const NidaraBrandMark({
    super.key,
    this.iconSize = 96,
    this.showName = true,
    this.subtitle,
  });

  final double iconSize;
  final bool showName;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppBrand.iconAsset,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          semanticLabel: 'Logotipo de ${AppBrand.name}',
          errorBuilder: (_, _, _) => Icon(
            Icons.nights_stay_rounded,
            size: iconSize * 0.76,
            color: AppColors.mint,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 12),
          Text(
            AppBrand.name,
            style: textTheme.displayLarge?.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
