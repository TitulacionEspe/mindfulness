import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum PatientFeatureAction {
  routines,
  tasks,
  thoughts,
  reminders,
  habits,
  progress,
  appointments,
}

class PatientFeatureGuideView extends StatelessWidget {
  const PatientFeatureGuideView({
    super.key,
    required this.isFirstRun,
    required this.onContinue,
    required this.onFeatureAction,
  });

  final bool isFirstRun;
  final VoidCallback onContinue;
  final ValueChanged<PatientFeatureAction> onFeatureAction;

  @override
  Widget build(BuildContext context) {
    final items = _guideItems();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Icon(
              Icons.self_improvement_rounded,
              size: 44,
              color: AppColors.mint,
            ),
            const SizedBox(height: 16),
            Text(
              isFirstRun
                  ? 'Bienvenido a tu espacio de descanso'
                  : '¿Qué puedes hacer en Nidara?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'En Nidara están disponibles estas actividades de acompañamiento para cuidar tu descanso y bienestar. La aplicación no realiza diagnósticos ni reemplaza la atención profesional.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tertiaryBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip_outlined, color: AppColors.tertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tus notas privadas y registros personales son confidenciales. Usa Nidara como apoyo de bienestar y solicita ayuda profesional cuando lo necesites.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GuideActionCard(
                  item: item,
                  onTap: () => onFeatureAction(item.action),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  isFirstRun ? 'Continuar a la aplicación' : 'Volver al inicio',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_GuideItemData> _guideItems() {
    return [
      _GuideItemData(
        step: 1,
        icon: Icons.self_improvement_outlined,
        title: 'Respiración y relajación',
        description:
            'Explora respiración, mindfulness, sonidos relajantes y sesiones breves para descansar.',
        buttonLabel: 'Ir a actividades',
        action: PatientFeatureAction.routines,
        color: AppColors.mint,
      ),
      _GuideItemData(
        step: 2,
        icon: Icons.bedtime_outlined,
        title: 'Registrar hábitos de sueño',
        description:
            'Ajusta horarios, recordatorios y preferencias para organizar tu descanso nocturno.',
        buttonLabel: 'Ir a hábitos',
        action: PatientFeatureAction.habits,
        color: AppColors.mint,
      ),
      _GuideItemData(
        step: 3,
        icon: Icons.menu_book_outlined,
        title: 'Diario personal',
        description:
            'Registra notas breves y confidenciales que solo tú puedes consultar.',
        buttonLabel: 'Abrir diario',
        action: PatientFeatureAction.thoughts,
        color: AppColors.tertiary,
      ),
      _GuideItemData(
        step: 4,
        icon: Icons.calendar_month_outlined,
        title: 'Solicitar o revisar citas',
        description:
            'Envía solicitudes, confirma horarios propuestos y consulta tus citas agendadas.',
        buttonLabel: 'Gestionar citas',
        action: PatientFeatureAction.appointments,
        color: AppColors.mint,
      ),
    ];
  }
}

class _GuideActionCard extends StatelessWidget {
  const _GuideActionCard({required this.item, required this.onTap});

  final _GuideItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
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
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.step}',
                          style: TextStyle(
                            color: AppColors.buttonPrimaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7, left: 8),
                      child: Icon(item.icon, color: item.color, size: 24),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: TextStyle(
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

          if (wide) {
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: OutlinedButton(
                    onPressed: onTap,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(item.buttonLabel, maxLines: 1),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(item.buttonLabel),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GuideItemData {
  const _GuideItemData({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.action,
    required this.color,
  });

  final int step;
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final PatientFeatureAction action;
  final Color color;
}
