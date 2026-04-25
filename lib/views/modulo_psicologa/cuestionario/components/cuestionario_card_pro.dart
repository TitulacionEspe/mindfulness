import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CuestionarioCardPro extends StatelessWidget {
  final String statusLabel; // "RESPONDIDO HOY" o "PENDIENTE"
  final String emoji; // "✅" o "⌛"
  final String patientName;
  final String testName;
  final Color headerColor;
  final Color textColor;

  const CuestionarioCardPro({
    super.key,
    required this.statusLabel,
    required this.emoji,
    required this.patientName,
    required this.testName,
    required this.headerColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado de estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(emoji, style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
          // Placeholder de Paciente (Gris)
          Container(
            height: 120,
            width: double.infinity,
            color: AppColors.greyBg,
            child: Center(
              child: Text(
                "Paciente",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          // Información inferior
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  testName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
