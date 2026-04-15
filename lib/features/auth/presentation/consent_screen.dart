import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../viewmodels/auth_viewmodel.dart';

/// Screen for informed consent and legal notice.
/// Required during onboarding before accessing the app features.
/// UX: Avoids clinical terms, emphasizes data privacy and non-replacement of therapy.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;

  Future<void> _handleAccept(AuthViewModel viewModel) async {
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos para continuar'),
        ),
      );
      return;
    }

    await viewModel.acceptConsent();

    // Check if the widget is still mounted before using context
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

    return Scaffold(
      backgroundColor: AppTheme.primaryTeal,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  size: 50,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(height: 16),
                Text(
                  'Consentimiento Ético y Legal',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 22,
                    color: AppTheme.primaryTeal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Scrollable text area for the consent content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Uso de la Aplicación'),
                        _buildBodyText(
                          'Esta herramienta está diseñada para el acompañamiento en hábitos de bienestar y relajación. No constituye un servicio médico ni de salud mental profesional.',
                        ),
                        const SizedBox(height: 12),
                        _buildSectionTitle('No Sustituye Terapia'),
                        _buildBodyText(
                          'El uso de este sistema NO sustituye el diagnóstico, tratamiento o consulta con un psicólogo, psiquiatra o médico profesional. Si se encuentra en una situación de emergencia, contacte a los servicios de salud locales.',
                        ),
                        const SizedBox(height: 12),
                        _buildSectionTitle('Privacidad y Datos'),
                        _buildBodyText(
                          'Sus datos, especialmente los registros de pensamientos y emociones, se manejan bajo estrictos criterios de confidencialidad y cifrado. Usted tiene control sobre su información.',
                        ),
                        const SizedBox(height: 12),
                        _buildSectionTitle('Compromiso del Usuario'),
                        _buildBodyText(
                          'Al aceptar, usted declara ser mayor de edad o contar con autorización institucional para participar en este programa de bienestar universitario.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),

                // Acceptance checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      onChanged: (val) =>
                          setState(() => _accepted = val ?? false),
                      activeColor: AppTheme.primaryTeal,
                    ),
                    const Expanded(
                      child: Text(
                        'He leído y acepto el aviso legal y el consentimiento ético.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => viewModel.signOut(),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _handleAccept(viewModel),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.white,
                                ),
                              )
                            : const Text('Aceptar y Continuar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppTheme.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
      textAlign: TextAlign.justify,
    );
  }
}
