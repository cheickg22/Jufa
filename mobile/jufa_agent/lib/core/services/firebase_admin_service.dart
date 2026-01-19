import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service Firebase Admin pour l'envoi de notifications depuis le backend
/// ⚠️ NE PAS UTILISER DANS L'APP MOBILE - BACKEND UNIQUEMENT
class FirebaseAdminService {
  static const String _projectId = 'jufa-c404f';
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  
  // ⚠️ CETTE CLÉ DOIT ÊTRE STOCKÉE CÔTÉ SERVEUR UNIQUEMENT
  static const String _serviceAccountEmail = 'firebase-adminsdk-fbsvc@jufa-c404f.iam.gserviceaccount.com';

  /// Envoyer une notification via Firebase Admin SDK
  /// ⚠️ Cette méthode doit être appelée depuis un serveur backend sécurisé
  static Future<bool> sendNotificationViaAdmin({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
    String? imageUrl,
  }) async {
    try {
      // ⚠️ En production, utilisez les credentials du service account
      // depuis des variables d'environnement ou un service de secrets
      
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        print('❌ Impossible d\'obtenir le token d\'accès');
        return false;
      }

      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data ?? {},
          'android': {
            'notification': {
              'channel_id': 'jufa_default',
              'sound': 'default',
              'priority': 'high',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Notification Admin envoyée avec succès');
        return true;
      } else {
        print('❌ Erreur Admin: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur Admin Service: $e');
      return false;
    }
  }

  /// Obtenir un token d'accès OAuth2
  /// ⚠️ Cette méthode nécessite les credentials du service account
  static Future<String?> _getAccessToken() async {
    // ⚠️ EN PRODUCTION: Utilisez les credentials depuis un fichier sécurisé
    // ou des variables d'environnement
    
    print('⚠️ ATTENTION: Cette méthode nécessite une implémentation backend sécurisée');
    print('📖 Consultez la documentation Firebase Admin SDK');
    
    // Retourner null pour forcer l'utilisation du service simplifié
    return null;
  }

  /// Envoyer des notifications en masse via Admin SDK
  static Future<Map<String, dynamic>> sendBulkNotificationViaAdmin({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, String>? data,
    String? imageUrl,
  }) async {
    int successCount = 0;
    int failureCount = 0;
    List<String> failedTokens = [];

    for (final token in tokens) {
      final success = await sendNotificationViaAdmin(
        token: token,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );

      if (success) {
        successCount++;
      } else {
        failureCount++;
        failedTokens.add(token);
      }
    }

    return {
      'success_count': successCount,
      'failure_count': failureCount,
      'failed_tokens': failedTokens,
      'total_sent': tokens.length,
    };
  }
}

/// Configuration pour l'environnement de production
class FirebaseAdminConfig {
  static const bool useAdminSDK = false; // Activer en production avec backend
  static const bool useServiceAccount = false; // Activer avec credentials sécurisés
  
  /// Vérifier si l'Admin SDK est disponible
  static bool get isAdminSDKAvailable {
    return useAdminSDK && useServiceAccount;
  }
  
  /// Instructions pour la configuration de production
  static String get productionSetupInstructions => '''
🔧 CONFIGURATION FIREBASE ADMIN SDK POUR PRODUCTION

1. 📁 Serveur Backend (Node.js, Python, PHP, etc.)
   - Installer Firebase Admin SDK
   - Configurer les credentials du service account
   - Créer des endpoints API sécurisés

2. 🔑 Gestion des Credentials
   - Stocker firebase_service_account.json côté serveur
   - Utiliser des variables d'environnement
   - Ne JAMAIS exposer les clés dans l'app mobile

3. 🛡️ Sécurité
   - Authentifier les requêtes API
   - Valider les tokens utilisateur
   - Limiter les taux d'envoi (rate limiting)

4. 📱 App Mobile
   - Envoyer les demandes de notification à votre API
   - Utiliser FirebaseSimpleService pour recevoir
   - Ne pas inclure les credentials Admin

5. 🧪 Test
   - Tester avec Firebase Console d'abord
   - Valider les tokens FCM
   - Vérifier les permissions de notification

📖 Documentation: https://firebase.google.com/docs/admin/setup
''';
}

/// Exemple d'utilisation recommandée
class NotificationExample {
  /// Exemple d'envoi via l'API backend (recommandé)
  static Future<void> sendViaBackendAPI({
    required String userToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // Appeler votre API backend qui utilise Firebase Admin SDK
    try {
      final response = await http.post(
        Uri.parse('https://votre-api.com/notifications/send'),
        headers: {
          'Authorization': 'Bearer YOUR_USER_JWT_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': userToken,
          'title': title,
          'body': body,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notification envoyée via API backend');
      } else {
        print('❌ Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur réseau: $e');
    }
  }
}
