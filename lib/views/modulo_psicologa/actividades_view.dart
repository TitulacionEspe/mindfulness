import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/views/modulo_psicologa/actividades/components/activity_action_buttons.dart';

import 'actividades/components/activi_banner.dart';
import 'actividades/components/activity_item_card.dart';
// Importamos los componentes locales
import 'actividades/components/activity_search.dart';
import 'actividades/components/category_filters.dart';

class ActividadesView extends StatelessWidget {
  const ActividadesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El azul profundo del Figma
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El Banner va fuera del Padding para que ocupe todo el ancho
            const ActiBanner(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dentro de tu Column:
                  const SizedBox(height: 30),

                  // 2. Botones de Acción (En lugar de CategoryFilters)
                  const ActivityActionButtons(),

                  const SizedBox(height: 30),

                  // 2. Filtros de Categorías
                  const CategoryFilters(),

                  SizedBox(height: 30),
                  // 1. Buscador
                  ActivitySearch(),

                  SizedBox(height: 30),

                  // 3. Título de la lista
                  Text(
                    "Explorar Actividades",
                    style: TextStyle(
                      color: AppColors.surfaceLowest,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 4. Lista de Actividades
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
