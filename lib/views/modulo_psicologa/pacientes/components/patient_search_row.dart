import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientSearchRow extends StatelessWidget {
  const PatientSearchRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón de Filtro Circular
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.tune, color: AppColors.textPrimary, size: 20),
        ),
        SizedBox(width: 12),
        // Buscador expandido
        Expanded(
          child: TextField(
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "Busca el nombre del paciente",
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              suffixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  30,
                ), // Muy redondeado como la imagen
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
