import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import '../componets_ps/agenda_card.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
    });
  }

  void _showCompleteDialog(BuildContext context, String id) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finalizar Sesión"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Escribe tus notas clínicas (privadas):"),
            SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Resumen de la sesión...",
                filled: true,
                fillColor: AppColors.surfaceLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
              await context.read<AppointmentsViewModel>().markAsDone(
                id,
                notesController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Cita completada y guardada en historial"),
                  ),
                );
              }
            },
            child: const Text("Guardar y Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();
    // Filtramos solo las CONFIRMADAS para la agenda activa
    final agendaActiva = viewModel.allAppointments
        .where((a) => a.status == 'CONFIRMADA')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Agenda Confimada"),
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : agendaActiva.isEmpty
          ? const Center(child: Text("No tienes citas confirmadas para hoy"))
          : ListView.builder(
              itemCount: agendaActiva.length,
              itemBuilder: (context, index) {
                final appointment = agendaActiva[index];
                return AgendaCard(
                  appointment: appointment,
                  onComplete: () =>
                      _showCompleteDialog(context, appointment.id!),
                );
              },
            ),
    );
  }
}
