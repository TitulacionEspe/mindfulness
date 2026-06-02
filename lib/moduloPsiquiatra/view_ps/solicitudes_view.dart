import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import '../../views/modulo_psicologa/components/professional_navigation_helper.dart';
import '../componets_ps/appointment_request_card.dart';

class SolicitudesView extends StatefulWidget {
  const SolicitudesView({super.key});

  @override
  State<SolicitudesView> createState() => _SolicitudesViewState();
}

class _SolicitudesViewState extends State<SolicitudesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
    });
  }

  void _showProposeDialog(BuildContext context, String appointmentId) {
    DateTime selectedDate = DateTime.now();
    int? selectedHour;
    const int fixedDuration = 60; // Fija a 1 hora
    final vm = context.read<AppointmentsViewModel>();

    String getSlotStatus(int hour, DateTime date) {
      final slotStart = DateTime(date.year, date.month, date.day, hour, 0);
      final slotEnd = slotStart.add(const Duration(minutes: fixedDuration));

      for (var app in vm.allAppointments) {
        if (app.scheduledDate != null &&
            app.durationMinutes != null &&
            app.id != appointmentId) {
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

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final workingHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];

          return AlertDialog(
            title: const Text('Proponer horario'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                          selectedHour = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Horarios disponibles  :( :v h(1h)',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(dialogContext).pop();
                  try {
                    await vm.rejectFromPro(appointmentId);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
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
                        // 1. Ocultar el teclado de inmediato
                        FocusManager.instance.primaryFocus?.unfocus();

                        final scheduled = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedHour!,
                          0,
                        );

                        // 2. Cerrar el diálogo de inmediato
                        Navigator.of(dialogContext).pop();

                        try {
                          await vm.proposeFromPro(
                            appointmentId,
                            scheduled,
                            fixedDuration,
                          );

                          if (!context.mounted) return;

                          // 3. Cerrar la vista de solicitudes
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Propuesta enviada al paciente.'),
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
                child: const Text('Enviar propuesta'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de cita'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Volver al panel',
            onPressed: () =>
                ProfessionalNavigationHelper.returnToHome(context, tabIndex: 3),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.pendingRequests.isEmpty
          ? const Center(child: Text('No tienes solicitudes pendientes.'))
          : ListView.builder(
              itemCount: viewModel.pendingRequests.length,
              itemBuilder: (context, index) {
                final appointment = viewModel.pendingRequests[index];
                return AppointmentRequestCard(
                  appointment: appointment,
                  onTap: () => _showProposeDialog(context, appointment.id!),
                );
              },
            ),
    );
  }
}
