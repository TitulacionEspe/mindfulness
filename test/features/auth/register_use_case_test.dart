import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/features/auth/domain/entities/user_entity.dart';
import 'package:mindfulness_app/features/auth/domain/entities/user_role.dart';
import 'package:mindfulness_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:mindfulness_app/features/auth/domain/use_cases/register_use_case.dart';

class MockAuthRepository implements IAuthRepository {
  String? lastRegisteredEmail;
  String? lastRegisteredFullName;
  bool registerCalled = false;
  bool consentSaved = false;

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String fullName,
  ) async {
    registerCalled = true;
    lastRegisteredEmail = email;
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
  Future<void> saveConsent(String userId, String version) async {
    consentSaved = true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

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

  group('RegisterUseCase validation', () {
    test('calls repository with valid normalized data', () async {
      await useCase(
        email: ' TEST@ESPE.EDU.EC ',
        password: 'Nidara1@',
        fullName: '  Doménica   Cevallos  ',
      );

      expect(mockRepository.registerCalled, true);
      expect(mockRepository.lastRegisteredEmail, 'test@espe.edu.ec');
      expect(mockRepository.lastRegisteredFullName, 'Doménica Cevallos');
    });

    test('does not call repository with invalid name', () async {
      expect(
        () => useCase(
          email: 'test@espe.edu.ec',
          password: 'Nidara1@',
          fullName: 'Doménica Isabel Cevallos',
        ),
        throwsA(isA<Exception>()),
      );
      expect(mockRepository.registerCalled, false);
    });

    test('does not call repository with invalid email', () async {
      expect(
        () => useCase(
          email: '${'a' * 244}@nidara.app',
          password: 'Nidara1@',
          fullName: 'Doménica Cevallos',
        ),
        throwsA(isA<Exception>()),
      );
      expect(mockRepository.registerCalled, false);
    });

    test('does not call repository with invalid password', () async {
      expect(
        () => useCase(
          email: 'test@espe.edu.ec',
          password: 'password',
          fullName: 'Doménica Cevallos',
        ),
        throwsA(isA<Exception>()),
      );
      expect(mockRepository.registerCalled, false);
    });
  });
}
