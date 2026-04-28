import 'package:flutter/material.dart';
import '../../../moduloTareas/model/assignment_model.dart';

class TareaCardWidget extends StatelessWidget {
  final Assignment tarea;
  final bool isPending;
  final VoidCallback onTap;

  const TareaCardWidget({
    super.key,
    required this.tarea,
    required this.isPending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Definir colores basados en el estado
    final Color color = isPending ? Colors.indigo : Colors.teal;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icono de estado
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.play_circle_fill : Icons.check_circle,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Textos (Título y Descripción)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarea.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tarea.description.isNotEmpty
                        ? tarea.description
                        : "Sin descripción",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Acción o indicador de completado
            if (isPending)
              SizedBox(
                height: 36,
                width: 60, // Ancho fijo para evitar problemas de layout
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "IR",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              const Icon(Icons.verified, color: Colors.green, size: 28),
          ],
        ),
      ),
    );
  }
}
