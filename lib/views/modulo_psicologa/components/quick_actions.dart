import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Acciones Rápidas",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildActionItem("Asignar Nueva Actividad", Icons.arrow_forward, Colors.white),
        _buildActionItem("Revisar Cuestionarios (12)", Icons.arrow_forward, Colors.white),
        _buildActionItem("Atender Alertas (2)", Icons.arrow_forward, const Color(0xFFFFF1C1), isAlert: true),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color bgColor, {bool isAlert = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isAlert) const Icon(Icons.warning, color: Colors.orange, size: 20),
              if (isAlert) const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isAlert ? Colors.brown : Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Icon(icon, color: isAlert ? Colors.orange : Colors.black26, size: 18),
        ],
      ),
    );
  }
}