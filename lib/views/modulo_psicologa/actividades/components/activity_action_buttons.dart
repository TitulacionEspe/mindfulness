import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/favoritos_view.dart';
import 'package:mindfulness_app/moduloPsiquiatra/view_ps/recursos.dart';

class ActivityActionButtons extends StatelessWidget {
  const ActivityActionButtons({super.key});

  // Función para navegar a la pantalla de Recursos
  void _goToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecursosView()),
    );

    // Navigator.push(context, MaterialPageRoute(builder: (context) => TuPantallaDeRecursos()));
    print("Navegando a Buscar Recursos...");
  }

  // Función para navegar a la pantalla de Favoritos
  void _goToFavorites(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => TuPantallaDeFavoritos()));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritosView()),
    );

    print("Navegando a Favoritos...");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón Buscar Recursos
        Expanded(
          child: _ActionButton(
            label: 'Buscar Recursos',
            icon: Icons.search,
            color: AppColors.lavender, // Un azul llamativo
            onTap: () => _goToResources(context),
          ),
        ),
        SizedBox(width: 15),
        // Botón Favoritos
        Expanded(
          child: _ActionButton(
            label: 'Biblioteca',
            icon: Icons.collections_bookmark,
            color: AppColors.error, // Un rojo suave
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
      color: Colors
          .transparent, // Importante para que se vea el fondo del contenedor
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
