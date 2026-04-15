import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/features/auth/domain/entities/user_entity.dart';
import 'package:mindfulness_app/features/auth/domain/entities/user_role.dart';
import 'package:mindfulness_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:mindfulness_app/features/auth/domain/use_cases/register_use_case.dart';

/// Manual Mock for IAuthRepository
class MockAuthRepository implements IAuthRepository {
  String? lastRegisteredFullName;
  bool registerCalled = false;

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String fullName,
  ) async {
    registerCalled = true;
    lastRegisteredFullName = fullName;
    return UserEntity(
      id: '123',
      email: email,
      fullName: fullName,
      createdAt: DateTime.now(),
      role: UserRole.patient,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async => null;
  @override
  Future<bool> hasAcceptedConsent(String userId, String version) async => false;
  @override
  Future<void> saveConsent(String userId, String version) async {}
  @override
  Future<UserEntity> signIn(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<void> signOut() async {}
}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase - PGS-6 Validation', () {
    test('should call repository with correct fullName', () async {
      // Arrange
      const tEmail = 'test@espe.edu.ec';
      const tPassword = 'password123';
      const tFullName = 'Juan Pérez';

      // Act
      await useCase(email: tEmail, password: tPassword, fullName: tFullName);

      // Assert
      expect(mockRepository.registerCalled, true);
      expect(mockRepository.lastRegisteredFullName, tFullName);
    });

    test('should throw error if fullName is empty', () async {
      // Act & Assert
      expect(
        () => useCase(email: 'a@a.com', password: '123', fullName: ''),
        throwsA(isA<Exception>()),
      );
    });
  });
}
