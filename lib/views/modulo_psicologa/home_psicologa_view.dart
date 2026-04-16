import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'components/home_banner.dart';
import 'components/stats_card.dart';
import 'components/quick_actions.dart';

class HomePsicologaView extends StatelessWidget {
  const HomePsicologaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView( // Permite scroll para ver todo
        child: Column(
          children: [
            // 1. Banner con Imagen y Título
            const HomeBanner(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 2. Grilla de Estadísticas (Fija, sin scroll propio)
                  GridView.count(
                    shrinkWrap: true, // Importante dentro de SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: const [
                      StatsCard(icon: Icons.people, titleLine1: "Pacientes", titleLine2: "totales", value: "20", accentColor: Colors.blue),
                      StatsCard(icon: Icons.task, titleLine1: "Taks Comple", titleLine2: "totales", value: "20", accentColor: Colors.green),
                      StatsCard(icon: Icons.timer, titleLine1: "Citas", titleLine2: "Pendientes", value: "20", accentColor: Colors.blueGrey),
                      StatsCard(icon: Icons.check_circle, titleLine1: "Cita", titleLine2: "Confirm", value: "20", accentColor: Colors.blue),
                    ],
                  ),
                  
                  const SizedBox(height: 30),

                  // 3. Acciones Rápidas
                  const QuickActions(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Botón flotante para Chat/Compartir (opcional según imagen)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white.withOpacity(0.9),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
      ),
    );
  }
}