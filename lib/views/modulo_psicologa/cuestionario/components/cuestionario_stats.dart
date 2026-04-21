import 'package:flutter/material.dart';

class CuestionarioStats extends StatelessWidget {
  const CuestionarioStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatBox('🔄', 'Respuestas Recientes', '(5)'),
        const SizedBox(width: 15),
        _buildStatBox('⌛', 'Pendientes', '(12)'),
      ],
    );
  }

  Widget _buildStatBox(String emoji, String title, String count) {
    return Expanded(
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              count,
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
