import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import '../../views/modulo_psicologa/components/professional_navigation_helper.dart';
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

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizar sesión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escribe notas de seguimiento:'),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Resumen de la sesión...',
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Ocultar el teclado de inmediato
              FocusManager.instance.primaryFocus?.unfocus();

              final notes = notesController.text.trim();

              // 2. Cerrar el diálogo de inmediato para dar feedback visual
              Navigator.of(dialogContext).pop();

              try {
                // 3. Ejecutar la operación
                await context.read<AppointmentsViewModel>().markAsDone(
                  id,
                  notes,
                );

                if (!context.mounted) return;

                // 4. Cerrar la vista principal de agenda
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cita completada y registrada.'),
                    backgroundColor: AppColors.mint,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'No se pudo finalizar la cita. Intenta nuevamente.',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Guardar y cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppointmentsViewModel>();
    final agendaActiva = viewModel.allAppointments
        .where((a) => a.status == 'CONFIRMADA')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda confirmada'),
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
          : agendaActiva.isEmpty
          ? const Center(child: Text('No tienes citas confirmadas por ahora.'))
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
