import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/domain/use_cases/register_use_case.dart';

/// AuthViewModel gestiona el estado de autenticación y la sesión del usuario
/// (patrón MVVM).
/// Responsabilidades:
/// - Usa casos de uso del dominio para registro e inicio de sesión
/// - Mantiene la sesión del usuario actual
/// - Rastrea estados de carga y error (para feedback a la UI)
/// - Expone el estado de autenticación a las Vistas (desacopla lógica de UI)
class AuthViewModel extends ChangeNotifier {
  late RegisterUseCase _registerUseCase;
  late AuthRepository _authRepository;

  // Variables de estado
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSigningUp = false;

  // Getters para la capa de Vista
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isSigningUp => _isSigningUp;

  /// Inicializa el ViewModel con casos de uso y repositorios.
  Future<void> initialize() async {
    _authRepository = AuthRepository();
    _registerUseCase = RegisterUseCase(_authRepository);
    _currentUser = Supabase.instance.client.auth.currentUser;
    notifyListeners();
  }

  /// Registra un nuevo usuario con correo y contraseña (usa el caso de uso del dominio).
  /// Al completar el registro, el perfil se crea automáticamente por trigger de BD.
  /// El usuario NO se loguea automáticamente (debe ir al login).
  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _isSigningUp = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _registerUseCase(email: email.trim(), password: password.trim());
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isSigningUp = false;
      notifyListeners();
    }
  }

  /// Inicia sesión de un usuario existente.
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        _currentUser = response.user;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia el mensaje de error (llamar después de que el usuario descarta el snackbar).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
