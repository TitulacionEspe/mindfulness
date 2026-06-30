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

  bool get _isFormReady {
    return AuthValidators.fullName(_fullNameController.text) == null &&
        AuthValidators.email(_emailController.text) == null &&
        AuthValidators.securePassword(_passwordController.text) == null &&
        AuthValidators.passwordsMatch(
          _passwordController.text,
          _confirmPasswordController.text,
        );
  }

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_refreshFormState);
    _emailController.addListener(_refreshFormState);
    _passwordController.addListener(_refreshFormState);
    _confirmPasswordController.addListener(_refreshFormState);
  }

  @override
  void dispose() {
    _fullNameController
      ..removeListener(_refreshFormState)
      ..dispose();
    _emailController
      ..removeListener(_refreshFormState)
      ..dispose();
    _passwordController
      ..removeListener(_refreshFormState)
      ..dispose();
    _confirmPasswordController
      ..removeListener(_refreshFormState)
      ..dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _refreshFormState() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSignUp(AuthViewModel viewModel) async {
    if (!_formKey.currentState!.validate() || !_isFormReady) {
      _focusFirstInvalidField();
      return;
    }

    final acceptedConsent = await _showConsentDialog();
    if (!mounted) return;

    if (acceptedConsent != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se creará la cuenta porque el consentimiento es necesario para usar Nidara.',
          ),
        ),
      );
      return;
    }

    await viewModel.signUpWithAcceptedConsent(
      email: AuthValidators.normalizeEmail(_emailController.text),
      password: _passwordController.text,
      fullName: AuthValidators.normalizeName(_fullNameController.text),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (viewModel.errorMessage == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Bienvenido a Nidara.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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

  Future<bool?> _showConsentDialog() {
    var accepted = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Consentimiento para crear tu cuenta'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Antes de crear tu cuenta, confirma que entiendes el uso de Nidara.',
                      ),
                      const SizedBox(height: 18),
                      _ConsentPoint(
                        title: 'Uso de la aplicación',
                        content:
                            'Nidara acompaña tu bienestar, relajación e higiene del sueño. No sustituye terapia profesional ni atención clínica.',
                      ),
                      _ConsentPoint(
                        title: 'Privacidad',
                        content:
                            'Tus datos personales se usan para habilitar tu experiencia en la aplicación y proteger tus registros.',
                      ),
                      _ConsentPoint(
                        title: 'Compromiso',
                        content:
                            'Al aceptar, confirmas que leíste el aviso legal y que el consentimiento es necesario para usar Nidara.',
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: accepted,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.mint,
                        checkColor: AppColors.buttonPrimaryText,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'He leído y acepto el aviso legal y el consentimiento ético.',
                        ),
                        onChanged: (value) =>
                            setDialogState(() => accepted = value ?? false),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Rechazar'),
                ),
                ElevatedButton(
                  onPressed: accepted
                      ? () => Navigator.of(dialogContext).pop(true)
                      : null,
                  child: const Text('Aceptar y crear cuenta'),
                ),
              ],
            );
          },
        );
      },
    );
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        labelText: 'Nombre y apellido',
                        hintText: 'Ej. Doménica Cevallos',
                        helperText: 'Ingresa un solo nombre y un apellido.',
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
                        hintText: 'Entre 8 y 30 caracteres',
                        helperText:
                            'Usa solo letras, números y los caracteres *, . o @.',
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
                      onFieldSubmitted: (_) {
                        if (_isFormReady) {
                          _handleSignUp(context.read<AuthViewModel>());
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _PasswordRequirementList(
                      password: _passwordController.text,
                      confirmation: _confirmPasswordController.text,
                    ),
                    const SizedBox(height: 28),
                    Consumer<AuthViewModel>(
                      builder: (context, viewModel, _) => ElevatedButton.icon(
                        onPressed: viewModel.isLoading || !_isFormReady
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

class _PasswordRequirementList extends StatelessWidget {
  const _PasswordRequirementList({
    required this.password,
    required this.confirmation,
  });

  final String password;
  final String confirmation;

  @override
  Widget build(BuildContext context) {
    final requirements = [
      _RequirementState(
        label: 'Al menos una mayúscula',
        isMet: AuthValidators.hasUppercase(password),
      ),
      _RequirementState(
        label: 'Al menos una minúscula',
        isMet: AuthValidators.hasLowercase(password),
      ),
      _RequirementState(
        label: 'Al menos un número',
        isMet: AuthValidators.hasNumber(password),
      ),
      _RequirementState(
        label: 'Un carácter especial permitido: *, . o @',
        isMet: AuthValidators.hasAllowedSpecialCharacter(password),
      ),
      _RequirementState(
        label: 'Las contraseñas coinciden',
        isMet: AuthValidators.passwordsMatch(password, confirmation),
      ),
    ];

    return Semantics(
      label: 'Requisitos de contraseña',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu contraseña debe cumplir:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...requirements.map(_RequirementRow.new),
          ],
        ),
      ),
    );
  }
}

class _RequirementState {
  const _RequirementState({required this.label, required this.isMet});

  final String label;
  final bool isMet;
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow(this.requirement);

  final _RequirementState requirement;

  @override
  Widget build(BuildContext context) {
    final color = requirement.isMet ? AppColors.mint : AppColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            requirement.isMet ? Icons.check_circle_rounded : Icons.cancel,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requirement.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentPoint extends StatelessWidget {
  const _ConsentPoint({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.lavender,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
