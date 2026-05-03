import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloPsiquiatra/componets_ps/psychiatrist_components.dart';
import 'package:provider/provider.dart';

import '../../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import '../../../viewmodels/viewmodels_psicologa/patients_viewmodel.dart';
import '../viewmodels_ps/routines_viewmodel2.dart';
import 'asignar_tarea_view.dart';
import 'crear_rutina_view.dart';
import 'gestion_rutinas_view.dart';

class DashboardTareasView extends StatefulWidget {
  const DashboardTareasView({super.key});

  @override
  State<DashboardTareasView> createState() => _DashboardTareasViewState();
}

class _DashboardTareasViewState extends State<DashboardTareasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
      context.read<PatientsViewModel>().loadPatients();
      context.read<RoutinesViewModel2>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsVM = context.watch<AppointmentsViewModel>();
    final patientsVM = context.watch<PatientsViewModel>();
    final routinesVM = context.watch<RoutinesViewModel2>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Panel de Psicología",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. GRID DE MÉTRICAS (CUADRITOS)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              MetricCard(
                label: "Solicitudes",
                value: appointmentsVM.pendingRequests.length.toString(),
                icon: Icons.pending_actions_rounded,
                color: Colors.orange,
              ),
              MetricCard(
                label: "Citas Hoy",
                value: appointmentsVM.confirmedAgenda.length.toString(),
                icon: Icons.calendar_today_rounded,
                color: Colors.indigo,
              ),
              MetricCard(
                label: "Pacientes",
                value: patientsVM.patients.length.toString(),
                icon: Icons.people_alt_rounded,
                color: Colors.teal,
              ),
              MetricCard(
                label: "Tus Rutinas",
                value: routinesVM.routines.length.toString(),
                icon: Icons.auto_awesome_motion_rounded,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            "Accesos Rápidos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // 2. ACCESOS QUE YA EXISTÍAN
          PsychiatristActionCard(
            title: "Catálogo de Rutinas",
            subtitle: "Ver tus plantillas guardadas",
            icon: Icons.library_books,
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GestionRutinasView()),
            ),
          ),
          const SizedBox(height: 15),
          PsychiatristActionCard(
            title: "Crear Nueva Rutina",
            subtitle: "Diseñar ejercicio de respiración",
            icon: Icons.add_circle,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CrearRutinaView()),
            ),
          ),
          const SizedBox(height: 15),
          PsychiatristActionCard(
            title: "Asignar a Paciente",
            subtitle: "Enviar tarea a un usuario",
            icon: Icons.person_add,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AsignarTareaView()),
            ),
          ),
        ],
      ),
    );
  }
}
