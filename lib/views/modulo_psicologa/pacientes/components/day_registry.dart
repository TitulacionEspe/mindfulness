import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DayRegistry extends StatelessWidget {
  const DayRegistry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.sectionWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Registro de días", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBlack)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'].map((day) {
              bool isToday = day == 'Mie'; // Ejemplo
              return Column(
                children: [
                  Text(day, style: TextStyle(fontSize: 12, color: isToday ? AppColors.accent : Colors.grey)),
                  const SizedBox(height: 5),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: isToday ? AppColors.accent : Colors.grey.shade200,
                    child: Text("15", style: TextStyle(fontSize: 12, color: isToday ? Colors.white : Colors.black)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}