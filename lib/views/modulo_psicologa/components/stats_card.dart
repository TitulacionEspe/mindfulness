import 'package:flutter/material.dart';
// Ajusta la ruta si es necesario

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String titleLine1; // "Pacientes"
  final String titleLine2; // "totales"
  final String value; // "20"
  final Color accentColor; // El color del icono y detalles

  const StatsCard({
    super.key,
    required this.icon,
    required this.titleLine1,
    required this.titleLine2,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para que se adapte al tamaño de la pantalla (Infinix)
    return LayoutBuilder(
      builder: (context, constraints) {
        

        return Container(
          // Diseño de la tarjeta blanca según el mockup
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white, // Fondo blanco según imagen
            borderRadius: BorderRadius.circular(25), // Bordes muy redondeados
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FILA SUPERIOR: Icono de color + Número Grande
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32, // Número grande
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(), // Empuja el texto hacia abajo
              // TEXTO INFERIOR: Dos líneas en negro
              Text(
                titleLine1,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                titleLine2,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
