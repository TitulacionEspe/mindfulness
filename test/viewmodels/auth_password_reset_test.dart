import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';

class _FakeAuthRepository extends AuthRepository {
  String? resetEmail;
  String? updatedPassword;
  Object? resetError;
  Object? updateError;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (resetError != null) throw resetError!;
    resetEmail = email;
  }

  @override
  Future<void> updatePassword(String password) async {
    if (updateError != null) throw updateError!;
    updatedPassword = password;
  }
}

void main() {
  group('AuthViewModel password recovery', () {
    test('envía correo de recuperación y limpia errores', () async {
      final repository = _FakeAuthRepository();
      final viewModel = AuthViewModel(authRepository: repository);

      final success = await viewModel.sendPasswordResetEmail(
        ' user@nidara.app ',
      );

      expect(success, isTrue);
      expect(repository.resetEmail, 'user@nidara.app');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('expone error amigable si falla el correo', () async {
      final repository = _FakeAuthRepository()
        ..resetError = Exception('No se pudo enviar el correo.');
      final viewModel = AuthViewModel(authRepository: repository);

      final success = await viewModel.sendPasswordResetEmail('user@nidara.app');

      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, 'No se pudo enviar el correo.');
    });

    test('actualiza contraseña con estado de carga controlado', () async {
      final repository = _FakeAuthRepository();
      final viewModel = AuthViewModel(authRepository: repository);

      final success = await viewModel.updatePassword('Nidara1@');

      expect(success, isTrue);
      expect(repository.updatedPassword, 'Nidara1@');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });
  });
}
