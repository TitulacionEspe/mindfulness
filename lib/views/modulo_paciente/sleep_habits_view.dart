import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';

class SleepHabitsView extends StatefulWidget {
  const SleepHabitsView({super.key});

  @override
  State<SleepHabitsView> createState() => _SleepHabitsViewState();
}

class _SleepHabitsViewState extends State<SleepHabitsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SleepHabitsViewModel>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SleepHabitsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: viewModel.hasCompletedOnboarding
          ? AppBar(
              backgroundColor: AppColors.background.withValues(alpha: 0),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Ajustes de Sueño',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
            )
          : null,
      body: SafeArea(
        child: viewModel.isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.mint))
            : CustomScrollView(
                slivers: [
                  if (!viewModel.hasCompletedOnboarding)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personaliza tu descanso',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Configura tus hábitos para que el sistema se adapte a tu ritmo universitario.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildConfigCard(
                        title: 'Horarios habituales',
                        child: Column(
                          children: [
                            _buildTimeTile(
                              label: 'Hora de dormir',
                              icon: Icons.bedtime_outlined,
                              time: viewModel.bedtime,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: viewModel.bedtime,
                                );
                                if (time != null) viewModel.setBedtime(time);
                              },
                            ),
                            Divider(color: AppColors.navBorder, height: 24),
                            _buildTimeTile(
                              label: 'Hora de despertar',
                              icon: Icons.wb_sunny_outlined,
                              time: viewModel.wakeTime,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: viewModel.wakeTime,
                                );
                                if (time != null) viewModel.setWakeTime(time);
                              },
                            ),
                          ],
                        ),
                      ),
                      _buildConfigCard(
                        title: 'Días de mayor carga académica',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selecciona los días en los que sueles tener más estrés o clases tarde.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildDayChip('Lun', 1, viewModel),
                                _buildDayChip('Mar', 2, viewModel),
                                _buildDayChip('Mié', 4, viewModel),
                                _buildDayChip('Jue', 8, viewModel),
                                _buildDayChip('Vie', 16, viewModel),
                                _buildDayChip('Sáb', 32, viewModel),
                                _buildDayChip('Dom', 64, viewModel),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildConfigCard(
                        title: 'Preferencias',
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Forzar modo oscuro',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Ideal para reducir la fatiga visual nocturna.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          value: viewModel.darkModeEnforced,
                          activeThumbColor: AppColors.mint,
                          onChanged: (val) => viewModel.setDarkMode(val),
                        ),
                      ),
                      SizedBox(height: 100),
                    ]),
                  ),
                ],
              ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(24),
        color: AppColors.background,
        child: ElevatedButton(
          onPressed: viewModel.isLoading
              ? null
              : () async {
                  final success = await viewModel.saveSettings();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración guardada correctamente'),
                      ),
                    );
                    // Si ya estaba en el sistema (editando), regresar atrás
                    if (viewModel.hasCompletedOnboarding &&
                        Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                },
          child: Text(
            viewModel.hasCompletedOnboarding
                ? 'Guardar Cambios'
                : 'Guardar y Continuar',
          ),
        ),
      ),
    );
  }

  Widget _buildConfigCard({required String title, required Widget child}) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lavender,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required String label,
    required IconData icon,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.mint, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
            ),
            Text(
              time.format(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.mint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(
    String label,
    int bitValue,
    SleepHabitsViewModel viewModel,
  ) {
    final isSelected = (viewModel.academicLoadDays & bitValue) != 0;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => viewModel.toggleAcademicDay(bitValue),
      selectedColor: AppColors.mint,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.buttonPrimaryText : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(
        color: isSelected ? AppColors.mint : AppColors.navBorder,
      ),
      showCheckmark: false,
    );
  }
}
