import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/moduloPsiquiatra/componets_ps/psychiatrist_components.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/gestion_rutinas_view.dart';
import 'package:mindfulness_app/views/modulo_psicologa/actividades/components/activity_action_buttons.dart';

import 'actividades/components/activity_item_card.dart';
import 'actividades/components/activity_search.dart';
import 'actividades/components/category_filters.dart';

class ActividadesView extends StatelessWidget {
  const ActividadesView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Título con jerarquía clara (Heurística: Reconocimiento)
              Text(
                "Gestión de Actividades",
                style: textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Administra y explora las rutinas disponibles.",
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 30),
              const ActivityActionButtons(),

              const SizedBox(height: 30),
              const CategoryFilters(),

              const SizedBox(height: 20),
              ActivitySearch(),

              const SizedBox(height: 32),

              // Subtítulo consistente
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Explorar Catálogo",
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              PsychiatristActionCard(
                title: "Catálogo de Rutinas",
                subtitle: "Ver tus plantillas guardadas",
                icon: Icons.library_books_rounded,
                color: AppColors.lavender,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GestionRutinasView()),
                ),
              ),

              const SizedBox(height: 10),

              // Lista de Actividades con diseño unificado
              const ActivityItemCard(
                emoji: '🌙',
                title: 'Meditación para dormir',
                category: 'Inducción de sueño',
                duration: '15 min',
                stats: '▶ 1.2k reproducciones',
              ),
              const ActivityItemCard(
                emoji: '🎧',
                title: 'Sonidos de lluvia',
                category: 'Audio relajante',
                duration: '30 min',
                stats: '▶ 2.1k reproducciones',
              ),
              const ActivityItemCard(
                emoji: '📓',
                title: 'Guía de mindfulness',
                category: 'Guía práctica',
                duration: '12 min',
                stats: '👁 756 visualizaciones',
              ),
              const ActivityItemCard(
                emoji: '🎮',
                title: 'Juego de burbujas zen',
                category: 'Juego anti-estrés',
                duration: '5 min',
                stats: '▶ 1.5k partidas',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
