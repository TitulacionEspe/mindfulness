import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:provider/provider.dart';

import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';

class MisCitasView extends StatefulWidget {
  const MisCitasView({super.key});

  @override
  State<MisCitasView> createState() => _MisCitasViewState();
}

class _MisCitasViewState extends State<MisCitasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();
    // Filtramos localmente solo las del paciente (el RLS ya hace el trabajo pesado)
    final citas = viewModel.allAppointments;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "Mis Solicitudes",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : citas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: citas.length,
              itemBuilder: (context, index) {
                final appointment = citas[index];
                return _buildAppointmentCard(context, appointment, viewModel);
              },
            ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    appointment,
    AppointmentsViewModel vm,
  ) {
    bool isProposed = appointment.status == 'PROPUESTA';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // Antes: mainAxisAlignment: MainAxisAlignment. Pluto,
              // Ahora:
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStatusBadge(appointment.status),
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
            const SizedBox(height: 15),
            const Text(
              "Motivo:",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              appointment.motive,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            if (appointment.scheduledDate != null) ...[
              const Divider(height: 30),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'EEEE d MMMM - hh:mm a',
                      'es',
                    ).format(appointment.scheduledDate!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text("Duración: ${appointment.durationMinutes} min"),
                ],
              ),
            ],

            if (isProposed) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleAction(
                        context,
                        vm,
                        appointment.id!,
                        'RECHAZADA',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text("Rechazar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAction(
                        context,
                        vm,
                        appointment.id!,
                        'CONFIRMADA',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "Aceptar Hora",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    AppointmentsViewModel vm,
    String id,
    String newStatus,
  ) async {
    // Aquí implementamos el UC3 y UC6 de tu UML
    try {
      await vm.updateStatusFromPatient(id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'CONFIRMADA'
                  ? "✅ Cita Agendada"
                  : "❌ Solicitud Cancelada",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'SOLICITADA':
        color = Colors.orange;
        break;
      case 'PROPUESTA':
        color = Colors.blue;
        break;
      case 'CONFIRMADA':
        color = Colors.green;
        break;
      case 'RECHAZADA':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Aún no tienes solicitudes de cita."));
  }
}
