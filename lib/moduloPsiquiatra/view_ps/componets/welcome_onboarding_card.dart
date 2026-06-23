import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomeOnboardingCard extends StatelessWidget {
  final VoidCallback onCreateTap;

  const WelcomeOnboardingCard({super.key, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mint.withValues(alpha: 0.1),
            AppColors.lavender.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.outlineVariant.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.mint,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Bienvenida a tu espacio!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Para que tus pacientes puedan realizar actividades, primero necesitas crear tu catálogo de rutinas (respiración o sonoterapia).',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCreateTap,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('CREAR MI PRIMERA RUTINA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.buttonPrimaryText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              // Indicador animado para guiar la primera acción.
              const Positioned(right: 10, top: -45, child: _PointingHand()),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Es muy fácil y solo toma un minuto.',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointingHand extends StatefulWidget {
  const _PointingHand();

  @override
  State<_PointingHand> createState() => _PointingHandState();
}

class _PointingHandState extends State<_PointingHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Icon(
            Icons.touch_app,
            size: 60,
            color: AppColors.tertiary,
            shadows: [
              Shadow(
                blurRadius: 15,
                color: AppColors.outlineVariant,
                offset: Offset(0, 8),
              ),
            ],
          ),
        );
      },
    );
  }
}
