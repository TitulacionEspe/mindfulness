import 'package:flutter/material.dart';

class PsicologaNavViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // Esto "avisa" a la barra que cambie de color/pestaña
  }
}