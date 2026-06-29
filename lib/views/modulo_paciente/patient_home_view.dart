import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'patient_feature_guide_view.dart';

class PatientHomeView extends StatelessWidget {
  const PatientHomeView({super.key, required this.onFeatureAction});

  final ValueChanged<PatientFeatureAction> onFeatureAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activities = [
      _HomeActivityData(
        number: 1,
        icon: Icons.self_improvement_outlined,
        title: 'Realizar actividades de respiración y relajación',
        description:
            'Encuentra ejercicios guiados para respirar con calma, relajarte y prepararte para el descanso.',
        buttonLabel: 'Ir a actividades',
        action: PatientFeatureAction.routines,
        color: AppColors.mint,
      ),
      _HomeActivityData(
        number: 2,
        icon: Icons.bedtime_outlined,
        title: 'Registrar hábitos de sueño',
        description:
            'Organiza horarios, recordatorios y preferencias para preparar mejor tu descanso.',
        buttonLabel: 'Ir a hábitos',
        action: PatientFeatureAction.habits,
        color: AppColors.lavender,
      ),
      _HomeActivityData(
        number: 3,
        icon: Icons.edit_note_rounded,
        title: 'Registrar notas en tu diario personal',
        description:
            'Escribe notas breves y confidenciales para ordenar ideas o registrar cómo te sientes.',
        buttonLabel: 'Abrir diario',
        action: PatientFeatureAction.thoughts,
        color: AppColors.tertiary,
      ),
      _HomeActivityData(
        number: 4,
        icon: Icons.calendar_month_outlined,
        title: 'Planificar una cita con un profesional.',
        description:
            'Solicita, revisa o confirma una cita cuando necesites acompañamiento del personal de Psicología.',
        buttonLabel: 'Planificar cita',
        action: PatientFeatureAction.appointments,
        color: AppColors.mint,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido a Nidara, tu espacio para tu descanso placentero.',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'En esta aplicación tú podrás realizar las siguientes actividades:',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...activities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HomeActivityCard(
                  data: activity,
                  onTap: () => onFeatureAction(activity.action),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _ConfidentialityCard(
              text:
                  'Tus datos personales e información que registres en la aplicación son confidenciales.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActivityCard extends StatelessWidget {
  const _HomeActivityCard({required this.data, required this.onTap});

  final _HomeActivityData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberedIcon(data: data),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final button = SizedBox(
            height: 48,
            width: wide ? 176 : double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(data.buttonLabel, maxLines: 1),
              ),
            ),
          );

          if (wide) {
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 12),
                button,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [content, const SizedBox(height: 14), button],
          );
        },
      ),
    );
  }
}

class _NumberedIcon extends StatelessWidget {
  const _NumberedIcon({required this.data});

  final _HomeActivityData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: data.color,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${data.number}',
                style: TextStyle(
                  color: AppColors.buttonPrimaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Icon(data.icon, color: data.color, size: 25),
          ),
        ],
      ),
    );
  }
}

class _ConfidentialityCard extends StatelessWidget {
  const _ConfidentialityCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Aviso de confidencialidad',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.tertiaryBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.privacy_tip_outlined, color: AppColors.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActivityData {
  const _HomeActivityData({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.action,
    required this.color,
  });

  final int number;
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final PatientFeatureAction action;
  final Color color;
}
