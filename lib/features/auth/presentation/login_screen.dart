import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../viewmodels/auth_viewmodel.dart';
import 'register_screen.dart';

/// Login screen for existing users with accessibility support.
/// Features: email, password, remember me, forgot password, signup link.
/// A11y: Semantics labels, proper tap targets (48x48), contrast ratios.
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
  bool _rememberMe = false;
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
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    await viewModel.signIn(email, password);

    if (context.mounted) {
      if (viewModel.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryTeal,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              ExcludeSemantics(
                child: Icon(Icons.security, size: 60, color: AppTheme.white),
              ),
              SizedBox(height: 12),
              Semantics(
                label: 'Iniciar Sesión',
                child: Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.white,
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Acceso seguro para la gestión de pacientes y bienestar.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correo Institucional',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Semantics(
                      textField: true,
                      label: 'Correo Institucional',
                      child: TextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'usuario@espe.edu.ec',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Contraseña',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Semantics(
                      textField: true,
                      label: 'Contraseña',
                      child: TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: AppTheme.primaryTeal,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.primaryTeal,
                            ),
                            tooltip: _obscurePassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Semantics(
                          checked: _rememberMe,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                            activeColor: AppTheme.primaryTeal,
                          ),
                        ),
                        Text(
                          'Recuérdame',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Spacer(),
                        Semantics(
                          button: true,
                          label: 'Recuperar contraseña',
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcionalidad en desarrollo'),
                                ),
                              );
                            },
                            child: Text(
                              '¿Olvidó su contraseña?',
                              style: TextStyle(
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Consumer<AuthViewModel>(
                      builder: (context, viewModel, _) => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Semantics(
                          button: true,
                          enabled: !viewModel.isLoading,
                          label: 'Entrar al Sistema',
                          child: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () => _handleLogin(viewModel, context),
                            child: viewModel.isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.white,
                                    ),
                                  )
                                : Text(
                                    'Entrar al Sistema',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              MergeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: AppTheme.white),
                    ),
                    Semantics(
                      button: true,
                      label: 'Regístrate aquí',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                '¿Necesitas ayuda? Contacta a soporte técnico',
                style: TextStyle(
                  color: AppTheme.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
