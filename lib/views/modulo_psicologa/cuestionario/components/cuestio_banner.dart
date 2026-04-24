import 'package:flutter/material.dart';

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
          Container(color: Colors.black.withValues(alpha: 0.3)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Caja blanca semi-transparente del título
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cuestionario",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "d:)",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Lunes, 30 Marzo 2026",
                    style: TextStyle(
                      color: Colors.white,
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
