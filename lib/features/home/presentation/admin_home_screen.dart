import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import '../../../../core/theme/app_theme.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consola de Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Just call signOut, the Consumer in main.dart handles redirection
              await authViewModel.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: AppTheme.accentOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'Consola de Gestión',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            const Text('Acceso total al sistema y control de perfiles.'),
            const SizedBox(height: 24),
            const Text(
              'Funcionalidad en desarrollo',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
