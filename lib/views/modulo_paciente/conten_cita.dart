import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_paciente/mis_citas_view.dart';
import 'package:mindfulness_app/views/modulo_paciente/solicitar_cita_view.dart';

import '../../core/theme/app_colors.dart';
import './componet/action_button.dart';

class CitaCont extends StatelessWidget {
  const CitaCont({super.key});

  void _goToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SolicitarCitaView()),
    );
  }

  void _goToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MisCitasView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.9,
      children: [
        ActionButton(
          label: 'Solicitar Cita',
          icon: Icons.calendar_month_rounded,
          color: AppColors.lavender,
          onTap: () => _goToResources(context),
        ),
        ActionButton(
          label: 'Mis Citas',
          icon: Icons.event_note_rounded,
          color: AppColors.mint,
          onTap: () => _goToFavorites(context),
        ),
      ],
    );
  }
}
