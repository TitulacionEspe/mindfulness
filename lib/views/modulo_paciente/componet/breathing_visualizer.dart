import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum BreathingShape { circle, square, heart, spiral }

class BreathingVisualizer extends StatelessWidget {
  final Animation<double> animation;
  final String label;
  final BreathingShape shape;

  const BreathingVisualizer({
    super.key,
    required this.animation,
    required this.label,
    this.shape = BreathingShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculamos tamaños dinámicos basados en el espacio disponible
            final availableHeight = constraints.maxHeight;
            final textHeight = 40.0;
            final gapHeight = availableHeight > 400 ? 40.0 : 20.0;

            // La figura tomará el espacio restante, con un tope máximo de 300
            final shapeSize = (availableHeight - textHeight - gapHeight - 40)
                .clamp(100.0, 300.0);

            return Stack(
              alignment: Alignment.center,
              children: [
                // Fondo con degradado
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _getShapeColor().withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                        center: Alignment.center,
                        radius: 1.2,
                      ),
                    ),
                  ),
                ),

                // Contenido central
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Texto fuera de la figura
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: _getShapeColor().withValues(alpha: 0.8),
                        fontSize: availableHeight > 400 ? 28 : 20,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 6.0,
                      ),
                    ),
                    SizedBox(height: gapHeight),
                    CustomPaint(
                      painter: _BreathingPainter(
                        progress: animation.value,
                        shape: shape,
                        color: _getShapeColor(),
                      ),
                      child: SizedBox(width: shapeSize, height: shapeSize),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getShapeColor() {
    return switch (shape) {
      BreathingShape.circle => AppColors.mint,
      BreathingShape.square => AppColors.lavender,
      BreathingShape.heart => AppColors.tertiary,
      BreathingShape.spiral => AppColors.successText,
    };
  }
}

class _BreathingPainter extends CustomPainter {
  final double progress;
  final BreathingShape shape;
  final Color color;

  _BreathingPainter({
    required this.progress,
    required this.shape,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.3;
    final scaleFactor = 0.6 + (progress * 0.4); // De 60% a 100% de tamaño
    final currentRadius = baseRadius * scaleFactor;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Efecto de resplandor (Glow)
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * progress)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * progress);

    switch (shape) {
      case BreathingShape.circle:
        _drawCircle(canvas, center, currentRadius, shadowPaint, paint);
        break;
      case BreathingShape.square:
        _drawSquare(canvas, center, currentRadius, shadowPaint, paint);
        break;
      case BreathingShape.heart:
        _drawHeart(canvas, center, currentRadius, shadowPaint, paint);
        break;
      case BreathingShape.spiral:
        _drawSpiral(canvas, center, currentRadius, shadowPaint, paint);
        break;
    }
  }

  void _drawCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint shadow,
    Paint fill,
  ) {
    canvas.drawCircle(center, radius + 10, shadow);
    canvas.drawCircle(center, radius, fill);
    // Borde más brillante
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawSquare(
    Canvas canvas,
    Offset center,
    double radius,
    Paint shadow,
    Paint fill,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.2));

    canvas.drawRRect(rrect.inflate(10), shadow);
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawHeart(
    Canvas canvas,
    Offset center,
    double radius,
    Paint shadow,
    Paint fill,
  ) {
    final path = Path();
    final width = radius * 2.5;
    final height = radius * 2.5;

    path.moveTo(center.dx, center.dy + height * 0.35);
    path.cubicTo(
      center.dx + width * 0.5,
      center.dy - height * 0.45,
      center.dx + width * 1.1,
      center.dy + height * 0.25,
      center.dx,
      center.dy + height * 0.85,
    );
    path.cubicTo(
      center.dx - width * 1.1,
      center.dy + height * 0.25,
      center.dx - width * 0.5,
      center.dy - height * 0.45,
      center.dx,
      center.dy + height * 0.35,
    );

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawSpiral(
    Canvas canvas,
    Offset center,
    double radius,
    Paint shadow,
    Paint fill,
  ) {
    // Para la espiral hacemos una animación de rotación también
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 2);

    final spiralPath = Path();
    for (double i = 0; i < radius * 1.5; i += 0.5) {
      double angle = 0.1 * i;
      double x = (0.2 * i) * math.cos(angle);
      double y = (0.2 * i) * math.sin(angle);
      if (i == 0) {
        spiralPath.moveTo(x, y);
      } else {
        spiralPath.lineTo(x, y);
      }
    }

    final spiralPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * progress
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(spiralPath, shadow);
    canvas.drawPath(spiralPath, spiralPaint);
    canvas.restore();

    // Dibujamos un círculo de fondo sutil
    canvas.drawCircle(
      center,
      radius * 0.8,
      fill..color = color.withValues(alpha: 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant _BreathingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.shape != shape;
  }
}
