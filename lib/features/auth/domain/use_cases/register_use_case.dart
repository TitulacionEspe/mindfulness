import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Use case: Register a new user.
/// Validates input and delegates to repository.
class RegisterUseCase {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute registration.
  /// Throws Exception if:
  /// - El correo electrónico tiene formato inválido
  /// - La contraseña tiene menos de 6 caracteres
  /// - Supabase rechaza el registro (correo ya registrado, error de red, etc.)
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw Exception('El correo electrónico no tiene un formato válido');
    }

    // Validate password length
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    // Delegate to repository (handles Supabase Auth + profile creation via trigger)
    return await _repository.register(email, password);
  }

  /// Simple email validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }
}
