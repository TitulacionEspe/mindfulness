import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../moduloCitas/model/appointment_model.dart';

class AppointmentCardItem extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onPropose;
  final VoidCallback onComplete;

  const AppointmentCardItem({
    super.key,
    required this.appointment,
    required this.onPropose,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = appointment.scheduledDate == null
        ? 'Sin fecha propuesta'
        : DateFormat(
            'EEEE dd MMM, HH:mm',
            'es',
          ).format(appointment.scheduledDate!);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surfaceLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(status: appointment.status),
                const Spacer(),
                Text(
                  appointment.type,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.patientName ?? 'Paciente Desconocido',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              appointment.motive,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _capitalize(dateLabel),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment.durationMinutes != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.timelapse_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${appointment.durationMinutes} min',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
            if (appointment.professionalNotes != null &&
                appointment.professionalNotes!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Notas: ${appointment.professionalNotes}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 10),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (appointment.id == null) return const SizedBox.shrink();

    if (appointment.status == 'SOLICITADA') {
      return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: onPropose,
          icon: const Icon(Icons.event_available_outlined),
          label: const Text('Proponer horario'),
        ),
      );
    }

    if (appointment.status == 'CONFIRMADA') {
      return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: onComplete,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Finalizar sesión'),
        ),
      );
    }

    if (appointment.status == 'PROPUESTA') {
      return Text(
        'Esperando confirmación del paciente.',
        style: TextStyle(color: AppColors.lavender, fontSize: 13),
      );
    }

    return const SizedBox.shrink();
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (background, foreground, text) = switch (status) {
      'SOLICITADA' => (AppColors.warningBg, AppColors.lavender, 'Solicitada'),
      'PROPUESTA' => (AppColors.tertiaryBg, AppColors.tertiary, 'Propuesta'),
      'CONFIRMADA' => (AppColors.successBg, AppColors.mint, 'Confirmada'),
      'COMPLETADA' => (
        AppColors.surfaceHighest,
        AppColors.textPrimary,
        'Completada',
      ),
      _ => (AppColors.surfaceHighest, AppColors.textSecondary, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
