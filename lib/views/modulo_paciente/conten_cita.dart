import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CitaCont extends StatelessWidget {
  const CitaCont({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Citas', style: TextStyle(color: AppColors.textPrimary)),
    );
  }
}
