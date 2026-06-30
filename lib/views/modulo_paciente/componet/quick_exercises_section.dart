import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/rmp_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../bubbles_exercise_view.dart';
import '../calm_drawing_view.dart';
import '../frecuencias/sound_therapy_selector_screen.dart';
import '../spinner_view.dart';
import '../stress_ball_view.dart';

class QuickExerciseMock {
  const QuickExerciseMock({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.iconBg,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color iconBg;
}

class QuickExercisesSection extends StatelessWidget {
  const QuickExercisesSection({super.key});

  List<QuickExerciseMock> _exercises() {
    return [
      QuickExerciseMock(
        id: 'sound_therapy',
        title: 'Terapia de sonido',
        subtitle: 'Frecuencias curativas',
        icon: Icons.graphic_eq_rounded,
        accentColor: AppColors.lavender,
        iconBg: AppColors.warningBg,
      ),
      QuickExerciseMock(
        id: 'bubbles',
        title: 'Burbujas',
        subtitle: 'Toca y suelta',
        icon: Icons.bubble_chart_rounded,
        accentColor: AppColors.mint,
        iconBg: AppColors.successBg,
      ),
      QuickExerciseMock(
        id: 'ball',
        title: 'Pelota antiestrés',
        subtitle: 'Arrastra y libera',
        icon: Icons.sports_baseball_rounded,
        accentColor: AppColors.tertiary,
        iconBg: AppColors.tertiaryBg,
      ),
      QuickExerciseMock(
        id: 'spinner',
        title: 'Fidget spinner',
        subtitle: 'Gira con calma',
        icon: Icons.rotate_right_rounded,
        accentColor: AppColors.lavender,
        iconBg: AppColors.warningBg,
      ),
      QuickExerciseMock(
        id: 'rmp',
        title: 'Relajación muscular',
        subtitle: 'Tensa y descansa',
        icon: Icons.accessibility_new_rounded,
        accentColor: AppColors.mint,
        iconBg: AppColors.successBg,
      ),
      QuickExerciseMock(
        id: 'drawing',
        title: 'Dibujo calmado',
        subtitle: 'Traza y respira',
        icon: Icons.brush_outlined,
        accentColor: AppColors.lavender,
        iconBg: AppColors.warningBg,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _exercises();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ejercicios rápidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${exercises.length} disponibles',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 198,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: exercises.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _QuickExerciseCard(exercise: exercises[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _QuickExerciseCard extends StatelessWidget {
  const _QuickExerciseCard({required this.exercise});

  final QuickExerciseMock exercise;

  void _navigate(BuildContext context) {
    final Widget nextView = switch (exercise.id) {
      'sound_therapy' => const SoundTherapySelectorScreen(),
      'bubbles' => const BubblesExerciseView(),
      'ball' => const StressBallView(),
      'spinner' => const SpinnerView(),
      'rmp' => const RmpScreen(),
      'drawing' => const CalmDrawingView(),
      _ => const CalmDrawingView(),
    };

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => nextView));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: exercise.title,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _navigate(context),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 148,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: exercise.iconBg,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: exercise.accentColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    exercise.icon,
                    size: 24,
                    color: exercise.accentColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  exercise.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: exercise.accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: exercise.accentColor,
                    ),
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
