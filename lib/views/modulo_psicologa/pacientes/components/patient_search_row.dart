import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/viewmodels_psicologa/patients_viewmodel.dart';

class PatientSearchRow extends StatelessWidget {
  const PatientSearchRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón de Filtro Circular
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.tune, color: AppColors.textPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        // Buscador expandido
        Expanded(
          child: TextField(
            onChanged: (value) {
              context.read<PatientsViewModel>().updateSearchQuery(value);
            },
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
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
