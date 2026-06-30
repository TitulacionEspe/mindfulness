import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/presentation/widgets/nocturne_bottom_nav.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/patient_history_viewmodel.dart';
import '../../viewmodels/sleep_habits_viewmodel.dart';
import 'chat_view.dart';
import 'patient_appointments_view.dart';
import 'patient_feature_guide_view.dart';
import 'patient_home_view.dart';
import 'patient_profile_view.dart';
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
  final bool _showAssistantTooltip = true;

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
    setState(() => _selectedIndex = index);
  }

  void _handleFeatureAction(PatientFeatureAction action) {
    switch (action) {
      case PatientFeatureAction.routines:
        _onItemTapped(1);
        break;
      case PatientFeatureAction.habits:
        _onItemTapped(4);
        break;
      case PatientFeatureAction.progress:
        _onItemTapped(5);
        break;
      case PatientFeatureAction.tasks:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TareasMainHub()));
        break;
      case PatientFeatureAction.thoughts:
        _onItemTapped(2);
        break;
      case PatientFeatureAction.reminders:
        _onItemTapped(4);
        break;
      case PatientFeatureAction.appointments:
        _onItemTapped(3);
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

    final pages = [
      PatientHomeView(onFeatureAction: _handleFeatureAction),
      const RoutinesLibraryView(),
      ThoughtEntriesView(
        showBackButton: false,
        onOpenActivities: () => _onItemTapped(1),
      ),
      const PatientAppointmentsView(showAppBar: false),
      const SleepHabitsView(showAppBar: false),
      const PatientProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [_buildAssistantBubbleButton(), const SizedBox(width: 8)],
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
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book_rounded),
            label: 'Diario',
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
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _openAssistantChatBubble(BuildContext context) {
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

  Widget _buildAssistantBubbleButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: _showAssistantTooltip ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(right: _showAssistantTooltip ? 8.0 : 0.0),
            width: _showAssistantTooltip ? 165 : 0,
            height: _showAssistantTooltip ? 32 : 0,
            child: _showAssistantTooltip
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      '¿Cómo te sientes hoy?',
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
          onTap: () => _openAssistantChatBubble(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/img/Icono_Minfulnes.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.lavender,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
