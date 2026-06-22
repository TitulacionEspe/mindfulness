import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_brand.dart';
import '../../../../core/presentation/widgets/nidara_brand_mark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(
    AuthViewModel viewModel,
    BuildContext context,
  ) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    await viewModel.signIn(email, password);

    if (context.mounted && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Restablecer contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Escribe el correo asociado a tu cuenta. Te enviaremos un enlace para crear una nueva contraseña.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Correo personal o institucional',
                    hintText: 'nombre@correo.com',
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Ingresa tu correo.';
                    if (!_isValidEmail(email)) {
                      return 'Ingresa un correo válido.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            Consumer<AuthViewModel>(
              builder: (context, viewModel, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 48),
                  ),
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final navigator = Navigator.of(dialogContext);
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await viewModel
                              .sendPasswordResetEmail(
                                resetEmailController.text.trim(),
                              );
                          if (!context.mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Te enviamos un enlace para restablecer tu contraseña. Revisa tu correo.'
                                    : viewModel.errorMessage ??
                                          'No se pudo enviar el correo. Intenta nuevamente.',
                              ),
                            ),
                          );
                        },
                  child: viewModel.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.buttonPrimaryText,
                          ),
                        )
                      : const Text('Enviar enlace'),
                );
              },
            ),
          ],
        );
      },
    );

    resetEmailController.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NidaraBrandMark(
                  iconSize: 104,
                  subtitle: AppBrand.tagline,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenido a ${AppBrand.name}',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppBrand.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildInputField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Correo personal o institucional',
                  hint: 'nombre@correo.com',
                  helperText:
                      'Usa el correo con el que creaste tu cuenta en Nidara.',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  label: 'Contraseña',
                  hint: '••••••••',
                  icon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showPasswordResetDialog,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: AppColors.lavender,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Consumer<AuthViewModel>(
                  builder: (context, viewModel, _) => ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _handleLogin(viewModel, context),
                    child: viewModel.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.buttonPrimaryText,
                            ),
                          )
                        : const Text('Entrar a Nidara'),
                  ),
                ),
                const SizedBox(height: 24),
                _NewAccountCallout(
                  onRegister: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String? helperText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onSubmitted: onSubmitted,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.25,
            ),
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.mint, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _NewAccountCallout extends StatelessWidget {
  const _NewAccountCallout({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_alt_rounded, color: AppColors.mint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¿Primera vez en Nidara?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu cuenta antes de iniciar sesión. Puedes usar un correo personal o institucional según corresponda.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRegister,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }
}
