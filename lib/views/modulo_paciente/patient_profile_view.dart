import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/consent_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/patient_history_viewmodel.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';
import 'patient_accessibility_view.dart';
import 'patient_history_view.dart';
import 'patient_support_view.dart';

class PatientProfileView extends StatelessWidget {
  const PatientProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final userName =
        auth.currentUser?.userMetadata?['full_name'] as String? ?? 'Paciente';
    final userEmail = auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(
              'Perfil',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tu información, privacidad y opciones de apoyo dentro de Nidara.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _ProfileHeaderCard(userName: userName, userEmail: userEmail),
            const SizedBox(height: 16),
            _ProfileActionTile(
              icon: Icons.trending_up_rounded,
              title: 'Progreso',
              description:
                  'Revisa tu historial personal, sesiones y continuidad de uso.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const PatientHistoryView(showBackButton: true),
                ),
              ),
            ),
            _ProfileActionTile(
              icon: Icons.accessibility_new_rounded,
              title: 'Accesibilidad',
              description:
                  'Ajusta el tamaño del texto y activa apoyo visual para daltonismo.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PatientAccessibilityView(),
                ),
              ),
            ),
            _ProfileActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacidad y consentimiento',
              description:
                  'Consulta el consentimiento informado y los límites de uso responsable.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ConsentScreen(readOnly: true),
                ),
              ),
            ),
            _ProfileActionTile(
              icon: Icons.help_outline_rounded,
              title: 'Ayuda o soporte',
              description:
                  'Encuentra orientación básica para usar la aplicación y solicitar apoyo.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PatientSupportView()),
              ),
            ),
            _ProfileActionTile(
              icon: Icons.info_outline_rounded,
              title: 'Acerca de Nidara',
              description:
                  'Conoce el propósito de la aplicación y sus desarrolladores.',
              onTap: () => _showAboutNidara(context),
            ),
            _ProfileActionTile(
              icon: Icons.restart_alt_rounded,
              title: 'Reiniciar progreso',
              description:
                  'Restablece tus sesiones, métricas y registros para empezar de cero.',
              iconColor: AppColors.error,
              iconBgColor: AppColors.error.withValues(alpha: 0.15),
              onTap: () => _showResetProgressDialog(context),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async => auth.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetProgressDialog(BuildContext context) {
    var resetSleepHabits = false;
    var deleteThoughts = false;
    var isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reiniciar progreso',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Se restablecerán tus sesiones de actividad completadas, autoevaluaciones y registros de sueño para que comiences desde el día 1.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.mint,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tu cuenta de usuario, tus consentimientos éticos y tus citas no se verán afectadas.',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Opciones adicionales:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isSubmitting
                          ? null
                          : () {
                              setDialogState(() {
                                resetSleepHabits = !resetSleepHabits;
                              });
                            },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: resetSleepHabits,
                              onChanged: isSubmitting
                                  ? null
                                  : (val) {
                                      setDialogState(() {
                                        resetSleepHabits = val ?? false;
                                      });
                                    },
                              activeColor: AppColors.mint,
                              checkColor: AppColors.buttonPrimaryText,
                            ),
                            Expanded(
                              child: Text(
                                'Reconfigurar mis hábitos de sueño (horarios)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: isSubmitting
                          ? null
                          : () {
                              setDialogState(() {
                                deleteThoughts = !deleteThoughts;
                              });
                            },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: deleteThoughts,
                              onChanged: isSubmitting
                                  ? null
                                  : (val) {
                                      setDialogState(() {
                                        deleteThoughts = val ?? false;
                                      });
                                    },
                              activeColor: AppColors.mint,
                              checkColor: AppColors.buttonPrimaryText,
                            ),
                            Expanded(
                              child: Text(
                                'Borrar también notas de mi diario personal',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          final messenger = ScaffoldMessenger.of(context);
                          final historyVm =
                              context.read<PatientHistoryViewModel>();
                          final sleepVm = context.read<SleepHabitsViewModel>();

                          final success = await historyVm.resetProgress(
                            resetSleepHabits: resetSleepHabits,
                            deleteThoughts: deleteThoughts,
                          );

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }

                          if (!context.mounted) return;

                          if (success) {
                            if (resetSleepHabits) {
                              sleepVm.reset();
                            }
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Progreso reiniciado correctamente. ¡Mucho ánimo en este nuevo comienzo!',
                                ),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  historyVm.errorMessage ??
                                      'No se pudo reiniciar el progreso.',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : const Text(
                          'Reiniciar ahora',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutNidara(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/img/Icono_Minfulnes.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Acerca de Nidara',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nidara es una aplicación de acompañamiento para mindfulness e higiene del sueño. No realiza diagnósticos ni reemplaza la atención profesional.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Desarrollador',
                  style: TextStyle(
                    color: AppColors.lavender,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mickel Franchesco Aragón, estudiante de Ingeniería de Software. Proyecto realizado como parte del proceso de titulación.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.userName, required this.userEmail});

  final String userName;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.person_outline_rounded, color: AppColors.mint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.iconColor,
    this.iconBgColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.lavender;
    final effectiveIconBgColor = iconBgColor ?? AppColors.warningBg;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: effectiveIconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: effectiveIconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
