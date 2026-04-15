import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../auth/domain/entities/user_role.dart';
import 'home_screen.dart';
import 'professional_home_screen.dart';
import 'admin_home_screen.dart';

/// HomeSwitcher determines which home screen to display based on the user's role.
/// It acts as a router for authenticated users.
class HomeSwitcher extends StatelessWidget {
  const HomeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        // While user data or role is loading
        if (authViewModel.isLoading ||
            (authViewModel.isAuthenticated && authViewModel.userRole == null)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If not authenticated, we return an empty scaffold while main.dart
        // rebuilds and switches the root widget to LoginScreen.
        if (!authViewModel.isAuthenticated) {
          return const Scaffold();
        }

        // Routing based on Role
        switch (authViewModel.userRole) {
          case UserRole.admin:
            return const AdminHomeScreen();
          case UserRole.professional:
            return const ProfessionalHomeScreen();
          case UserRole.patient:
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
