import 'package:flutter/material.dart';

class ActiBanner extends StatelessWidget {
  const ActiBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Altura según el mockup
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        image: const DecorationImage(
          image: NetworkImage('https://media.gq.com.mx/photos/61db416eed3f3306292cf94d/16:9/w_2240,c_limit/emociones.jpg'), // Imagen de oficina/psicología
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Capa oscura para que el texto resalte
          Container(color: Colors.black.withOpacity(0.3)),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Caja blanca semi-transparente del título
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Actividades",
                        style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "d:)",
                        style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Lunes, 30 Marzo 2026",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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