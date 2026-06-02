import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../moduloCitas/model/appointment_model.dart';
import '../../../../moduloCitas/viewmodels/appointments_viewmodel.dart';

class CitasDialogs {
  static Future<void> showProposeDialog({
    required BuildContext context,
    required Appointment appointment,
    required DateTime initialDate,
    required Function(DateTime) onSuccess,
  }) async {
    DateTime selectedDate = initialDate;
    int? selectedHour;
    const int fixedDuration = 60; // Fija a 1 hora
    final vm = context.read<AppointmentsViewModel>();

    String getSlotStatus(int hour, DateTime date) {
      final slotStart = DateTime(date.year, date.month, date.day, hour, 0);
      final slotEnd = slotStart.add(const Duration(minutes: fixedDuration));

      for (var app in vm.allAppointments) {
        if (app.scheduledDate != null &&
            app.durationMinutes != null &&
            app.id != appointment.id) {
          final existingUtc = app.scheduledDate!;
          final existingStart = existingUtc.toLocal();
          final existingEnd = existingStart.add(
            Duration(minutes: app.durationMinutes!),
          );
          if (slotStart.isBefore(existingEnd) &&
              slotEnd.isAfter(existingStart)) {
            if (app.status == 'CONFIRMADA') return 'occupied';
            if (app.status == 'PROPUESTA') return 'proposed';
          }
        }
      }
      return 'free';
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final workingHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];

            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Proponer horario',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOptionTile(
                      icon: Icons.calendar_month_outlined,
                      label: DateFormat('dd/MM/yyyy').format(selectedDate),
                      color: const Color(0xFFB2EBF2),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                            selectedHour = null; // Resetear hora al cambiar día
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Horarios disponibles ;) (1h)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: workingHours.map((hour) {
                        final status = getSlotStatus(hour, selectedDate);
                        final isSelected = selectedHour == hour;
                        final isFree = status == 'free';
                        final isProposed = status == 'proposed';

                        return InkWell(
                          onTap: isFree
                              ? () => setDialogState(() => selectedHour = hour)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isFree
                                  ? (isSelected
                                        ? AppColors.mint
                                        : AppColors.successBg)
                                  : AppColors.error.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFree
                                    ? AppColors.mint
                                    : AppColors.error.withValues(alpha: 0.60),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                    color: isFree
                                        ? (isSelected
                                              ? AppColors.surfaceLowest
                                              : AppColors.textPrimary)
                                        : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    decoration: isFree
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough,
                                  ),
                                ),
                                if (isProposed)
                                  Text(
                                    'Propuesta',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(dialogContext);
                    try {
                      await vm.rejectFromPro(appointment.id!);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solicitud rechazada.')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al rechazar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Rechazar'),
                ),
                ElevatedButton(
                  onPressed: selectedHour == null
                      ? null
                      : () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final scheduled = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedHour!,
                            0,
                          );
                          Navigator.pop(dialogContext);
                          try {
                            await vm.proposeFromPro(
                              appointment.id!,
                              scheduled,
                              fixedDuration,
                            );
                            onSuccess(selectedDate);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Horario propuesto correctamente.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            final msg = e.toString().replaceAll(
                              'Exception: ',
                              '',
                            );
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cruce de horarios'),
                                content: Text(msg),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Entendido'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB2EBF2),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Enviar propuesta'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> showCompleteDialog({
    required BuildContext context,
    required Appointment appointment,
  }) async {
    final notesController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Finalizar sesión',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Añade notas importantes sobre el progreso del paciente.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe aquí tus notas...',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Volver',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final notes = notesController.text.trim();
                Navigator.pop(dialogContext);
                try {
                  await context.read<AppointmentsViewModel>().markAsDone(
                    appointment.id!,
                    notes,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cita finalizada y guardada.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al finalizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8E6C9), // Menta suave
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Guardar y Cerrar'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.withValues(alpha: 0.8), size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: color.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
