import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import '../services/secure_storage_service.dart';

class EncryptionHelper {
  // We should fetch the key from secure storage if it exists, otherwise generate one.
  static late final Key _key;
  static final IV _iv = IV.fromLength(16);

  static Future<void> init() async {
    String? storedKey = await SecureStorageService.getEncryptionKey();
    if (storedKey == null) {
      // Generate a new 32-character key for AES-256
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      storedKey = base64Url.encode(values).substring(0, 32); 
      await SecureStorageService.saveEncryptionKey(storedKey);
    }
    _key = Key.fromUtf8(storedKey);
  }

  static String encrypt(String plainText) {
    if (plainText.isEmpty) return "";
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String cipherText) {
    if (cipherText.isEmpty) return "";
    try {
      final encrypter = Encrypter(AES(_key));
      final decrypted = encrypter.decrypt(Encrypted.fromBase64(cipherText), iv: _iv);
      return decrypted;
    } catch (e) {
      return "Unable to decrypt note content.";
    }
  }
}
