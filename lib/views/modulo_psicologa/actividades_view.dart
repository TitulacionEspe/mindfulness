import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Importamos los componentes locales
import 'actividades/components/activity_search.dart';
import 'actividades/components/category_filters.dart';
import 'actividades/components/activity_item_card.dart';
import 'actividades/components/activi_banner.dart';

class ActividadesView extends StatelessWidget {
  const ActividadesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.figmaBlue, // El azul profundo del Figma
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
                  // 1. Buscador
                  const ActivitySearch(),

                  const SizedBox(height: 30),

                  // 2. Filtros de Categorías
                  const CategoryFilters(),

                  const SizedBox(height: 30),

                  // 3. Título de la lista
                  const Text(
                    "Explorar Actividades",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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