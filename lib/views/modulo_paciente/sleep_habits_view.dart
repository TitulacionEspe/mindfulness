import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/sleep_log_model.dart';
import '../../core/theme/app_colors.dart';
import '../../services/transition_tone_preview_service.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';
import '../../viewmodels/sleep_logs_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

class SleepHabitsView extends StatefulWidget {
  final bool showBackButton;
  final bool showAppBar;
  final TransitionTonePreviewService? tonePreviewService;
  const SleepHabitsView({
    super.key,
    this.showBackButton = false,
    this.showAppBar = true,
    this.tonePreviewService,
  });

  @override
  State<SleepHabitsView> createState() => _SleepHabitsViewState();
}

class _SleepHabitsViewState extends State<SleepHabitsView> {
  late final TransitionTonePreviewService _tonePreviewService;
  late final bool _ownsTonePreviewService;
  String? _previewingToneValue;

  @override
  void initState() {
    super.initState();
    _ownsTonePreviewService = widget.tonePreviewService == null;
    _tonePreviewService =
        widget.tonePreviewService ?? TransitionTonePreviewService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SleepHabitsViewModel>().loadSettings();
      try {
        context.read<SleepLogsViewModel>().loadLogs();
      } on ProviderNotFoundException {
        // Tests or isolated previews may render this view without sleep logs.
      }
    });
  }

  @override
  void dispose() {
    _tonePreviewService.stop();
    if (_ownsTonePreviewService) {
      _tonePreviewService.dispose();
    }
    super.dispose();
  }

  Future<void> _selectTone({
    required SleepHabitsViewModel viewModel,
    required String value,
    required String label,
  }) async {
    viewModel.setPreferredVoice(value);
    setState(() => _previewingToneValue = value);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Tono $label seleccionado. Reproduciendo muestra.'),
      ),
    );

    try {
      await _tonePreviewService.playTone(value);
    } catch (_) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo reproducir la muestra. La preferencia quedó seleccionada.',
            ),
          ),
        );
    } finally {
      if (mounted && _previewingToneValue == value) {
        setState(() => _previewingToneValue = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SleepHabitsViewModel>();
    SleepLogsViewModel? logsViewModel;
    try {
      logsViewModel = context.watch<SleepLogsViewModel>();
    } on ProviderNotFoundException {
      logsViewModel = null;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: (viewModel.hasCompletedOnboarding && widget.showAppBar)
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
                'Ajustes de sueño',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
            )
          : null,
      body: SafeArea(
        child: viewModel.isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.mint))
            : CustomScrollView(
                slivers: [
                  if (!viewModel.hasCompletedOnboarding || !widget.showAppBar)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.hasCompletedOnboarding
                                  ? 'Ajustes de sueño'
                                  : 'Personaliza tu descanso',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Configura tus hábitos para que Nidara se adapte a tu ritmo universitario.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      if (viewModel.hasCompletedOnboarding &&
                          logsViewModel != null) ...[
                        _buildSleepLogCard(context, logsViewModel),
                        const SizedBox(height: 8),
                      ],
                      _buildConfigCard(
                        title: 'Horarios habituales',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Te enviaremos una notificación suave para ayudarte a descansar por la noche y un saludo calmado al despertar.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Semantics(
                              label:
                                  'Selector de tono de transición de rutinas',
                              child: Row(
                                children: [
                                  _buildToneCard(
                                    context: context,
                                    label: 'Burbuja',
                                    value: 'femenina',
                                    icon: Icons.bubble_chart_outlined,
                                    viewModel: viewModel,
                                    isPreviewing:
                                        _previewingToneValue == 'femenina',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildToneCard(
                                    context: context,
                                    label: 'Platillo',
                                    value: 'masculina',
                                    icon: Icons.graphic_eq_outlined,
                                    viewModel: viewModel,
                                    isPreviewing:
                                        _previewingToneValue == 'masculina',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildToneCard(
                                    context: context,
                                    label: 'Campana',
                                    value: 'ambient',
                                    icon: Icons.notifications_active_outlined,
                                    viewModel: viewModel,
                                    isPreviewing:
                                        _previewingToneValue == 'ambient',
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
                    // Si ya estaba en la aplicación (editando), regresar atrás
                    if (viewModel.hasCompletedOnboarding &&
                        Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                },
          child: Text(
            viewModel.hasCompletedOnboarding
                ? 'Guardar cambios'
                : 'Guardar y continuar',
          ),
        ),
      ),
    );
  }

  Widget _buildSleepLogCard(
    BuildContext context,
    SleepLogsViewModel logsViewModel,
  ) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.hotel_rounded, color: AppColors.mint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro diario de sueño',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Anota cómo dormiste para ver tendencias personales sin interpretación clínica.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: logsViewModel.isSaving
                    ? null
                    : () => _openSleepLogSheet(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Registrar sueño de hoy'),
              ),
            ),
            if (logsViewModel.errorMessage != null) ...[
              const SizedBox(height: 12),
              _InlineSleepLogFeedback(
                message: logsViewModel.errorMessage!,
                color: AppColors.error,
                icon: Icons.error_outline_rounded,
              ),
            ],
            if (logsViewModel.successMessage != null) ...[
              const SizedBox(height: 12),
              _InlineSleepLogFeedback(
                message: logsViewModel.successMessage!,
                color: AppColors.mint,
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
            const SizedBox(height: 16),
            if (logsViewModel.isLoading && logsViewModel.logs.isEmpty)
              Center(child: CircularProgressIndicator(color: AppColors.mint))
            else if (logsViewModel.logs.isEmpty)
              _SleepLogEmptyState(onTap: () => _openSleepLogSheet(context))
            else
              Column(
                children: logsViewModel.logs
                    .take(3)
                    .map(
                      (log) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SleepLogTile(log: log),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSleepLogSheet(BuildContext context) async {
    final habits = context.read<SleepHabitsViewModel>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SleepLogsViewModel>(),
        child: _SleepLogFormSheet(
          initialBedtime: habits.bedtime,
          initialWakeTime: habits.wakeTime,
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
    required bool isPreviewing,
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
        label: isSelected
            ? 'Tono $label seleccionado. Toca para escuchar una muestra.'
            : 'Tono $label. Toca para seleccionar y escuchar una muestra.',
        child: InkWell(
          onTap: () =>
              _selectTone(viewModel: viewModel, value: value, label: label),
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
                isPreviewing
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentColor,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 22,
                        color: isSelected
                            ? accentColor
                            : AppColors.textSecondary,
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
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
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

class _SleepLogFormSheet extends StatefulWidget {
  const _SleepLogFormSheet({
    required this.initialBedtime,
    required this.initialWakeTime,
  });

  final TimeOfDay initialBedtime;
  final TimeOfDay initialWakeTime;

  @override
  State<_SleepLogFormSheet> createState() => _SleepLogFormSheetState();
}

class _SleepLogFormSheetState extends State<_SleepLogFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _latencyController = TextEditingController();
  final _awakeController = TextEditingController();
  final _noteController = TextEditingController();
  late TimeOfDay _bedtime;
  late TimeOfDay _wakeTime;
  int _quality = 3;

  @override
  void initState() {
    super.initState();
    _bedtime = widget.initialBedtime;
    _wakeTime = widget.initialWakeTime;
  }

  @override
  void dispose() {
    _latencyController.dispose();
    _awakeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final viewModel = context.watch<SleepLogsViewModel>();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar sueño de hoy',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Registra datos generales de descanso. Esta información no se usa para diagnosticar.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                _TimeSelectorTile(
                  label: 'Hora de dormir',
                  value: _bedtime.format(context),
                  icon: Icons.bedtime_outlined,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _bedtime,
                    );
                    if (picked != null) setState(() => _bedtime = picked);
                  },
                ),
                const SizedBox(height: 10),
                _TimeSelectorTile(
                  label: 'Hora de despertar',
                  value: _wakeTime.format(context),
                  icon: Icons.wb_sunny_outlined,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _wakeTime,
                    );
                    if (picked != null) setState(() => _wakeTime = picked);
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Calidad percibida',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final selected = value == _quality;
                    return ChoiceChip(
                      label: Text('$value'),
                      selected: selected,
                      onSelected: (_) => setState(() => _quality = value),
                      showCheckmark: false,
                      selectedColor: AppColors.successBg,
                      backgroundColor: AppColors.surfaceLow,
                      side: BorderSide(
                        color: selected
                            ? AppColors.mint
                            : AppColors.outlineVariant,
                      ),
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.mint
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latencyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutos para dormir',
                          hintText: 'Ej. 20',
                        ),
                        validator: _optionalPositiveNumber,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _awakeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutos despierto',
                          hintText: 'Ej. 10',
                        ),
                        validator: _optionalPositiveNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 240,
                  decoration: const InputDecoration(
                    labelText: 'Nota opcional',
                    hintText: 'Ej. Me desperté por ruido o estrés académico.',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isSaving ? null : _save,
                        icon: viewModel.isSaving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.buttonPrimaryText,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _optionalPositiveNumber(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 0) {
      return 'Usa un número válido.';
    }
    if (parsed > 720) {
      return 'Revisa el valor ingresado.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<SleepLogsViewModel>();
    final success = await viewModel.createLog(
      bedTime: _bedtime,
      wakeTime: _wakeTime,
      sleepQualityRating: _quality,
      sleepLatencyMin: int.tryParse(_latencyController.text.trim()),
      wakeAfterSleepOnsetMin: int.tryParse(_awakeController.text.trim()),
      disturbances: _noteController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro de sueño guardado.')),
      );
    }
  }
}

class _TimeSelectorTile extends StatelessWidget {
  const _TimeSelectorTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.mint),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepLogTile extends StatelessWidget {
  const _SleepLogTile({required this.log});

  final SleepLogModel log;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("d 'de' MMMM", 'es').format(log.logDate);
    final bed = DateFormat('HH:mm').format(log.bedTime.toLocal());
    final wake = DateFormat('HH:mm').format(log.wakeTime.toLocal());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.nights_stay_outlined, color: AppColors.lavender),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bed - $wake · Calidad ${log.sleepQualityRating ?? '-'}/5',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepLogEmptyState extends StatelessWidget {
  const _SleepLogEmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.bedtime_outlined, color: AppColors.lavender, size: 30),
          const SizedBox(height: 8),
          Text(
            'Aún no tienes registros diarios.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Empieza con un registro breve para comparar tu descanso durante la semana.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear primer registro'),
          ),
        ],
      ),
    );
  }
}

class _InlineSleepLogFeedback extends StatelessWidget {
  const _InlineSleepLogFeedback({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color == AppColors.error
            ? AppColors.tertiaryBg
            : AppColors.successBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
