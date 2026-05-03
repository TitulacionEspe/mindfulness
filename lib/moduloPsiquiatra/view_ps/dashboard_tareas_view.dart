import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloPsiquiatra/componets_ps/psychiatrist_components.dart';

import 'asignar_tarea_view.dart';
import 'crear_rutina_view.dart';
import 'gestion_rutinas_view.dart';

class DashboardTareasView extends StatelessWidget {
  const DashboardTareasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resumenes ")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
