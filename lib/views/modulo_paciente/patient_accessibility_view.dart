import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/accessibility/accessibility_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/accessibility_viewmodel.dart';

class PatientAccessibilityView extends StatelessWidget {
  const PatientAccessibilityView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccessibilityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Accesibilidad',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Personaliza la lectura',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajusta el tamaño del texto y activa una paleta pensada para daltonismo rojo-verde.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _AccessibilityCard(
              title: 'Tamaño del texto',
              description:
                  'Elige una escala cómoda. Nidara limita el tamaño para cuidar la lectura y evitar que las pantallas se rompan.',
              child: _FontScaleSelector(
                selectedScale: viewModel.fontScale,
                isLoading: viewModel.isLoading,
                onSelected: (scale) async {
                  await context.read<AccessibilityViewModel>().setFontScale(
                    scale,
                  );
                  if (context.mounted) _showFeedback(context);
                },
              ),
            ),
            const SizedBox(height: 14),
            _AccessibilityCard(
              title: 'Modo daltonismo',
              description:
                  'Cambia los acentos visuales para que los estados importantes no dependan solo del rojo o verde.',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Soporte rojo-verde',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  viewModel.isColorBlindModeEnabled
                      ? 'Modo daltonismo activo.'
                      : 'Usando paleta normal.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                value: viewModel.isColorBlindModeEnabled,
                activeThumbColor: AppColors.buttonPrimary,
                activeTrackColor: AppColors.successBg,
                onChanged: viewModel.isLoading
                    ? null
                    : (enabled) async {
                        await context
                            .read<AccessibilityViewModel>()
                            .toggleColorBlindMode(enabled);
                        if (context.mounted) _showFeedback(context);
                      },
              ),
            ),
            const SizedBox(height: 14),
            if (viewModel.errorMessage != null)
              _FeedbackBanner(
                text: viewModel.errorMessage!,
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
                background: AppColors.tertiaryBg,
              ),
            _AccessibilityPreviewCard(viewModel: viewModel),
          ],
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Preferencia de accesibilidad actualizada.'),
        ),
      );
  }
}

class _AccessibilityCard extends StatelessWidget {
  const _AccessibilityCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FontScaleSelector extends StatelessWidget {
  const _FontScaleSelector({
    required this.selectedScale,
    required this.isLoading,
    required this.onSelected,
  });

  final double selectedScale;
  final bool isLoading;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AccessibilityPreferences.allowedFontScales.map((scale) {
        final isSelected = (selectedScale - scale).abs() < 0.001;
        return _FontScaleButton(
          scale: scale,
          isSelected: isSelected,
          isEnabled: !isLoading,
          onSelected: onSelected,
        );
      }).toList(),
    );
  }
}

class _FontScaleButton extends StatelessWidget {
  const _FontScaleButton({
    required this.scale,
    required this.isSelected,
    required this.isEnabled,
    required this.onSelected,
  });

  final double scale;
  final bool isSelected;
  final bool isEnabled;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final label = AccessibilityPreferences.labelForFontScale(scale);
    final percent = '${(scale * 100).round()}%';

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label, $percent',
      child: InkWell(
        onTap: isEnabled ? () => onSelected(scale) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 92),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.successBg : AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.buttonPrimary : AppColors.outline,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.buttonPrimary
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                percent,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessibilityPreviewCard extends StatelessWidget {
  const _AccessibilityPreviewCard({required this.viewModel});

  final AccessibilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.lavender),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vista previa',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Así se verán los textos, botones y estados dentro de la aplicación.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _PreviewStatusChip(
                icon: Icons.check_circle_outline_rounded,
                label: 'Completado',
                tone: _PreviewTone.success,
              ),
              _PreviewStatusChip(
                icon: Icons.schedule_rounded,
                label: 'Pendiente',
                tone: _PreviewTone.warning,
              ),
              _PreviewStatusChip(
                icon: Icons.priority_high_rounded,
                label: 'Revisar',
                tone: _PreviewTone.alert,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.touch_app_rounded),
              label: Text(
                viewModel.isColorBlindModeEnabled
                    ? 'Botón con modo daltonismo'
                    : 'Botón de ejemplo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PreviewTone { success, warning, alert }

class _PreviewStatusChip extends StatelessWidget {
  const _PreviewStatusChip({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final _PreviewTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      _PreviewTone.success => (AppColors.successBg, AppColors.buttonPrimary),
      _PreviewTone.warning => (AppColors.warningBg, AppColors.lavender),
      _PreviewTone.alert => (
        AppColors.tertiaryBg,
        AppColors.tertiaryOnContainer,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 18),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.text,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
