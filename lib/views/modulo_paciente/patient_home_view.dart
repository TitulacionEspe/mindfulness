import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'thought_entries_view.dart';

class PatientHomeView extends StatelessWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'Inicio',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accesos rapidos para tus rutinas de descanso y regulacion emocional.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            _HomeQuickCard(
              icon: Icons.edit_note_rounded,
              title: 'Descarga emocional',
              subtitle: 'Registra pensamientos privados antes de dormir.',
              accent: AppColors.lavender,
              buttonLabel: 'Abrir registro',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ThoughtEntriesView()),
                );
              },
            ),
            const SizedBox(height: 12),
            _HomeQuickCard(
              icon: Icons.task_alt_rounded,
              title: 'Tareas de bienestar',
              subtitle: 'Revisa actividades asignadas y rutinas disponibles.',
              accent: AppColors.mint,
              buttonLabel: 'Ir a Tareas',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Abre la pestana Tareas en la barra inferior para continuar.',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    backgroundColor: AppColors.surfaceHigh,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeQuickCard extends StatelessWidget {
  const _HomeQuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.buttonPrimaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
