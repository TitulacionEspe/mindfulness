import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientSearchBar extends StatelessWidget {
  const PatientSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: AppColors.surfaceLowest),
      decoration: InputDecoration(
        hintText: "Busca el nombre del paciente",
        hintStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
