import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service de notifications simplifié pour Jufa
class NotificationService {
  static const String _oneSignalAppId = 'your_onesignal_app_id';
  static const String _oneSignalApiKey = 'your_onesignal_api_key';
  
  static StreamController<Map<String, dynamic>>? _notificationController;
  static Stream<Map<String, dynamic>>? _notificationStream;
  static String? _deviceToken;

  /// Initialiser le service de notifications
  static Future<void> initialize() async {
    try {
      // Configurer le stream de notifications
      _notificationController = StreamController<Map<String, dynamic>>.broadcast();
      _notificationStream = _notificationController!.stream;
      
      // Générer un token de device simulé
      _deviceToken = 'device_token_${DateTime.now().millisecondsSinceEpoch}';
      
      print('Service de notifications simplifié initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  /// Obtenir le token du device
  static String? getDeviceToken() {
    return _deviceToken;
  }

  /// Envoyer une notification via HTTP (simulation)
  static Future<bool> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      // Simulation d'envoi de notification
      print('📱 Notification envoyée:');
      print('   Token: $token');
      print('   Titre: $title');
      print('   Message: $body');
      print('   Data: $data');
      
      // Simuler une réponse réussie
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Ajouter au stream local
      _notificationController?.add({
        'type': 'sent',
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Erreur lors de l\'envoi de notification: $e');
      return false;
    }
  }

  /// Envoyer une notification à plusieurs utilisateurs
  static Future<Map<String, dynamic>> sendBulkNotification({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      int successCount = 0;
      int failureCount = 0;
      
      for (final token in tokens) {
        final success = await sendNotification(
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
        }
      }
      
      return {
        'success': true,
        'success_count': successCount,
        'failure_count': failureCount,
        'total_tokens': tokens.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur lors de l\'envoi groupé: $e',
      };
    }
  }

  /// Envoyer via OneSignal (simulation)
  static Future<bool> sendOneSignalNotification({
    required List<String> playerIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? url,
  }) async {
    try {
      print('🔔 OneSignal Notification:');
      print('   Players: ${playerIds.length}');
      print('   Titre: $title');
      print('   Message: $message');
      
      // Simulation d'envoi OneSignal
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      print('Erreur lors de l\'envoi OneSignal: $e');
      return false;
    }
  }

  /// Afficher une notification locale (simulation)
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    try {
      print('📲 Notification locale:');
      print('   ID: $id');
      print('   Titre: $title');
      print('   Message: $body');
      print('   Payload: $payload');
      
      // Ajouter au stream
      _notificationController?.add({
        'type': 'local',
        'id': id,
        'title': title,
        'body': body,
        'payload': payload,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de l\'affichage de notification locale: $e');
    }
  }

  /// Envoyer notification de transaction
  static Future<void> sendTransactionNotification({
    required String userToken,
    required String type,
    required double amount,
    required String currency,
    required String status,
    String? merchantName,
  }) async {
    final Map<String, String> titles = {
      'payment': 'Paiement ${status == 'completed' ? 'réussi' : 'en cours'}',
      'transfer': 'Transfert ${status == 'completed' ? 'effectué' : 'en cours'}',
      'deposit': 'Dépôt ${status == 'completed' ? 'reçu' : 'en cours'}',
      'withdrawal': 'Retrait ${status == 'completed' ? 'effectué' : 'en cours'}',
    };

    final Map<String, String> bodies = {
      'payment': '${amount.toStringAsFixed(0)} $currency ${merchantName != null ? 'chez $merchantName' : ''}',
      'transfer': '${amount.toStringAsFixed(0)} $currency transféré',
      'deposit': '${amount.toStringAsFixed(0)} $currency déposé sur votre compte',
      'withdrawal': '${amount.toStringAsFixed(0)} $currency retiré de votre compte',
    };

    await sendNotification(
      token: userToken,
      title: titles[type] ?? 'Transaction',
      body: bodies[type] ?? 'Nouvelle transaction',
      data: {
        'type': 'transaction',
        'transaction_type': type,
        'amount': amount.toString(),
        'currency': currency,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Envoyer notification de promotion
  static Future<void> sendPromotionNotification({
    required List<String> tokens,
    required String title,
    required String message,
    required String promoCode,
    String? imageUrl,
    String? deepLink,
  }) async {
    await sendBulkNotification(
      tokens: tokens,
      title: title,
      body: message,
      data: {
        'type': 'promotion',
        'promo_code': promoCode,
        'deep_link': deepLink,
        'timestamp': DateTime.now().toIso8601String(),
      },
      imageUrl: imageUrl,
    );
  }

  /// Obtenir le stream de notifications
  static Stream<Map<String, dynamic>>? get notificationStream => _notificationStream;

  /// S'abonner à un topic (simulation)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      print('✅ Abonné au topic: $topic');
    } catch (e) {
      print('Erreur lors de l\'abonnement au topic: $e');
    }
  }

  /// Se désabonner d'un topic (simulation)
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      print('❌ Désabonné du topic: $topic');
    } catch (e) {
      print('Erreur lors du désabonnement du topic: $e');
    }
  }

  /// Nettoyer les ressources
  static void dispose() {
    _notificationController?.close();
    _notificationController = null;
    _notificationStream = null;
  }
}

/// Types de notifications
enum NotificationType {
  transaction,
  promotion,
  security,
  system,
  marketing,
}

/// Configuration des notifications simplifiée
class SimpleNotificationConfig {
  final bool enablePush;
  final bool enableLocal;
  final bool enableEmail;
  final bool enableSMS;
  final List<NotificationType> enabledTypes;
  final Map<String, bool> topicSubscriptions;

  const SimpleNotificationConfig({
    this.enablePush = true,
    this.enableLocal = true,
    this.enableEmail = false,
    this.enableSMS = false,
    this.enabledTypes = const [NotificationType.transaction, NotificationType.security],
    this.topicSubscriptions = const {},
  });

  factory SimpleNotificationConfig.fromJson(Map<String, dynamic> json) {
    return SimpleNotificationConfig(
      enablePush: json['enable_push'] ?? true,
      enableLocal: json['enable_local'] ?? true,
      enableEmail: json['enable_email'] ?? false,
      enableSMS: json['enable_sms'] ?? false,
      enabledTypes: (json['enabled_types'] as List?)
          ?.map((e) => NotificationType.values.firstWhere(
                (type) => type.name == e,
                orElse: () => NotificationType.system,
              ))
          .toList() ?? [NotificationType.transaction],
      topicSubscriptions: Map<String, bool>.from(json['topic_subscriptions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_push': enablePush,
      'enable_local': enableLocal,
      'enable_email': enableEmail,
      'enable_sms': enableSMS,
      'enabled_types': enabledTypes.map((e) => e.name).toList(),
      'topic_subscriptions': topicSubscriptions,
    };
  }
}
