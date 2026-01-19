import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  
  SecureStorageService(this._storage);
  
  // Écrire une valeur
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Erreur lors de l\'écriture sécurisée: $e');
    }
  }
  
  // Lire une valeur
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture sécurisée: $e');
    }
  }
  
  // Supprimer une valeur
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Erreur lors de la suppression sécurisée: $e');
    }
  }
  
  // Supprimer toutes les valeurs
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Erreur lors de la suppression totale: $e');
    }
  }
  
  // Vérifier si une clé existe
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }
  
  // Lire toutes les valeurs
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw Exception('Erreur lors de la lecture totale: $e');
    }
  }
}
