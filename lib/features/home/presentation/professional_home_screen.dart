import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/dashboard_tareas_view.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import '../../../../viewmodels/psicologa_nav_viewmodel.dart';
import '../../../../views/modulo_psicologa/actividades_view.dart';
import '../../../../views/modulo_psicologa/asignar_view.dart';
import '../../../../views/modulo_psicologa/citas_view.dart';
import '../../../../views/modulo_psicologa/pacientes_view.dart';

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final navVM = Provider.of<PsicologaNavViewModel>(context);

    final List<Widget> pages = [
      const DashboardTareasView(),
      const PacientesView(),
      const AsignarView(),
      const ActividadesView(),
      const CitasView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Panel Profesional',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Flutter automáticamente pondrá el icono de hamburguesa si hay un drawer
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // 📱 MENÚ LATERAL (DRAWER)
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: Column(
          children: [
            // Cabecera del menú
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Icon(Icons.person, size: 40, color: AppColors.accent),
              ),
              accountName: Text(
                'Profesional de Salud',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                'Gestión de Pacientes',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),

            // Opciones del menú
            ListTile(
              leading: Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Configuración',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                // TODO: Implementar navegación a configuración
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.textPrimary),
              title: Text(
                'Ayuda y Soporte',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(), // Empuja el botón de salir al fondo

            Divider(color: AppColors.outlineVariant),

            // Botón de Cerrar Sesión
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context); // Cerrar el drawer antes
                await authViewModel.signOut();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: IndexedStack(index: navVM.currentIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navVM.currentIndex,
        onTap: (index) => navVM.updateIndex(index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind_rounded),
            label: 'Asignar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_motion_rounded),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Citas',
          ),
        ],
      ),
    );
  }
}
