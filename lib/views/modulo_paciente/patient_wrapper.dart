import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/presentation/widgets/nocturne_bottom_nav.dart';
import '../../core/presentation/widgets/nocturne_drawer.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/consent_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/patient_history_viewmodel.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';
import 'chat_view.dart';
import 'patient_history_view.dart';
import 'patient_home_view.dart';
import 'patient_support_view.dart';
import 'profile_view.dart';
import 'reminders_view.dart';
import 'routines_library_view.dart';
import 'sleep_habits_view.dart';

class PatientWrapper extends StatefulWidget {
  const PatientWrapper({super.key});

  @override
  State<PatientWrapper> createState() => _PatientWrapperState();
}

class _PatientWrapperState extends State<PatientWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PatientHomeView(),
    RoutinesLibraryView(),
    SleepHabitsView(),
    PatientHistoryView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SleepHabitsViewModel>().loadSettings();
      context.read<PatientHistoryViewModel>().loadHistory();
    });
  }

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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.mint)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      drawer: NocturneDrawer(
        userName:
            context
                .read<AuthViewModel>()
                .currentUser
                ?.userMetadata?['full_name'] ??
            'Paciente',
        userEmail: context.read<AuthViewModel>().currentUser?.email ?? '',
        roleText: 'Paciente',
        onLogout: () async {
          await context.read<AuthViewModel>().signOut();
        },
        menuItems: [
          ListTile(
            leading: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.lavender,
            ),
            title: Text(
              'Hablar con Calma',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: Text(
              'Acompañamiento emocional',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: AppColors.textPrimary),
            title: Text(
              'Perfil del paciente',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.tune_outlined, color: AppColors.textPrimary),
            title: Text(
              'Preferencias de experiencia',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Configuración de recordatorios',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RemindersView()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Privacidad y consentimiento',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConsentScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.help_outline_rounded,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Ayuda o soporte',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientSupportView()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NocturneBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            activeIcon: Icon(Icons.self_improvement),
            label: 'Rutinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime_outlined),
            activeIcon: Icon(Icons.bedtime),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }
}
