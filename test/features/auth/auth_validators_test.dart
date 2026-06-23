import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/features/auth/domain/validators/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('normaliza nombre y correo sin perder tildes', () {
      expect(AuthValidators.normalizeName('  Ana   María  '), 'Ana María');
      expect(
        AuthValidators.normalizeEmail('  ANA@Example.COM '),
        'ana@example.com',
      );
    });

    test('valida longitud y formato de nombre', () {
      expect(AuthValidators.fullName('An'), isNotNull);
      expect(AuthValidators.fullName('Ana María'), isNull);
      expect(AuthValidators.fullName('Ana123'), isNotNull);
    });

    test('valida correo requerido, formato y longitud máxima', () {
      expect(AuthValidators.email(''), 'Ingresa tu correo.');
      expect(
        AuthValidators.email('correo-invalido'),
        'Ingresa un correo válido.',
      );
      expect(AuthValidators.email('a@nidara.app'), isNull);
      expect(AuthValidators.email('${'a' * 245}@nidara.app'), isNotNull);
    });

    test('exige contraseña segura y confirmación coincidente', () {
      expect(AuthValidators.securePassword('abc123'), isNotNull);
      expect(
        AuthValidators.securePassword('abcdefgh'),
        'Incluye al menos un número.',
      );
      expect(
        AuthValidators.securePassword('12345678'),
        'Incluye al menos una letra.',
      );
      expect(AuthValidators.securePassword('Nidara123'), isNull);
      expect(
        AuthValidators.confirmPassword('Nidara1234', 'Nidara123'),
        'Las contraseñas no coinciden.',
      );
    });
  });
}
