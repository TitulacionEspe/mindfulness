import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import './componet/action_button.dart';
import 'patient_appointments_view.dart';

class CitaCont extends StatelessWidget {
  const CitaCont({super.key});

  void _goToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientAppointmentsView(
          initialTab: PatientAppointmentsTab.requests,
          openRequestComposerOnStart: true,
        ),
      ),
    );
  }

  void _goToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientAppointmentsView(
          initialTab: PatientAppointmentsTab.requests,
        ),
      ),
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
          label: 'Mis citas',
          icon: Icons.event_note_rounded,
          color: AppColors.mint,
          onTap: () => _goToFavorites(context),
        ),
      ],
    );
  }
}
