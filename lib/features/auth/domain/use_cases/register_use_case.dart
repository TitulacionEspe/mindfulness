import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';
import '../validators/auth_validators.dart';

/// Use case: Register a new user.
/// Validates input and delegates persistence to the repository.
class RegisterUseCase {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Throws [Exception] with a user-facing validation message when input is
  /// invalid. Repository errors are mapped in the data layer.
  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final nameError = AuthValidators.fullName(fullName);
    if (nameError != null) throw Exception(nameError);

    final emailError = AuthValidators.email(email);
    if (emailError != null) throw Exception(emailError);

    final passwordError = AuthValidators.securePassword(password);
    if (passwordError != null) throw Exception(passwordError);

    return await _repository.register(
      AuthValidators.normalizeEmail(email),
      password,
      AuthValidators.normalizeName(fullName),
    );
  }
}
