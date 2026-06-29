import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/auth_viewmodel.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key, this.readOnly = false});

  final bool readOnly;

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;

  Future<void> _handleAccept(AuthViewModel viewModel) async {
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos para continuar.'),
        ),
      );
      return;
    }

    await viewModel.acceptConsent();
    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    final isReadOnly = widget.readOnly || viewModel.hasAcceptedConsent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Icon(
                isReadOnly ? Icons.privacy_tip_rounded : Icons.gavel_rounded,
                size: 48,
                color: AppColors.mint,
              ),
              const SizedBox(height: 24),
              Text(
                isReadOnly
                    ? 'Privacidad y consentimiento'
                    : 'Consentimiento ético y legal',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 12),
              Text(
                isReadOnly
                    ? 'Consulta la información vigente que ya aceptaste para usar la aplicación.'
                    : 'Por favor, lee atentamente antes de continuar.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isReadOnly) ...[
                          _buildAcceptedStatus(),
                          const SizedBox(height: 20),
                        ],
                        _buildSection(
                          'Uso de la aplicación',
                          'Esta herramienta es para el acompañamiento en bienestar, relajación e higiene del sueño. No sustituye terapia profesional ni atención clínica.',
                        ),
                        _buildSection(
                          'Privacidad',
                          'Tus datos están cifrados y solo tú tienes acceso a tus pensamientos y emociones registradas.',
                        ),
                        _buildSection(
                          'Compromiso',
                          'Al aceptar, declaras ser mayor de edad o contar con autorización para participar.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isReadOnly) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Volver'),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      onChanged: (val) =>
                          setState(() => _accepted = val ?? false),
                      activeColor: AppColors.mint,
                      checkColor: AppColors.buttonPrimaryText,
                    ),
                    Expanded(
                      child: Text(
                        'He leído y acepto el aviso legal y el consentimiento ético.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => viewModel.signOut(),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _handleAccept(viewModel),
                        child: viewModel.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.buttonPrimaryText,
                                ),
                              )
                            : const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consentimiento aceptado',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versión vigente: ${AuthViewModel.currentConsentVersion}. Puedes revisar estos términos cuando lo necesites.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.lavender,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: AppColors.textPrimary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
