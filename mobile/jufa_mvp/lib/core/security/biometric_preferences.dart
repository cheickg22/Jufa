import 'package:shared_preferences/shared_preferences.dart';

class BiometricPreferences {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastBiometricCheckKey = 'last_biometric_check';
  
  // Vérifier si la biométrie est activée
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  // Activer/désactiver la biométrie
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    
    if (enabled) {
      // Enregistrer la date d'activation
      await prefs.setInt(_lastBiometricCheckKey, DateTime.now().millisecondsSinceEpoch);
    }
  }
  
  // Obtenir la dernière vérification biométrique
  static Future<DateTime?> getLastBiometricCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastBiometricCheckKey);
    
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    return null;
  }
  
  // Vérifier si une nouvelle authentification est requise (ex: après 24h)
  static Future<bool> isReauthenticationRequired() async {
    final lastCheck = await getLastBiometricCheck();
    
    if (lastCheck == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastCheck);
    
    // Réauthentification requise après 24 heures
    return difference.inHours >= 24;
  }
  
  // Mettre à jour le timestamp de la dernière vérification
  static Future<void> updateLastBiometricCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBiometricCheckKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  // Réinitialiser toutes les préférences biométriques
  static Future<void> resetBiometricPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricEnabledKey);
    await prefs.remove(_lastBiometricCheckKey);
  }
}
