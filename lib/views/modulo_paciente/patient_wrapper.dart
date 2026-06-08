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
import 'chat_view.dart';
import 'patient_appointments_view.dart';
import 'patient_feature_guide_view.dart';
import 'patient_history_view.dart';
import 'patient_home_view.dart';
import 'patient_support_view.dart';
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
  bool _showCalmaTooltip = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SleepHabitsViewModel>().loadSettings();
      context.read<PatientHistoryViewModel>().loadHistory();
      _loadFeatureGuidePreference();
    });
    // Ocultar el globo de diálogo después de 8 segundos
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _showCalmaTooltip = false);
      }
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
        _onItemTapped(3);
        break;
      case PatientFeatureAction.progress:
        _onItemTapped(4);
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
        _onItemTapped(2);
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
      const PatientAppointmentsView(),
      const SleepHabitsView(),
      const PatientHistoryView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          _buildCalmaBubbleButton(),
          const SizedBox(width: 8),
        ],
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
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Citas',
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

  void _openCalmaChatBubble(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            child: ChatView(),
          ),
        );
      },
    );
  }

  Widget _buildCalmaBubbleButton() {
    const String? calmaImage = null; // Asignable en el futuro
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: _showCalmaTooltip ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(right: _showCalmaTooltip ? 8.0 : 0.0),
            width: _showCalmaTooltip ? 165 : 0,
            height: _showCalmaTooltip ? 32 : 0,
            child: _showCalmaTooltip
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      '¿Cómo te sientes hoy? 💬',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        GestureDetector(
          onTap: () => _openCalmaChatBubble(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: ClipOval(
              child: calmaImage != null
                  ? Image.network(
                      calmaImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.favorite_rounded,
                        color: AppColors.lavender,
                        size: 20,
                      ),
                    )
                  : Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.lavender,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
