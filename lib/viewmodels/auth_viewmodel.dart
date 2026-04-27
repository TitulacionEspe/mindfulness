import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/domain/entities/user_role.dart';
import '../features/auth/domain/use_cases/register_use_case.dart';

/// AuthViewModel manages authentication state and user session (MVVM pattern).
/// Responsibilities:
/// - Uses domain use cases for signup and login
/// - Maintains current user session and role
/// - Tracks loading and error states for UI feedback
/// - Exposes authentication state to Views (decouples UI from logic)
class AuthViewModel extends ChangeNotifier {
  late RegisterUseCase _registerUseCase;
  late AuthRepository _authRepository;

  // State variables
  User? _currentUser;
  UserRole? _userRole;
  bool _hasAcceptedConsent = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSigningUp = false;

  // Constant for consent versioning
  static const String currentConsentVersion = '1.0.0';

  // Getters for View layer
  User? get currentUser => _currentUser;
  UserRole? get userRole => _userRole;
  bool get hasAcceptedConsent => _hasAcceptedConsent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isSigningUp => _isSigningUp;

  // Convenience getters for RBAC
  bool get isPatient => _userRole == UserRole.patient;
  bool get isProfessional => _userRole == UserRole.professional;
  bool get isAdmin => _userRole == UserRole.admin;

  /// Initializes the ViewModel with use cases and repositories.
  Future<void> initialize() async {
    _authRepository = AuthRepository();
    _registerUseCase = RegisterUseCase(_authRepository);

    // Only try to access Supabase if it was properly initialized in main()
    if (SupabaseConfig.isConfigured) {
      try {
        _currentUser = Supabase.instance.client.auth.currentUser;

        if (_currentUser != null) {
          // Fetch role for persisted session
          final userEntity = await _authRepository.getCurrentUser();
          if (userEntity == null || !userEntity.canAccessProtectedFeatures) {
            _currentUser = null;
            _userRole = null;
            _hasAcceptedConsent = false;
            notifyListeners();
            return;
          }
          _userRole = userEntity.role;

          // Check for consent acceptance
          _hasAcceptedConsent = await _authRepository.hasAcceptedConsent(
            _currentUser!.id,
            currentConsentVersion,
          );
        }
      } catch (e) {
        debugPrint('AuthViewModel initialization error: $e');
        _currentUser = null;
        _userRole = null;
        _hasAcceptedConsent = false;
      }
    }

    notifyListeners();
  }

  /// Signs up a new user (uses domain use case).
  /// User profile is auto-created by DB trigger.
  Future<void> signUp(String email, String password, String fullName) async {
    _isLoading = true;
    _isSigningUp = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _registerUseCase(
        email: email.trim(),
        password: password.trim(),
        fullName: fullName.trim(),
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      _isSigningUp = false;
      notifyListeners();
    }
  }

  /// Signs in an existing user using email and password.
  /// Uses the AuthRepository to handle business logic, role fetching, and error mapping.
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _hasAcceptedConsent = false;
    notifyListeners();

    try {
      // Call repository to handle logic and role fetching
      final userEntity = await _authRepository.signIn(
        email.trim(),
        password.trim(),
      );

      _currentUser = Supabase.instance.client.auth.currentUser;
      _userRole = userEntity.role;

      // Check for consent acceptance immediately after login
      _hasAcceptedConsent = await _authRepository.hasAcceptedConsent(
        _currentUser!.id,
        currentConsentVersion,
      );

      _errorMessage = null;
    } catch (e) {
      // Repository already returns friendly Spanish messages
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _currentUser = null;
      _userRole = null;
      _hasAcceptedConsent = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Records explicit acceptance of the ethical consent by the user.
  Future<void> acceptConsent() async {
    if (_currentUser == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.saveConsent(
        _currentUser!.id,
        currentConsentVersion,
      );
      _hasAcceptedConsent = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs out the current user and clears session state.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signOut();
      _currentUser = null;
      _userRole = null;
      _hasAcceptedConsent = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears error message (call after user dismisses feedback).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
