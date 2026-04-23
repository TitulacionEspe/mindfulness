import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';
import 'sleep_habits_view.dart';
import 'profile_view.dart'; // Importamos la nueva vista

class PatientWrapper extends StatefulWidget {
  const PatientWrapper({super.key});

  @override
  State<PatientWrapper> createState() => _PatientWrapperState();
}

class _PatientWrapperState extends State<PatientWrapper> {
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<SleepHabitsViewModel>().loadSettings();
      _initialized = true;
    }
  }

  final List<Widget> _pages = [
    const Center(
      child: Text('Home', style: TextStyle(color: AppColors.textPrimary)),
    ),
    const Center(
      child: Text('Tareas', style: TextStyle(color: AppColors.textPrimary)),
    ),
    const Center(
      child: Text('Citas', style: TextStyle(color: AppColors.textPrimary)),
    ),
    const Center(
      child: Text('Logros', style: TextStyle(color: AppColors.textPrimary)),
    ),
    const ProfileView(), // Reemplazamos el placeholder por ProfileView
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sleepViewModel = context.watch<SleepHabitsViewModel>();

    if (!sleepViewModel.hasCompletedOnboarding && !sleepViewModel.isLoading) {
      return const SleepHabitsView();
    }

    if (sleepViewModel.isLoading && !sleepViewModel.hasCompletedOnboarding) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.mint)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.navBorder, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.mint,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined),
              activeIcon: Icon(Icons.task_alt),
              label: 'Tareas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Logros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
