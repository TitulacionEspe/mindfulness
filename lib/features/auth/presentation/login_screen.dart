import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_brand.dart';
import '../../../../core/presentation/widgets/nidara_brand_mark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import '../domain/validators/auth_validators.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _handleLogin(AuthViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      _focusFirstInvalidField();
      return;
    }

    await viewModel.signIn(
      AuthValidators.normalizeEmail(_emailController.text),
      _passwordController.text,
    );

    if (mounted && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  void _focusFirstInvalidField() {
    if (AuthValidators.email(_emailController.text) != null) {
      _emailFocus.requestFocus();
      return;
    }
    _passwordFocus.requestFocus();
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
                  autofillHints: const [AutofillHints.email],
                  maxLength: AuthValidators.maxEmailLength,
                  decoration: const InputDecoration(
                    labelText: 'Correo personal o institucional',
                    hintText: 'nombre@correo.com',
                    counterText: '',
                  ),
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushNamed('/reset-password');
                  },
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Ya tengo el enlace'),
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
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(140, 48),
                  ),
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final navigator = Navigator.of(dialogContext);
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await viewModel
                              .sendPasswordResetEmail(
                                resetEmailController.text,
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
                  icon: viewModel.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.buttonPrimaryText,
                          ),
                        )
                      : const Icon(Icons.mail_outline_rounded),
                  label: const Text('Enviar enlace'),
                );
              },
            ),
          ],
        );
      },
    );

    resetEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NidaraBrandMark(iconSize: 170, showName: false),
                    const SizedBox(height: 0.1),
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
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      maxLength: AuthValidators.maxEmailLength,
                      decoration: const InputDecoration(
                        labelText: 'Correo personal o institucional',
                        hintText: 'nombre@correo.com',
                        helperText:
                            'Usa el correo con el que creaste tu cuenta.',
                        prefixIcon: Icon(Icons.email_outlined),
                        counterText: '',
                      ),
                      validator: AuthValidators.email,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      maxLength: AuthValidators.maxPasswordLength,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingresa tu contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        counterText: '',
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: AuthValidators.requiredPassword,
                      onFieldSubmitted: (_) =>
                          _handleLogin(context.read<AuthViewModel>()),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 24),
                    Consumer<AuthViewModel>(
                      builder: (context, viewModel, _) => ElevatedButton.icon(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _handleLogin(viewModel),
                        icon: viewModel.isLoading
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.buttonPrimaryText,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: const Text('Entrar a Nidara'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _NewAccountCallout(
                      onRegister: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
            'Crea tu cuenta con un correo activo para acceder a actividades, hábitos, progreso y citas.',
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
