import 'package:flutter/material.dart';

class ActivitySearch extends StatelessWidget {
  const ActivitySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          icon: Text("🔍", style: TextStyle(fontSize: 18)),
          hintText: 'Buscar actividades...',
          hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}