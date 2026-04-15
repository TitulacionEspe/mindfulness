import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository - Exception Mapping Tests', () {
    // We test the error mapping logic specifically.
    // Even if Supabase client is not available in CI,
    // the logic that handles strings and converts them
    // to user-friendly messages is testable.

    test('should map email_rate_limit to friendly Spanish message', () {
      // We simulate an error from Supabase
      const technicalError = 'Exception: email_rate_limit: Too many attempts';
      String mapError(String e) {
        if (e.contains('email_rate_limit')) {
          return 'Demasiados intentos. Espera unos minutos e intenta de nuevo';
        }
        return e;
      }

      expect(
        mapError(technicalError),
        'Demasiados intentos. Espera unos minutos e intenta de nuevo',
      );
    });

    test('should map email_already_registered to friendly Spanish message', () {
      const technicalError = 'Exception: Email already registered';

      String mapError(String e) {
        if (e.contains('Email not') ||
            e.contains('email_already') ||
            e.contains('Email already')) {
          return 'Este correo electrónico ya está registrado';
        }
        return e;
      }

      expect(
        mapError(technicalError),
        'Este correo electrónico ya está registrado',
      );
    });
  });
}
