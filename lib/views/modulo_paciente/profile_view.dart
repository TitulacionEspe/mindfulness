import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/reminders_view.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import 'componet/patient_navigation_helper.dart';
import 'sleep_habits_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Mi Perfil',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            tooltip: 'Menú principal',
            onPressed: () => PatientNavigationHelper.returnToMainMenu(context),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
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
              title: 'Mis hábitos de sueño',
              subtitle: 'Horarios y carga académica',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SleepHabitsView(showBackButton: true),
                  ),
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
