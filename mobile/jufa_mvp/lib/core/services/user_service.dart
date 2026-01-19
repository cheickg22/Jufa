import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class UserService {
  static const String _keyUserId = 'user_id';
  static const String _keyFirstName = 'user_first_name';
  static const String _keyLastName = 'user_last_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhone = 'user_phone';
  static const String _keyBalance = 'user_balance';
  static const String _keyPin = 'user_pin';
  
  // Clés pour les derniers identifiants de connexion (persistants)
  static const String _keyLastLoginEmail = 'last_login_email';
  static const String _keyLastLoginPhone = 'last_login_phone';
  static const String _keyLastLoginPassword = 'last_login_password';
  
  // Préfixes pour les données utilisateur par identifiant
  static const String _prefixUserData = 'user_data_';

  // Générer une clé unique basée sur l'identifiant de connexion
  static String _generateUserKey(String identifier, String field) {
    // Nettoyer l'identifiant pour créer une clé valide
    final cleanIdentifier = identifier.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return '${_prefixUserData}${cleanIdentifier}_$field';
  }

  // Sauvegarder les informations utilisateur pour un identifiant spécifique
  static Future<void> saveUserInfoForIdentifier({
    required String identifier,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? password,
    double balance = 0.0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sauvegarder avec des clés spécifiques à l'identifiant
    await prefs.setString(_generateUserKey(identifier, 'firstName'), firstName);
    await prefs.setString(_generateUserKey(identifier, 'lastName'), lastName);
    await prefs.setString(_generateUserKey(identifier, 'email'), email);
    await prefs.setString(_generateUserKey(identifier, 'phone'), phone);
    await prefs.setDouble(_generateUserKey(identifier, 'balance'), balance);
    
    // Sauvegarder le mot de passe si fourni
    if (password != null && password.isNotEmpty) {
      await prefs.setString(_generateUserKey(identifier, 'password'), password);
    }
  }

  // Charger les informations utilisateur pour un identifiant spécifique
  static Future<void> loadUserInfoForIdentifier(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Récupérer les données spécifiques à cet identifiant
    final firstName = prefs.getString(_generateUserKey(identifier, 'firstName')) ?? '';
    final lastName = prefs.getString(_generateUserKey(identifier, 'lastName')) ?? '';
    final email = prefs.getString(_generateUserKey(identifier, 'email')) ?? '';
    final phone = prefs.getString(_generateUserKey(identifier, 'phone')) ?? '';
    final balance = prefs.getDouble(_generateUserKey(identifier, 'balance')) ?? 250000.0;
    
    // Charger dans la session courante
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      await prefs.setString(_keyFirstName, firstName);
      await prefs.setString(_keyLastName, lastName);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyPhone, phone);
      await prefs.setDouble(_keyBalance, balance);
    }
  }

  // Sauvegarder les informations utilisateur (méthode legacy pour compatibilité)
  static Future<void> saveUserInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? password,
    double balance = 0.0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Sauvegarder les données de session
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
    await prefs.setDouble(_keyBalance, balance);
    
    // Déterminer l'identifiant principal (téléphone prioritaire)
    final identifier = phone.isNotEmpty ? phone : email;
    if (identifier.isNotEmpty) {
      // Sauvegarder aussi avec l'identifiant spécifique
      await saveUserInfoForIdentifier(
        identifier: identifier,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        balance: balance,
      );
    }
  }

  // Sauvegarder l'ID utilisateur
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  // Récupérer l'ID utilisateur
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Récupérer le prénom
  static Future<String> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFirstName) ?? '';
  }

  // Récupérer le nom
  static Future<String> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastName) ?? '';
  }

  // Récupérer le nom complet
  static Future<String> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_keyFirstName) ?? '';
    final lastName = prefs.getString(_keyLastName) ?? '';
    
    if (firstName.isEmpty && lastName.isEmpty) {
      return 'Utilisateur'; // Nom par défaut
    }
    
    return '$firstName $lastName'.trim();
  }

  // Récupérer les initiales
  static Future<String> getInitials() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_keyFirstName) ?? '';
    final lastName = prefs.getString(_keyLastName) ?? '';
    
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    
    return initials.isEmpty ? 'U' : initials;
  }

  // Récupérer l'email
  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  // Récupérer le téléphone
  static Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone) ?? '';
  }

  // Récupérer le solde
  static Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBalance) ?? 250000.0; // Solde par défaut pour le MVP
  }

  // Mettre à jour le solde
  static Future<void> updateBalance(double newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBalance, newBalance);
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_keyFirstName);
    return firstName != null && firstName.isNotEmpty;
  }

  // Sauvegarder les derniers identifiants de connexion (persistants)
  static Future<void> saveLastLoginCredentials({
    required String email,
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLoginEmail, email);
    await prefs.setString(_keyLastLoginPhone, phone);
    await prefs.setString(_keyLastLoginPassword, password);
  }

  // Récupérer les derniers identifiants de connexion
  static Future<Map<String, String>> getLastLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyLastLoginEmail) ?? '',
      'phone': prefs.getString(_keyLastLoginPhone) ?? '',
      'password': prefs.getString(_keyLastLoginPassword) ?? '',
    };
  }

  // Effacer les derniers identifiants de connexion
  static Future<void> clearLastLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastLoginEmail);
    await prefs.remove(_keyLastLoginPhone);
    await prefs.remove(_keyLastLoginPassword);
  }

  // Sauvegarder le mot de passe pour un identifiant spécifique
  static Future<void> savePasswordForIdentifier({
    required String identifier,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_generateUserKey(identifier, 'password'), password);
  }

  // Vérifier le mot de passe pour un identifiant spécifique
  static Future<bool> verifyPasswordForIdentifier({
    required String identifier,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString(_generateUserKey(identifier, 'password')) ?? '';
    
    print('🔐 Vérification mot de passe pour: $identifier');
    print('🔑 Clé password: ${_generateUserKey(identifier, 'password')}');
    print('💾 Mot de passe sauvegardé: ${savedPassword.isNotEmpty ? "***" : "(vide)"}');
    print('🔓 Mot de passe saisi: ${password.isNotEmpty ? "***" : "(vide)"}');
    print('✅ Correspondance: ${savedPassword == password}');
    
    return savedPassword.isNotEmpty && savedPassword == password;
  }

  // Vérifier si un identifiant existe
  static Future<bool> identifierExists(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_generateUserKey(identifier, 'firstName')) ?? '';
    final password = prefs.getString(_generateUserKey(identifier, 'password')) ?? '';
    
    // Debug: afficher les clés et valeurs
    print('🔍 Vérification identifiant: $identifier');
    print('🔑 Clé firstName: ${_generateUserKey(identifier, 'firstName')}');
    print('👤 FirstName trouvé: $firstName');
    print('🔑 Clé password: ${_generateUserKey(identifier, 'password')}');
    print('🔒 Password existe: ${password.isNotEmpty}');
    
    // Debug: afficher toutes les clés qui commencent par user_data_
    print('📋 Toutes les clés sauvegardées:');
    final allKeys = prefs.getKeys();
    for (var key in allKeys) {
      if (key.startsWith(_prefixUserData)) {
        print('   - $key');
      }
    }
    
    return firstName.isNotEmpty && password.isNotEmpty;
  }

  // Restaurer les données utilisateur pour un identifiant spécifique
  static Future<void> restoreUserDataForIdentifier(String identifier) async {
    await loadUserInfoForIdentifier(identifier);
  }

  // Sauvegarder le code PIN
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, pin);
  }

  // Récupérer le code PIN
  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPin);
  }

  // Vérifier si un PIN est configuré
  static Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  // Déconnexion (effacer les données de session mais garder les identifiants)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstName);
    await prefs.remove(_keyLastName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyBalance);
    await prefs.remove(_keyUserId);
    
    // Supprimer les tokens d'authentification
    await AuthService.clearTokens();
    
    // Note: On ne supprime pas les derniers identifiants de connexion ni les données persistantes ni le PIN
  }
}
