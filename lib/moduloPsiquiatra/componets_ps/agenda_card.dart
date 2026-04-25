import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

import '../../moduloCitas/model/appointment_model.dart';

class AgendaCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onComplete;

  const AgendaCard({
    super.key,
    required this.appointment,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: AppColors.mint),
                SizedBox(width: 8),
                Text(
                  "CONFIRMADA",
                  style: TextStyle(
                    color: AppColors.mint,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                Text(
                  appointment.type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lavender,
                  ),
                ),
              ],
            ),
            Divider(height: 25),
            Text(
              "Motivo: ${appointment.motive}",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 5),
                Text(
                  DateFormat(
                    'dd/MM/yyyy - hh:mm a',
                  ).format(appointment.scheduledDate!),
                ),
                SizedBox(width: 15),
                Icon(
                  Icons.timer_sharp,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text("${appointment.durationMinutes} min"),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.surfaceLowest,
                ),
                label: Text(
                  "Finalizar Sesión",
                  style: TextStyle(color: AppColors.surfaceLowest),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
