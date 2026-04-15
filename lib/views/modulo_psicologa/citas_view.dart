import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CitasView extends StatelessWidget {
  const CitasView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          "ESTÁS EN: GESTIÓN DE CITAS",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}