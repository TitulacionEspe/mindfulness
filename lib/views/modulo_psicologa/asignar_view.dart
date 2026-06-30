import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/asignar_tarea_view.dart';
import 'package:mindfulness_app/views/modulo_psicologa/cuestionario/conten_asignados.dart';
import 'package:mindfulness_app/views/modulo_psicologa/ia_assistant/ia_assistant_view.dart';

import '../../core/theme/app_colors.dart';
import 'cuestionario/components/cuestionario_card_pro.dart';
import 'cuestionario/components/cuestionario_stats.dart';

class AsignarView extends StatelessWidget {
  const AsignarView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Asignación de retos',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Grid de acciones principales
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _ModernActionCard(
                  title: "Asignar",
                  subtitle: "Enviar retos",
                  icon: Icons.add_task_rounded,
                  color: AppColors.mint,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AsignarTareaView()),
                  ),
                ),
                _ModernActionCard(
                  title: "Historial",
                  subtitle: "Ver asignados",
                  icon: Icons.history_edu_rounded,
                  color: AppColors.lavender,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Asignarconten()),
                  ),
                ),
                _ModernActionCard(
                  title: "Asistente IA",
                  subtitle: "Crear contenido",
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.lavender,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IAAssistantView()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Buscador moderno (estilo pill)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.outlineVariant.withValues(alpha: 0.16),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Próximamente disponible',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Estadísticas rápidas
            const CuestionarioStats(),

            const SizedBox(height: 32),

            // Título de sección con botón de filtrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividad reciente',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: AppColors.surfaceLowest,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filtrar',
                        style: TextStyle(
                          color: AppColors.surfaceLowest,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista Horizontal de Tarjetas
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  CuestionarioCardPro(
                    statusLabel: "RESPONDIDO HOY",
                    emoji: "✅",
                    patientName: "Marta Gómez",
                    testName: "Índice de Calidad...",
                    headerColor: AppColors.successBg,
                    textColor: AppColors.successText,
                  ),
                  const SizedBox(width: 16),
                  CuestionarioCardPro(
                    statusLabel: "PENDIENTE",
                    emoji: "⌛",
                    patientName: "Luis Pérez",
                    testName: "Cuestionario de...",
                    headerColor: AppColors.warningBg,
                    textColor: AppColors.warningText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ModernActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withValues(alpha: 0.12),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.08),
                  color.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
