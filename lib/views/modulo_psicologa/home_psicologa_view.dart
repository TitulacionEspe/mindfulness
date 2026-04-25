import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'components/home_header.dart';
import 'components/stats_card.dart';
import 'components/quick_actions.dart';

class HomePsicologaView extends StatelessWidget {
  const HomePsicologaView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userName =
        authViewModel.currentUser?.userMetadata?['full_name'] ?? 'Profesional';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: HomeHeader(userName: userName),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen General',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Pacientes',
                            value: '24',
                            icon: Icons.people_outline,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: StatsCard(
                            title: 'Alertas',
                            value: '3',
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(
                      'Acciones Rápidas',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16),
                    QuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.mint,
        child: Icon(
          Icons.chat_bubble_outline,
          color: AppColors.buttonPrimaryText,
        ),
      ),
    );
  }
}
