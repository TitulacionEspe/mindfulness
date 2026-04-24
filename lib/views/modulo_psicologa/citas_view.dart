import 'package:flutter/material.dart';
import 'package:mindfulness_app/views/modulo_psicologa/citas/componet/baner_cita.dart';
import 'package:mindfulness_app/views/modulo_psicologa/citas/componet/button_cita.dart';

import '../../core/theme/app_colors.dart';

class CitasView extends StatelessWidget {
  const CitasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Usamos SafeArea para que el contenido no choque con el notch del celular
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerCita(),

              // Título de la sección
              const SizedBox(height: 5),
              const Text(
                "Organiza tu agenda del día",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // 1. TU COMPONENTE ACTUAL (El Grid de botones)
              const Activitypsicologa(),

              const SizedBox(height: 30),

              // 2. ESPACIO PREPARADO PARA OTROS COMPONENTES
              // Aquí puedes llamar a otros widgets en el futuro
              _buildSectionTitle("Próximas Citas"),
              const SizedBox(height: 10),

              // Ejemplo de un componente futuro (un placeholder)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: const Center(
                  child: Text("Aquí irán más componentes en el futuro"),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para títulos de futuras secciones
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(221, 84, 201, 201),
      ),
    );
  }
}
