import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

class SleepHabitsView extends StatefulWidget {
  final bool showBackButton;
  const SleepHabitsView({super.key, this.showBackButton = false});

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
              automaticallyImplyLeading: false,
              leading: widget.showBackButton
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Te enviaremos una notificación suave para ayudarte a descansar por la noche y un saludo calmado al despertar.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 16),
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
                              'En los días seleccionados, recibirás una notificación motivacional por la mañana a las 8:00 AM para recordarte respirar y cuidar tu bienestar.',
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
                        title: 'Tono acústico de transición',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elige el efecto de sonido que se reproducirá como guía al iniciar o cambiar de fase en tus ejercicios.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Semantics(
                              label: 'Selector de tono de transición de rutinas',
                              child: Row(
                                children: [
                                  _buildToneCard(
                                    context: context,
                                    label: 'Burbuja',
                                    value: 'femenina',
                                    icon: Icons.bubble_chart_outlined,
                                    viewModel: viewModel,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildToneCard(
                                    context: context,
                                    label: 'Platillo',
                                    value: 'masculina',
                                    icon: Icons.graphic_eq_outlined,
                                    viewModel: viewModel,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildToneCard(
                                    context: context,
                                    label: 'Campana',
                                    value: 'ambient',
                                    icon: Icons.notifications_active_outlined,
                                    viewModel: viewModel,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildThemeSelectorCard(context),
                      const SizedBox(height: 100),
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
  Widget _buildThemeSelectorCard(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    return _buildConfigCard(
      title: 'Tema preferencial / Descanso visual',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elige la apariencia que mejor se adapte a tu fatiga visual o luz ambiental. El modo claro es ideal para el día y el modo oscuro ayuda a descansar la vista por la noche.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Selector de tema preferencial',
            child: SizedBox(
              width: double.infinity,
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
          ),
        ],
      ),
    );
  }

  Widget _buildToneCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required SleepHabitsViewModel viewModel,
  }) {
    final isSelected = viewModel.preferredVoice == value;

    final (accentColor, bgColor) = switch (value) {
      'femenina' => (AppColors.mint, AppColors.successBg),
      'masculina' => (AppColors.lavender, AppColors.warningBg),
      'ambient' || _ => (AppColors.tertiary, AppColors.tertiaryBg),
    };

    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: 'Tono $label',
        child: InkWell(
          onTap: () => viewModel.setPreferredVoice(value),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? bgColor : AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? accentColor : AppColors.outlineVariant,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? accentColor : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
