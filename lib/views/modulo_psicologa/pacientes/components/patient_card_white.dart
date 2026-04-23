import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientCardWhite extends StatelessWidget {
  final String name;
  final String task;
  final double progress;

  const PatientCardWhite({
    super.key,
    required this.name,
    required this.task,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.background.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a'),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  task,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.navBorder,
                  color: AppColors.mint,
                  minHeight: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Icono de Configuración/Más
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {}, // Aquí iría la configuración del paciente
          ),
        ],
      ),
    );
  }
}
