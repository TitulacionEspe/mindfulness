import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/auth_viewmodel.dart';

/// Welcome/Home screen displayed after successful login.
/// Shows user greeting, quick stats, and onboarding hints.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryTeal,
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, viewModel, _) => IconButton(
              onPressed: () async {
                await viewModel.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(color: AppTheme.white, fontSize: 32),
                      ),
                      SizedBox(height: 8),
                      Consumer<AuthViewModel>(
                        builder: (context, viewModel, _) => Text(
                          'Tu sesión está activa: ${viewModel.currentUser?.email ?? 'Usuario'}',
                          style: TextStyle(
                            color: AppTheme.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Quick stats cards
                _buildStatsCard(
                  icon: Icons.favorite,
                  label: 'Sesiones Completadas',
                  value: '0',
                  color: AppTheme.accentGreen,
                ),
                SizedBox(height: 12),
                _buildStatsCard(
                  icon: Icons.trending_up,
                  label: 'Racha Actual',
                  value: '--',
                  color: AppTheme.accentOrange,
                ),
                SizedBox(height: 32),

                // Getting started section
                Text(
                  'Primeros Pasos',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppTheme.white),
                ),
                SizedBox(height: 16),
                _buildQuickActionTile(
                  icon: Icons.self_improvement,
                  title: 'Comenzar Sesión de Mindfulness',
                  subtitle: 'Explora ejercicios guiados',
                ),
                SizedBox(height: 12),
                _buildQuickActionTile(
                  icon: Icons.bedtime,
                  title: 'Registrar Actividad de Sueño',
                  subtitle: 'Monitorea tu calidad de sueño',
                ),
                SizedBox(height: 12),
                _buildQuickActionTile(
                  icon: Icons.settings,
                  title: 'Configurar Preferencias',
                  subtitle: 'Personaliza tu experiencia',
                ),
                SizedBox(height: 32),

                // Info banner
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Integración en Progreso',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Estamos integrando todas las funcionalidades. Las pantallas de sesiones y tracking estarán disponibles pronto.',
                              style: TextStyle(
                                color: AppTheme.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.darkText),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.white, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppTheme.white, size: 16),
        ],
      ),
    );
  }
}
