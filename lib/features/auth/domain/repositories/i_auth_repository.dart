import '../entities/user_entity.dart';

/// Abstract interface for auth operations (Domain Layer).
/// Implementation in Data Layer must follow this contract.
abstract class IAuthRepository {
  /// Register a new user with email and password.
  /// Throws exception if email already exists or password too short.
  Future<UserEntity> register(String email, String password);

  /// Sign in existing user.
  Future<UserEntity> signIn(String email, String password);

  /// Sign out current user.
  Future<void> signOut();

  /// Get current authenticated user, or null if not logged in.
  Future<UserEntity?> getCurrentUser();

  /// Check if the user has accepted a specific version of the consent document.
  Future<bool> hasAcceptedConsent(String userId, String documentVersion);

  /// Save user's explicit acceptance of the consent terms.
  Future<void> saveConsent(String userId, String documentVersion);
}
