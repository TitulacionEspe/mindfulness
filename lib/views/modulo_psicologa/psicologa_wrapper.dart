import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/psicologa_nav_viewmodel.dart';
import 'actividades_view.dart';
import 'asignar_view.dart';
import 'citas_view.dart';
import 'home_psicologa_view.dart';
import 'pacientes_view.dart';

class PsicologaWrapper extends StatelessWidget {
  const PsicologaWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al ViewModel
    final navVM = Provider.of<PsicologaNavViewModel>(context);

    ///la barra de navegacion de la psicologa se cambio features/home/professional_home
    // Las 5 páginas de tu mockup
    final List<Widget> pages = [
      const HomePsicologaView(),
      const PacientesView(),
      const AsignarView(),
      const ActividadesView(),
      CitasView(),
    ];

    return Scaffold(
      body: IndexedStack(index: navVM.currentIndex, children: pages),
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
            label: 'cuestionario',
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
