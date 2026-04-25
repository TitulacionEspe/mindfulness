import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';

class CuestioBanner extends StatelessWidget {
  const CuestioBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Altura según el mockup
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        image: const DecorationImage(
          image: NetworkImage(
            'https://jftnjpnwcdmndnfdhtld.supabase.co/storage/v1/object/public/tesis/peaceful-sleep-moon.jpg',
          ), // Imagen de oficina/psicología
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Capa oscura para que el texto resalte
          Container(color: AppColors.textPrimary.withValues(alpha: 0.3)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Caja blanca semi-transparente del título
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cuestionario",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "d:)",
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
                      color: AppColors.surfaceLowest,
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
