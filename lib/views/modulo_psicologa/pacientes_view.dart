import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Importación de componentes realmente utilizados
import 'pacientes/components/pacient_bar.dart'; // Verifica si este es tu Banner
import 'pacientes/components/patient_search_row.dart';
import 'pacientes/components/status_filters.dart';
import 'pacientes/components/patient_card_white.dart';
import 'pacientes/components/day_registry.dart';

class PacientesView extends StatelessWidget {
  const PacientesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. BANNER SUPERIOR
            // Asegúrate que el componente se llame PacientBar o importa el correcto
            const PacientBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 3. FILA DE BÚSQUEDA
                  const PatientSearchRow(),

                  SizedBox(height: 20),

                  // 4. FILTROS DE ESTADO
                  StatusFilters(),

                  SizedBox(height: 25),

                  // 5. TÍTULO DE LA LISTA
                  Text(
                    "Lista de pacientes",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 6. LISTA DE TARJETAS
                  ListView(
                    shrinkWrap: true,
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

                  // 2. REGISTRO DE DÍAS
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
