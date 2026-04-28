import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloPsiquiatra/componets_ps/psychiatrist_components.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/asignar_tarea_view.dart';

import '../../core/theme/app_colors.dart';
import 'cuestionario/components/cuestionario_card_pro.dart';
import 'cuestionario/components/cuestionario_search.dart';
import 'cuestionario/components/cuestionario_stats.dart';

class AsignarView extends StatelessWidget {
  const AsignarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Color azul oscuro del Figma
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
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

            //const CuestioBanner(), // Invocas tu imagen superior
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CuestionarioSearch(), // Buscador estilo Figma

                  const SizedBox(height: 25),

                  const CuestionarioStats(), // Los dos cuadros: Recientes y Pendientes

                  SizedBox(height: 25),

                  // Botón de Filtrar (Negro como en el Figma)
                  Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Filtrar',
                        style: TextStyle(
                          color: AppColors.surfaceLowest,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Lista Horizontal de Tarjetas
                  SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CuestionarioCardPro(
                          statusLabel: "RESPONDIDO HOY",
                          emoji: "✅",
                          patientName: "Marta Gómez",
                          testName: "Índice de Calidad...",
                          headerColor: AppColors.successBg,
                          textColor: AppColors.successText,
                        ),
                        CuestionarioCardPro(
                          statusLabel: "PENDIENTE",
                          emoji: "⌛",
                          patientName: "Luis Pérez",
                          testName: "Cuestionario de...",
                          headerColor: AppColors.warningBg,
                          textColor: AppColors.warningText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
