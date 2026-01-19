import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';

  /// Sauvegarder le token d'authentification
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Récupérer le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Sauvegarder le refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  /// Récupérer le refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Supprimer les tokens (déconnexion)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
  }

  /// Vérifier si l'utilisateur est authentifié
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
