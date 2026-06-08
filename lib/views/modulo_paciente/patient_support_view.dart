import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'componet/patient_navigation_helper.dart';

class PatientSupportView extends StatelessWidget {
  const PatientSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Ayuda y soporte',
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SupportCard(
            icon: Icons.shield_outlined,
            title: 'Privacidad y cifrado',
            subtitle:
                'Tus registros de autopercepción y las sesiones de relajación se guardan de forma segura para mostrarte métricas de progreso. Las notas de pensamientos privados están cifradas y son 100% privadas; nadie más, ni siquiera los profesionales de psicología, pueden leerlas.',
          ),
          const SizedBox(height: 12),
          _SupportCard(
            icon: Icons.notifications_active_outlined,
            title: 'Ajustes de alertas locales',
            subtitle:
                'Puedes programar alertas diarias para ayudarte a iniciar tus rutinas nocturnas. Si no recibes las notificaciones en la hora programada, asegúrate de activar los permisos de notificación de la aplicación en los ajustes de tu celular.',
          ),
          const SizedBox(height: 12),
          _SupportCard(
            icon: Icons.calendar_month_outlined,
            title: 'Solicitud de citas de psicología',
            subtitle:
                'Dirígete al apartado de "Citas con Psicología", pulsa el botón "+" y detalla tu motivo. La psicóloga asignada recibirá tu solicitud y te propondrá un horario que podrás confirmar directamente desde la aplicación.',
          ),
          const SizedBox(height: 12),
          _SupportCard(
            icon: Icons.health_and_safety_outlined,
            title: 'Emergencia emocional',
            subtitle:
                'Si estás pasando por una crisis o momento muy difícil, recuerda que no estás solo. Puedes llamar de forma gratuita y confidencial a la línea nacional de salud mental 171 (opción 6) o al servicio de emergencias 911.',
            accentColor: AppColors.error,
          ),
          const SizedBox(height: 12),
          _SupportCard(
            icon: Icons.contact_support_outlined,
            title: 'Contacto de soporte técnico',
            subtitle:
                'Si experimentas fallas en la aplicación o errores de carga, puedes escribir a:\nsoporte.nidara@espe.edu.ec\n\nNuestro equipo te responderá en un plazo estimado de 24 a 48 horas hábiles.',
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final themeColor = accentColor ?? AppColors.mint;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColor),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
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
