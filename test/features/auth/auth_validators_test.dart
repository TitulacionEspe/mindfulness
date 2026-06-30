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

    test('acepta un nombre y un apellido ecuatoriano', () {
      expect(AuthValidators.fullName('Doménica Cevallos'), isNull);
    });

    test('rechaza un solo nombre y más de dos palabras', () {
      expect(
        AuthValidators.fullName('Doménica'),
        'Ingresa solo un nombre y un apellido.',
      );
      expect(
        AuthValidators.fullName('Doménica Isabel Cevallos'),
        'Ingresa solo un nombre y un apellido.',
      );
    });

    test('rechaza nombre mayor a 50 caracteres y caracteres inválidos', () {
      expect(
        AuthValidators.fullName('${'A' * 49} B'),
        'El nombre no debe superar 50 caracteres.',
      );
      expect(
        AuthValidators.fullName('Doménica Cevallos1'),
        'Usa solo letras, espacios, guiones o apóstrofes.',
      );
    });

    test('valida correo requerido, formato y longitud máxima', () {
      final validMaxEmail = '${'a' * 243}@nidara.app';
      final invalidLongEmail = '${'a' * 244}@nidara.app';

      expect(AuthValidators.email(''), 'Ingresa tu correo.');
      expect(
        AuthValidators.email('correo-invalido'),
        'Ingresa un correo válido.',
      );
      expect(validMaxEmail.length, AuthValidators.maxEmailLength);
      expect(AuthValidators.email(validMaxEmail), isNull);
      expect(invalidLongEmail.length, AuthValidators.maxEmailLength + 1);
      expect(
        AuthValidators.email(invalidLongEmail),
        'El correo no debe superar 254 caracteres.',
      );
    });

    test('exige contraseña segura y confirmación coincidente', () {
      expect(AuthValidators.securePassword('Nidara1@'), isNull);
      expect(
        AuthValidators.securePassword('nidara1@'),
        'Incluye al menos una letra mayúscula.',
      );
      expect(
        AuthValidators.securePassword('NIDARA1@'),
        'Incluye al menos una letra minúscula.',
      );
      expect(
        AuthValidators.securePassword('Nidara@@'),
        'Incluye al menos un número.',
      );
      expect(
        AuthValidators.securePassword('Nidara12'),
        'Incluye al menos un carácter especial: *, . o @.',
      );
      expect(
        AuthValidators.securePassword('Nidara1#'),
        'Usa solo letras, números y los caracteres especiales *, . o @.',
      );
      expect(
        AuthValidators.securePassword('Nidara1@#'),
        'Usa solo letras, números y los caracteres especiales *, . o @.',
      );
      expect(
        AuthValidators.securePassword('Nidara1@${'a' * 23}'),
        'La contraseña debe tener entre 8 y 30 caracteres.',
      );
      expect(
        AuthValidators.confirmPassword('Nidara1.', 'Nidara1@'),
        'Las contraseñas no coinciden.',
      );
      expect(AuthValidators.confirmPassword('Nidara1@', 'Nidara1@'), isNull);
    });
  });
}
