import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Mis Solicitudes",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfaceLowest,
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
            SizedBox(height: 15),
            Text(
              "Motivo:",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              appointment.motive,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            if (appointment.scheduledDate != null) ...[
              Divider(height: 30),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 18, color: AppColors.mint),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'EEEE d MMMM - hh:mm a',
                      'es',
                    ).format(appointment.scheduledDate!),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: AppColors.tertiary,
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
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
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
                        backgroundColor: AppColors.mint,
                      ),
                      child: Text(
                        "Aceptar Hora",
                        style: TextStyle(color: AppColors.surfaceLowest),
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
        color = AppColors.tertiary;
        break;
      case 'PROPUESTA':
        color = AppColors.lavender;
        break;
      case 'CONFIRMADA':
        color = AppColors.mint;
        break;
      case 'RECHAZADA':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
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
