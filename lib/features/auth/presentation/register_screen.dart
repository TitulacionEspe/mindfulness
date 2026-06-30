import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_brand.dart';
import '../../../../core/presentation/widgets/nidara_brand_mark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import '../domain/validators/auth_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(AuthViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      _focusFirstInvalidField();
      return;
    }

    await viewModel.signUp(
      AuthValidators.normalizeEmail(_emailController.text),
      _passwordController.text,
      AuthValidators.normalizeName(_fullNameController.text),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (viewModel.errorMessage == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
      );
      Navigator.of(context).pop();
      return;
    }

    messenger.showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
  }

  void _focusFirstInvalidField() {
    if (AuthValidators.fullName(_fullNameController.text) != null) {
      _fullNameFocus.requestFocus();
      return;
    }
    if (AuthValidators.email(_emailController.text) != null) {
      _emailFocus.requestFocus();
      return;
    }
    if (AuthValidators.securePassword(_passwordController.text) != null) {
      _passwordFocus.requestFocus();
      return;
    }
    _confirmPasswordFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NidaraBrandMark(iconSize: 72, showName: false),
                    const SizedBox(height: 16),
                    Text(
                      'Crea tu cuenta en ${AppBrand.name}',
                      style: textTheme.displayLarge?.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Únete para cuidar tu higiene del sueño y bienestar.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _fullNameController,
                      focusNode: _fullNameFocus,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      maxLength: AuthValidators.maxFullNameLength,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        hintText: 'Ej. Juan Pérez',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        counterText: '',
                      ),
                      validator: AuthValidators.fullName,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: 18),
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
                            'Usa un correo activo para recuperar tu acceso.',
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
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      maxLength: AuthValidators.maxPasswordLength,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 8 caracteres',
                        helperText: 'Incluye al menos una letra y un número.',
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
                      validator: AuthValidators.securePassword,
                      onFieldSubmitted: (_) =>
                          _confirmPasswordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      maxLength: AuthValidators.maxPasswordLength,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        counterText: '',
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirm
                              ? 'Mostrar confirmación'
                              : 'Ocultar confirmación',
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => AuthValidators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      onFieldSubmitted: (_) =>
                          _handleSignUp(context.read<AuthViewModel>()),
                    ),
                    const SizedBox(height: 28),
                    Consumer<AuthViewModel>(
                      builder: (context, viewModel, _) => ElevatedButton.icon(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _handleSignUp(viewModel),
                        icon: viewModel.isLoading
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.buttonPrimaryText,
                                ),
                              )
                            : const Icon(Icons.person_add_alt_rounded),
                        label: const Text('Crear cuenta'),
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
