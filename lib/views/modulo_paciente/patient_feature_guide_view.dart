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
                  : '¿Qué puedes hacer en el sistema?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Esta aplicación te acompaña con rutinas de relajación, registro personal, hábitos de sueño, recordatorios, progreso y citas con Psicología. No realiza diagnósticos ni reemplaza la atención profesional.',
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
                      'Tus pensamientos y registros personales son privados. Usa la app como apoyo de bienestar y solicita ayuda profesional cuando lo necesites.',
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
                  isFirstRun ? 'Continuar al sistema' : 'Volver al inicio',
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
        icon: Icons.self_improvement_outlined,
        title: 'Iniciar rutinas de relajación',
        description:
            'Explora respiración, mindfulness, sonidos relajantes y sesiones breves para descansar.',
        buttonLabel: 'Probar rutinas',
        action: PatientFeatureAction.routines,
        color: AppColors.mint,
      ),
      _GuideItemData(
        icon: Icons.task_alt_outlined,
        title: 'Revisar tareas asignadas',
        description:
            'Consulta actividades enviadas por la psicóloga y completa sesiones guiadas.',
        buttonLabel: 'Ver tareas',
        action: PatientFeatureAction.tasks,
        color: AppColors.lavender,
      ),
      _GuideItemData(
        icon: Icons.edit_note_rounded,
        title: 'Registrar pensamientos',
        description:
            'Realiza una descarga emocional privada antes de dormir o cuando tengas preocupaciones.',
        buttonLabel: 'Registrar ahora',
        action: PatientFeatureAction.thoughts,
        color: AppColors.tertiary,
      ),
      _GuideItemData(
        icon: Icons.notifications_active_outlined,
        title: 'Configurar recordatorios',
        description:
            'Crea avisos para rutinas nocturnas, respiración breve o hábitos de descanso.',
        buttonLabel: 'Crear aviso',
        action: PatientFeatureAction.reminders,
        color: AppColors.lavender,
      ),
      _GuideItemData(
        icon: Icons.bedtime_outlined,
        title: 'Registrar hábitos de sueño',
        description:
            'Ajusta horarios, preferencias de descanso y datos básicos de tu rutina nocturna.',
        buttonLabel: 'Ir a hábitos',
        action: PatientFeatureAction.habits,
        color: AppColors.mint,
      ),
      _GuideItemData(
        icon: Icons.trending_up_outlined,
        title: 'Consultar progreso',
        description:
            'Revisa sesiones, emociones registradas y continuidad de uso sin interpretación clínica.',
        buttonLabel: 'Ver progreso',
        action: PatientFeatureAction.progress,
        color: AppColors.tertiary,
      ),
      _GuideItemData(
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Icon(item.icon, color: item.color),
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
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.action,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final PatientFeatureAction action;
  final Color color;
}
