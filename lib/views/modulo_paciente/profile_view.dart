import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloCitas/viewmodels/appointments_viewmodel.dart';
import 'package:mindfulness_app/moduloTareas/viewmodels/tasks_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/patient_history_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/reminders_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/routines_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/self_assessments_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/sleep_habits_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/thought_entries_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/reminders_view.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import 'sleep_habits_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthViewModel authViewModel,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Cerrar sesion',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Confirma que deseas salir de tu cuenta.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surfaceLowest,
              minimumSize: const Size(96, 48),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authViewModel.signOut();

      if (context.mounted) {
        // Limpieza profunda del estado para evitar fugas de datos entre usuarios
        context.read<RoutinesViewModel>().reset();
        context.read<ThoughtEntriesViewModel>().reset();
        context.read<TasksViewModel>().reset();
        context.read<RemindersViewModel>().reset();
        context.read<PatientHistoryViewModel>().reset();
        context.read<SelfAssessmentsViewModel>().reset();
        context.read<SleepHabitsViewModel>().reset();
        context.read<AppointmentsViewModel>().reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            Text('Mi Perfil', style: Theme.of(context).textTheme.displayMedium),
            SizedBox(height: 32),
            Card(
              color: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.lavender,
                      child: Icon(
                        Icons.person,
                        color: AppColors.surfaceLowest,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.userMetadata?['full_name'] ?? 'Usuario',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Ajustes del sistema',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.lavender,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeSelector(context, themeViewModel),
            _buildSettingsTile(
              context: context,
              icon: Icons.hotel_rounded,
              title: 'Mis habitos de sueno',
              subtitle: 'Horarios y carga academica',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SleepHabitsView()),
                );
              },
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.notifications_active_rounded,
              title: 'Recordatorios',
              subtitle: 'Avisos de rutina y descanso',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RemindersView()),
                );
              },
            ),
            SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: authViewModel.isLoading
                  ? null
                  : () => _showLogoutDialog(context, authViewModel),
              icon: authViewModel.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : Icon(Icons.logout_rounded),
              label: Text(
                authViewModel.isLoading
                    ? 'Cerrando sesion...'
                    : 'Cerrar sesion',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeViewModel themeViewModel,
  ) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: AppColors.mint),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema visual',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        themeViewModel.isLoading
                            ? 'Guardando preferencia...'
                            : 'Claro por defecto, oscuro cuando lo necesites.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (themeViewModel.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.mint,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Selector de tema visual',
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Claro'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Oscuro'),
                  ),
                ],
                selected: {themeViewModel.themeMode},
                onSelectionChanged: themeViewModel.isLoading
                    ? null
                    : (selection) async {
                        final mode = selection.first;
                        await context.read<ThemeViewModel>().setThemeMode(mode);
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              mode == ThemeMode.dark
                                  ? 'Modo oscuro activado'
                                  : 'Modo claro activado',
                            ),
                          ),
                        );
                      },
              ),
            ),
            if (themeViewModel.errorMessage != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: AppColors.error),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      themeViewModel.errorMessage!,
                      style: TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        minVerticalPadding: 12,
        leading: Icon(icon, color: AppColors.mint),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
