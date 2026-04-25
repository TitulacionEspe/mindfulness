import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PacientBar extends StatelessWidget {
  const PacientBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Altura según el mockup
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        image: DecorationImage(
          image: NetworkImage(
            'https://jftnjpnwcdmndnfdhtld.supabase.co/storage/v1/object/public/tesis/peaceful-sleep-moon.jpg',
          ), // Imagen de oficina/psicología
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 1. Capa oscura con la nueva función .withValues (Para pasar el CI)
          Container(color: AppColors.background.withValues(alpha: 0.3)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Caja blanca semi-transparente del título
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    // 2. Usando .withValues aquí también
                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Panel General",
                        style: TextStyle(
                          color: AppColors.buttonPrimaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Psicologares",
                        style: TextStyle(
                          color: AppColors.mint,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Lunes, 30 Marzo 2026",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
