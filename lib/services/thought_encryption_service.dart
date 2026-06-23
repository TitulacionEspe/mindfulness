import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ThoughtKeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SecureStorageThoughtKeyStore implements ThoughtKeyStore {
  SecureStorageThoughtKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }
}

class MemoryThoughtKeyStore implements ThoughtKeyStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

class ThoughtEncryptionService {
  ThoughtEncryptionService({ThoughtKeyStore? keyStore, AesGcm? algorithm})
    : _keyStore = keyStore ?? SecureStorageThoughtKeyStore(),
      _algorithm = algorithm ?? AesGcm.with256bits();

  static const String versionPrefix = 'v1';

  final ThoughtKeyStore _keyStore;
  final AesGcm _algorithm;
  final Map<String, SecretKey> _keyCache = {};

  bool isEncrypted(String value) => value.startsWith('$versionPrefix:');

  Future<String> encrypt(String plainText, {required String userId}) async {
    final secretKey = await _secretKeyFor(userId);
    final nonce = _algorithm.newNonce();
    final box = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
    );

    return [
      versionPrefix,
      _encode(box.nonce),
      _encode(box.cipherText),
      _encode(box.mac.bytes),
    ].join(':');
  }

  Future<String> decrypt(String storedValue, {required String userId}) async {
    if (!isEncrypted(storedValue)) return storedValue;

    final parts = storedValue.split(':');
    if (parts.length != 4 || parts.first != versionPrefix) {
      throw const ThoughtDecryptionException();
    }

    try {
      final secretKey = await _secretKeyFor(userId);
      final clearBytes = await _algorithm.decrypt(
        SecretBox(
          _decode(parts[2]),
          nonce: _decode(parts[1]),
          mac: Mac(_decode(parts[3])),
        ),
        secretKey: secretKey,
      );
      return utf8.decode(clearBytes);
    } catch (_) {
      throw const ThoughtDecryptionException();
    }
  }

  Future<SecretKey> _secretKeyFor(String userId) async {
    final cacheKey = _storageKey(userId);
    final cached = _keyCache[cacheKey];
    if (cached != null) return cached;

    final stored = await _keyStore.read(cacheKey);
    if (stored != null && stored.isNotEmpty) {
      final key = SecretKey(_decode(stored));
      _keyCache[cacheKey] = key;
      return key;
    }

    final generated = await _algorithm.newSecretKey();
    final generatedBytes = await generated.extractBytes();
    await _keyStore.write(cacheKey, _encode(generatedBytes));
    _keyCache[cacheKey] = generated;
    return generated;
  }

  String _storageKey(String userId) => 'nidara_thought_key_$userId';

  String _encode(List<int> bytes) => base64UrlEncode(bytes);

  List<int> _decode(String value) => base64Url.decode(value);
}

class ThoughtDecryptionException implements Exception {
  const ThoughtDecryptionException();
}
