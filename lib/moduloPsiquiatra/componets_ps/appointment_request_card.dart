import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';

import '../../moduloCitas/model/appointment_model.dart';

class AppointmentRequestCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentRequestCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // CAMBIAMOS ListTile POR UN Column PARA EVITAR ERRORES DE RENDERIZADO
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA: TIPO Y BOTÓN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lavender,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size(80, 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Gestionar",
                    style: TextStyle(
                      color: AppColors.surfaceLowest,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // CUERPO: MOTIVO
            Text(
              "Motivo de la consulta:",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              appointment.motive,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            Divider(height: 24),

            // PIE: ID / REFERENCIA
            Text(
              "ID de solicitud: ${appointment.id?.substring(0, 8) ?? 'Pendiente'}",
              style: TextStyle(
                fontSize: 11,
                color: AppColors.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
