import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../auth/domain/entities/user_role.dart';
import '../../auth/presentation/consent_screen.dart';
import '../../../views/modulo_paciente/patient_wrapper.dart';
import 'professional_home_screen.dart';
import 'admin_home_screen.dart';
import '../../../core/theme/app_colors.dart';

class HomeSwitcher extends StatelessWidget {
  const HomeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    // 1. Carga inicial de autenticación o rol
    if (authViewModel.isLoading ||
        (authViewModel.isAuthenticated && authViewModel.userRole == null)) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.mint)),
      );
    }

    // 2. Si no está autenticado
    if (!authViewModel.isAuthenticated) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    // 3. Consentimiento obligatorio
    if (!authViewModel.hasAcceptedConsent) {
      return const ConsentScreen();
    }

    // 4. Enrutamiento por Rol
    switch (authViewModel.userRole) {
      case UserRole.admin:
        return const AdminHomeScreen();
      case UserRole.professional:
        return const ProfessionalHomeScreen();
      case UserRole.patient:
      default:
        // El PatientWrapper ahora se encargará de decidir si muestra Onboarding o Home
        return const PatientWrapper();
    }
  }
}
