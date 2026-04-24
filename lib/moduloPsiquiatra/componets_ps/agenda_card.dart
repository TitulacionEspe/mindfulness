import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, size: 12, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "CONFIRMADA",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  appointment.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Text(
              "Motivo: ${appointment.motive}",
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  DateFormat(
                    'dd/MM/yyyy - hh:mm a',
                  ).format(appointment.scheduledDate!),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.timer_sharp, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text("${appointment.durationMinutes} min"),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  "Finalizar Sesión",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
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
