import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart'; // Tus colores
import '../../../../viewmodels/auth_viewmodel.dart';
import '../../../../viewmodels/psicologa_nav_viewmodel.dart';
import '../../../../views/modulo_psicologa/actividades_view.dart';
import '../../../../views/modulo_psicologa/asignar_view.dart';
import '../../../../views/modulo_psicologa/citas_view.dart';
// Importa tus vistas
import '../../../../views/modulo_psicologa/home_psicologa_view.dart';
import '../../../../views/modulo_psicologa/pacientes_view.dart';

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Enganchamos ambos mundos
    final authViewModel = Provider.of<AuthViewModel>(context);
    final navVM = Provider.of<PsicologaNavViewModel>(context);

    // 2. Tus 5 páginas
    final List<Widget> pages = [
      const HomePsicologaView(),
      const PacientesView(),
      const AsignarView(),
      const ActividadesView(),
      const CitasView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // Mantenemos el AppBar del compañero para el Logout, pero con tu estilo
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Panel Profesional',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.accent),
            onPressed: () async {
              await authViewModel.signOut(); // Funcionalidad de tu compañero
            },
          ),
        ],
      ),
      // 3. Tu cuerpo con IndexedStack
      body: IndexedStack(index: navVM.currentIndex, children: pages),
      // 4. Tu barra de navegación
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navVM.currentIndex,
        onTap: (index) => navVM.updateIndex(index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Paciente'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Cuestionario',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Actividades'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Cita',
          ),
        ],
      ),
    );
  }
}
