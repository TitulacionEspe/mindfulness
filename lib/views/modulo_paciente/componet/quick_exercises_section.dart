import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/rmp_screen.dart';

import '../bubbles_exercise_view.dart';
import '../spinner_view.dart';
import '../stress_ball_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelo
// ─────────────────────────────────────────────────────────────────────────────
class QuickExerciseMock {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color accentDark;
  final Color iconBg;

  const QuickExerciseMock({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.accentDark,
    required this.iconBg,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Datos — cada tarjeta tiene su propio acento de color
// ─────────────────────────────────────────────────────────────────────────────
final List<QuickExerciseMock> mockExercises = [
  const QuickExerciseMock(
    id: '1',
    title: 'Burbujas',
    subtitle: 'Explota y relaja',
    icon: Icons.bubble_chart_rounded,
    accentColor: Color(0xFF1AAA7A),
    accentDark: Color(0xFF0D7A55),
    iconBg: Color(0xFFE1F7EF),
  ),
  const QuickExerciseMock(
    id: '2',
    title: 'Pelota\nAntiestrés',
    subtitle: 'Libera tensión',
    icon: Icons.sports_baseball_rounded,
    accentColor: Color(0xFFE8622A),
    accentDark: Color(0xFFB84010),
    iconBg: Color(0xFFFDEEE7),
  ),
  const QuickExerciseMock(
    id: '3',
    title: 'Fidget\nSpinner',
    subtitle: 'Gira y concentra',
    icon: Icons.rotate_right_rounded,
    accentColor: Color(0xFF5B6CF5),
    accentDark: Color(0xFF3A47C9),
    iconBg: Color(0xFFEEF0FE),
  ),
  const QuickExerciseMock(
    id: '4',
    title: 'RMP',
    subtitle: 'Mueve tu cuerpo',
    icon: Icons.rotate_right_rounded,
    accentColor: Color.fromARGB(255, 35, 152, 30),
    accentDark: Color(0xFF3A47C9),
    iconBg: Color(0xFFEEF0FE),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Sección principal
// ─────────────────────────────────────────────────────────────────────────────
class QuickExercisesSection extends StatelessWidget {
  const QuickExercisesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ejercicios Rápidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${mockExercises.length} disponibles',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1AAA7A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Lista horizontal
        SizedBox(
          height: 182,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: mockExercises.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) =>
                _QuickExerciseCard(exercise: mockExercises[index]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card individual — diseño moderno
// ─────────────────────────────────────────────────────────────────────────────
class _QuickExerciseCard extends StatelessWidget {
  final QuickExerciseMock exercise;
  const _QuickExerciseCard({required this.exercise});

  void _navigate(BuildContext context) {
    Widget nextView;
    switch (exercise.id) {
      case '1':
        nextView = const BubblesExerciseView();
        break;
      case '2':
        nextView = const StressBallView();
        break;
      case '3':
        nextView = const SpinnerView();
        break;

      case '4':
        nextView = const RmpScreen();

      default:
        return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => nextView));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: exercise.accentColor.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Franja de color superior
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 72,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [exercise.accentColor, exercise.accentDark],
                    ),
                  ),
                ),
              ),

              // Círculo decorativo de fondo (elemento de profundidad)
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: -35,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícono con fondo blanco flotante
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        exercise.icon,
                        size: 26,
                        color: exercise.accentColor,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Título
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Subtítulo
                    Text(
                      exercise.subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.45),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const Spacer(),

                    // Indicador de acción — flecha pequeña
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: exercise.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: exercise.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
