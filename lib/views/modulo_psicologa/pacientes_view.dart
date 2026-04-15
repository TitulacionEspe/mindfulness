import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';




import 'pacientes/components/patient_search_bar.dart';
import 'pacientes/components/patient_filter_row.dart';
import 'pacientes/components/patient_card.dart';


import 'pacientes/components/patient_header.dart';
import 'pacientes/components/patient_search_row.dart';
import 'pacientes/components/pacient_bar.dart';



import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Importación de tus componentes modulares

import 'pacientes/components/day_registry.dart';
import 'pacientes/components/patient_search_row.dart';
import 'pacientes/components/status_filters.dart';
import 'pacientes/components/patient_card_white.dart';

class PacientesView extends StatelessWidget {
  const PacientesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo oscuro de la app
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. BANNER SUPERIOR (Imagen + Título)
            const PacienBanner(),

            // Contenedor para el resto de elementos con margen lateral
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                                   // 3. FILA DE BÚSQUEDA (Botón circular + Buscador)
                  const PatientSearchRow(),

                  const SizedBox(height: 20),

                  // 4. FILTROS DE ESTADO (Realizados / No realizados)
                  const StatusFilters(),

                  const SizedBox(height: 25),

                  // 5. TÍTULO DE LA LISTA
                  const Text(
                    "Lista de pacientes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 6. LISTA DE TARJETAS BLANCAS
                  // Usamos ListView.builder en el futuro para Supabase
                  ListView(
                    shrinkWrap: true, // Para que funcione dentro de SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      PatientCardWhite(
                        name: "Juan Perez",
                        task: "Actividad: Respiración Consciente",
                        progress: 0.8,
                      ),
                      PatientCardWhite(
                        name: "Maria Garcia",
                        task: "Cuestionario de Ansiedad",
                        progress: 0.4,
                      ),
                      PatientCardWhite(
                        name: "Luis Merizalde",
                        task: "Actividad: Caminata Mindfulness",
                        progress: 0.9,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                   // 2. REGISTRO DE DÍAS (Sección Blanca)
                  const DayRegistry(), 

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}