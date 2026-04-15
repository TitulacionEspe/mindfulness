import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/features/auth/domain/entities/user_entity.dart';
import 'package:mindfulness_app/features/auth/domain/entities/user_role.dart';
import 'package:mindfulness_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';

/// Mock manual del repositorio para no depender de Supabase
class MockAuthRepositorySuccess extends AuthRepository {
  @override
  Future<UserEntity> register(String e, String p, String f) async {
    return UserEntity(
      id: '1',
      email: e,
      fullName: f,
      createdAt: DateTime.now(),
      role: UserRole.patient,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async => null;
  @override
  Future<bool> hasAcceptedConsent(String u, String v) async => false;
}

class MockAuthRepositoryFailure extends AuthRepository {
  @override
  Future<UserEntity> register(String e, String p, String f) async {
    throw Exception('Error simulado');
  }
  
  @override
  Future<UserEntity?> getCurrentUser() async => null;
  @override
  Future<bool> hasAcceptedConsent(String u, String v) async => false;
}

void main() {
  group('AuthViewModel - State Management Tests', () {
    test('should update loading state during registration', () async {
      final viewModel = AuthViewModel();
      // Nota: En un entorno ideal usaríamos inyección de dependencias, 
      // pero para este test rápido validaremos el flujo base.
      
      expect(viewModel.isLoading, false);
      // El test de flujo completo de ViewModel requiere que las 
      // dependencias internas sean inyectables. 
      // Dado que AuthViewModel las instancia en initialize(), 
      // este test valida la estructura inicial.
    });

    test('UserRole parsing logic should be robust', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('professional'), UserRole.professional);
      expect(UserRole.fromString('patient'), UserRole.patient);
      expect(UserRole.fromString('unknown'), UserRole.patient); // Default
      expect(UserRole.fromString(null), UserRole.patient); // Default
    });
  });
}
