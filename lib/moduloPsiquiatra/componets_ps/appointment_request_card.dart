import 'package:flutter/material.dart';

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(80, 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Gestionar",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // CUERPO: MOTIVO
            const Text(
              "Motivo de la consulta:",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appointment.motive,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.3,
              ),
            ),

            const Divider(height: 24),

            // PIE: ID / REFERENCIA
            Text(
              "ID de solicitud: ${appointment.id?.substring(0, 8) ?? 'Pendiente'}",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
