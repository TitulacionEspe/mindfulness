import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/presentation/widgets/nocturne_bottom_nav.dart';
import '../../core/presentation/widgets/nocturne_drawer.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/consent_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/patient_history_viewmodel.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';
import 'patient_appointments_view.dart';
import 'patient_feature_guide_view.dart';
import 'patient_history_view.dart';
import 'patient_home_view.dart';
import 'patient_support_view.dart';
import 'profile_view.dart';
import 'reminders_view.dart';
import 'routines_library_view.dart';
import 'sleep_habits_view.dart';
import 'tareas_main_hub.dart';
import 'thought_entries_view.dart';

class PatientWrapper extends StatefulWidget {
  const PatientWrapper({super.key});

  @override
  State<PatientWrapper> createState() => _PatientWrapperState();
}

class _PatientWrapperState extends State<PatientWrapper> {
  int _selectedIndex = 0;
  bool _isLoadingFeatureGuide = true;
  bool _showFeatureGuide = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SleepHabitsViewModel>().loadSettings();
      context.read<PatientHistoryViewModel>().loadHistory();
      _loadFeatureGuidePreference();
    });
  }

  Future<void> _loadFeatureGuidePreference() async {
    final authViewModel = context.read<AuthViewModel>();
    final currentUserId = authViewModel.currentUser?.id;

    if (currentUserId == null) {
      if (mounted) setState(() => _isLoadingFeatureGuide = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeenGuide =
        prefs.getBool(_featureGuideKey(currentUserId)) ?? false;

    if (!mounted) return;
    setState(() {
      _showFeatureGuide = authViewModel.justAcceptedConsent && !hasSeenGuide;
      _isLoadingFeatureGuide = false;
    });
  }

  String _featureGuideKey(String userId) =>
      'patient_feature_guide_seen_$userId';

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _markFeatureGuideSeen() async {
    final authViewModel = context.read<AuthViewModel>();
    final currentUserId = authViewModel.currentUser?.id;

    if (currentUserId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_featureGuideKey(currentUserId), true);
    }

    authViewModel.clearConsentIntroFlag();
  }

  Future<void> _finishFirstRunGuide([PatientFeatureAction? action]) async {
    await _markFeatureGuideSeen();
    if (!mounted) return;

    setState(() => _showFeatureGuide = false);

    if (action != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleFeatureAction(action);
      });
    }
  }

  Future<void> _openFeatureGuide() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientFeatureGuideView(
          isFirstRun: false,
          onContinue: () => Navigator.of(context).pop(),
          onFeatureAction: (action) {
            Navigator.of(context).pop();
            _handleFeatureAction(action);
          },
        ),
      ),
    );
  }

  void _handleFeatureAction(PatientFeatureAction action) {
    switch (action) {
      case PatientFeatureAction.routines:
        _onItemTapped(1);
        break;
      case PatientFeatureAction.habits:
        _onItemTapped(2);
        break;
      case PatientFeatureAction.progress:
        _onItemTapped(3);
        break;
      case PatientFeatureAction.tasks:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TareasMainHub()));
        break;
      case PatientFeatureAction.thoughts:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ThoughtEntriesView()));
        break;
      case PatientFeatureAction.reminders:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RemindersView()));
        break;
      case PatientFeatureAction.appointments:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PatientAppointmentsView()),
        );
        break;
    }
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

    if (_isLoadingFeatureGuide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.mint)),
      );
    }

    if (_showFeatureGuide) {
      return PatientFeatureGuideView(
        isFirstRun: true,
        onContinue: () => _finishFirstRunGuide(),
        onFeatureAction: (action) => _finishFirstRunGuide(action),
      );
    }

    final pages = [
      PatientHomeView(onShowFeatureGuide: _openFeatureGuide),
      const RoutinesLibraryView(),
      const SleepHabitsView(),
      const PatientHistoryView(),
    ];

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
                MaterialPageRoute(
                  builder: (_) => const ConsentScreen(readOnly: true),
                ),
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
      body: pages[_selectedIndex],
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
