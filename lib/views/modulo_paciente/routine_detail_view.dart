import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/routine_model.dart';
import 'routine_session_view.dart';

class RoutineDetailView extends StatelessWidget {
  const RoutineDetailView({super.key, required this.routine});

  final RoutineModel routine;

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(routine);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: 'Volver',
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Detalle',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Text(
                    routine.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Pill(text: routine.category.label),
                      _Pill(text: routine.durationLabel),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SurfaceSection(
                    title: 'Antes de iniciar',
                    child: Text(
                      routine.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SurfaceSection(
                    title: 'Pasos de la practica',
                    child: Column(
                      children: [
                        for (var index = 0; index < steps.length; index++)
                          _StepRow(number: index + 1, text: steps[index]),
                      ],
                    ),
                  ),
                  if (routine.category == RoutineCategory.breathing) ...[
                    const SizedBox(height: 16),
                    const _SurfaceSection(
                      title: 'Cuidado',
                      child: Text(
                        'Si aparece mareo, incomodidad o ansiedad, detente y vuelve a tu respiracion natural.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RoutineSessionView(routine: routine),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonPrimaryText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Iniciar sesion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _stepsFor(RoutineModel routine) {
    return switch (routine.category) {
      RoutineCategory.breathing => const [
        'Sientate o recuestate con los hombros relajados.',
        'Sigue el circulo de respiracion sin forzar el aire.',
        'Termina con tres respiraciones naturales antes de salir.',
      ],
      RoutineCategory.relaxation => const [
        'Lleva la atencion a una zona del cuerpo.',
        'Contrae suavemente por unos segundos y suelta.',
        'Avanza con calma hasta relajar rostro, hombros, manos y piernas.',
      ],
      RoutineCategory.sleepInduction => const [
        'Reduce la luz y deja el celular en una posicion estable.',
        'Observa sensaciones corporales sin intentar cambiarlas.',
        'Cierra la practica con una frase corta de descanso.',
      ],
      RoutineCategory.soundscape => const [
        'Permanece en una postura comoda.',
        'Usa el temporizador como guia silenciosa.',
        'Vuelve a la respiracion cada vez que aparezcan distracciones.',
      ],
      RoutineCategory.all => const [],
    };
  }
}

class _SurfaceSection extends StatelessWidget {
  const _SurfaceSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.warningBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.lavender,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.lavender,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
