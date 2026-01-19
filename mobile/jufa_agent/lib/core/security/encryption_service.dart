import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;
  
  EncryptionService({String? customKey}) {
    // En production, utiliser une clé depuis les variables d'environnement
    final keyString = customKey ?? 
                     const String.fromEnvironment('ENCRYPTION_KEY', 
                       defaultValue: 'JufaMali2025SecureKey32CharLong!');
    
    _key = Key.fromUtf8(keyString.padRight(32).substring(0, 32));
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(_key));
  }
  
  // Chiffrer une chaîne
  String encrypt(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Erreur de chiffrement: $e');
    }
  }
  
  // Déchiffrer une chaîne
  String decrypt(String encryptedText) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('Erreur de déchiffrement: $e');
    }
  }
  
  // Hasher une chaîne (pour les mots de passe, pins, etc.)
  String hash(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Vérifier un hash
  bool verifyHash(String text, String hashedText) {
    return hash(text) == hashedText;
  }
  
  // Générer un token aléatoire
  String generateToken({int length = 32}) {
    final random = Key.fromSecureRandom(length);
    return base64Url.encode(random.bytes);
  }
}
