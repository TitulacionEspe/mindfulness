import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_brand.dart';
import '../../../../core/presentation/widgets/nidara_brand_mark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import '../domain/validators/auth_validators.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      _focusFirstInvalidField();
      return;
    }

    final success = await viewModel.updatePassword(_passwordController.text);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ??
              'No se pudo actualizar la contraseña. Intenta nuevamente.',
        ),
      ),
    );
  }

  void _focusFirstInvalidField() {
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
        title: const Text('Nueva contraseña'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NidaraBrandMark(
                      iconSize: 82,
                      showName: false,
                      subtitle: AppBrand.tagline,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Crea una contraseña segura',
                      textAlign: TextAlign.center,
                      style: textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Usa el enlace de recuperación enviado a tu correo y define una nueva contraseña para volver a Nidara.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      maxLength: AuthValidators.maxPasswordLength,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        helperText:
                            'Entre 8 y 30 caracteres, con mayúscula, minúscula, número y *, . o @.',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      maxLength: AuthValidators.maxPasswordLength,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                          _submit(context.read<AuthViewModel>()),
                    ),
                    const SizedBox(height: 28),
                    Consumer<AuthViewModel>(
                      builder: (context, viewModel, _) {
                        return ElevatedButton.icon(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _submit(viewModel),
                          icon: viewModel.isLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.buttonPrimaryText,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Guardar contraseña'),
                        );
                      },
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
