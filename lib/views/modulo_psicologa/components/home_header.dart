import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName; // "Lic. Ximena"

  const HomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¡Hola Buenos Dias!",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "\"Un dia a la vez...\"", // La frase del mockup
              style: TextStyle(
                color: AppColors.accentLight, // Color de acento para la frase
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
        // Icono de Notificación con punto rojo (puedes implementarlo luego)
        Stack(
          children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 30),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              ),
            )
          ],
        ),
      ],
    );
  }
}