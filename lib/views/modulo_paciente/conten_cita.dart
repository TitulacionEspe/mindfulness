import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/mis_citas_view.dart';
import 'package:mindfulness_app/views/modulo_paciente/solicitar_cita_view.dart';

import './componet/action_button.dart'; // Importas el componente visual

class CitaCont extends StatelessWidget {
  const CitaCont({super.key});

  void _goToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SolicitarCitaView()),
    );
  }

  void _goToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MisCitasView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Esqueleto: Cuadrícula que sostiene los componentes
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, // 2 columnas como en la foto
      crossAxisSpacing: 15, // Espacio horizontal entre cards
      mainAxisSpacing: 15, // Espacio vertical
      childAspectRatio: 0.9, // Para que sean ligeramente más altos que anchos
      children: [
        ActionButton(
          label: 'Solicitar Cita',
          icon: Icons.abc_sharp, // Icono nuevo
          color: const Color(0xFFFF5A8D), // Color rosado/fucsia de la foto
          onTap: () => _goToResources(context),
        ),
        ActionButton(
          label: 'Mis Citas',
          icon: Icons.event_note_rounded, // Icono nuevo
          color: const Color(0xFFFFA726), // Color naranja de la foto
          onTap: () => _goToFavorites(context),
        ),
      ],
    );
  }
}
