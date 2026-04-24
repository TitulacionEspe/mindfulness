import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/agenda_view.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/solicitudes_view.dart';

class Activitypsicologa extends StatelessWidget {
  const Activitypsicologa({super.key});

  // Función para navegar a la pantalla de Recursos
  void _goToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgendaView()),
    );

    // Navigator.push(context, MaterialPageRoute(builder: (context) => TuPantallaDeRecursos()));
  }

  // Función para navegar a la pantalla de Favoritos
  void _goToFavorites(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => TuPantallaDeFavoritos()));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SolicitudesView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón Buscar Recursos
        Expanded(
          child: _ActionButton(
            label: 'Mi agenda',
            icon: Icons.calendar_today,
            color: const Color(0xFF4A90E2), // Un azul llamativo
            onTap: () => _goToResources(context),
          ),
        ),
        const SizedBox(width: 15),
        // Botón Favoritos
        Expanded(
          child: _ActionButton(
            label: 'Solicitudes',
            icon: Icons.assignment,
            color: const Color(0xFFFF5A5F), // Un rojo suave
            onTap: () => _goToFavorites(context),
          ),
        ),
      ],
    );
  }
}

// Widget privado para el diseño de los botones
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(
        0,
        101,
        188,
        204,
      ), // Importante para que se vea el fondo del contenedor
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16,
        ), // Para que el efecto sea redondeado
        splashColor: color.withValues(
          alpha: 0.2,
        ), // Color de la onda al presionar
        highlightColor: color.withValues(
          alpha: 0.1,
        ), // Color de fondo mientras se mantiene presionado
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            // Mantenemos el fondo sutil que ya teníamos
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
