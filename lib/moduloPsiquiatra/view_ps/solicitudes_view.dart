import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
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
    // Cargamos las solicitudes al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
    });
  }

  void _showProposeDialog(BuildContext context, String appointmentId) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedDuration = 45; // Valor por defecto

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Para actualizar el diálogo internamente
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Proponer Horario"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) setDialogState(() => selectedDate = date);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) setDialogState(() => selectedTime = time);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: selectedDuration,
                decoration: const InputDecoration(
                  labelText: "Duración (minutos)",
                ),
                items: [30, 45, 60, 90]
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text("$d min")),
                    )
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedDuration = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final fullDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                await context.read<AppointmentsViewModel>().proposeFromPro(
                  appointmentId,
                  fullDateTime,
                  selectedDuration,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Propuesta enviada al paciente"),
                    ),
                  );
                }
              },
              child: const Text("Enviar Propuesta"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitudes de Cita"),
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.pendingRequests.isEmpty
          ? const Center(child: Text("No tienes solicitudes pendientes"))
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
