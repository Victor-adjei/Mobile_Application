import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _notesKey = 'encrypted_notes';
  static const String _pinHashKey = 'pin_hash';
  static const String _encryptionKey = 'encryption_key'; // For note content encryption

  // Save encrypted notes as JSON string
  static Future<void> saveNotes(String encryptedJson) async {
    await _storage.write(key: _notesKey, value: encryptedJson);
  }

  static Future<String?> loadNotes() async {
    return await _storage.read(key: _notesKey);
  }

  // Save hashed PIN (never store raw PIN)
  static Future<void> savePinHash(String hash) async {
    await _storage.write(key: _pinHashKey, value: hash);
  }

  static Future<String?> loadPinHash() async {
    return await _storage.read(key: _pinHashKey);
  }

  // Save encryption key for notes
  static Future<void> saveEncryptionKey(String key) async {
    await _storage.write(key: _encryptionKey, value: key);
  }

  static Future<String?> getEncryptionKey() async {
    return await _storage.read(key: _encryptionKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
