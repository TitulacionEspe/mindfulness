import 'package:flutter/material.dart';

class CuestionarioCard extends StatelessWidget {
  final String title;
  final String duration;

  const CuestionarioCard({
    super.key, 
    required this.title, 
    required this.duration
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, // CAJA BLANCA como pediste
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined, color: Colors.blue, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: Colors.black87
                  ),
                ),
                Text(
                  "Tiempo est.: $duration",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.add_circle_outline, color: Colors.green),
        ],
      ),
    );
  }
}