import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/services/thought_encryption_service.dart';

void main() {
  group('ThoughtEncryptionService', () {
    test('encrypts and decrypts content for the same user', () async {
      final service = ThoughtEncryptionService(
        keyStore: MemoryThoughtKeyStore(),
      );

      final encrypted = await service.encrypt(
        'pensamiento privado',
        userId: 'patient-1',
      );
      final decrypted = await service.decrypt(encrypted, userId: 'patient-1');

      expect(encrypted.startsWith('v1:'), isTrue);
      expect(encrypted, isNot(contains('pensamiento privado')));
      expect(decrypted, 'pensamiento privado');
    });

    test('keeps legacy plain text readable', () async {
      final service = ThoughtEncryptionService(
        keyStore: MemoryThoughtKeyStore(),
      );

      final decrypted = await service.decrypt(
        'entrada antigua',
        userId: 'patient-1',
      );

      expect(decrypted, 'entrada antigua');
    });

    test('fails to decrypt content with another user key', () async {
      final service = ThoughtEncryptionService(
        keyStore: MemoryThoughtKeyStore(),
      );

      final encrypted = await service.encrypt('privado', userId: 'patient-1');

      expect(
        () => service.decrypt(encrypted, userId: 'patient-2'),
        throwsA(isA<ThoughtDecryptionException>()),
      );
    });
  });
}
