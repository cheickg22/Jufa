import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import '../../features/marketplace/domain/models/marketplace_models.dart';

class MerchantAPIService {
  static const String _baseUrl = 'https://api.jufa.ml/v1/merchants';
  static const String _webhookSecret = 'jufa_webhook_secret_2024';
  
  // Headers d'authentification pour les partenaires
  static Map<String, String> _getAuthHeaders(String apiKey) {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Version': '1.0',
      'User-Agent': 'Jufa-Mobile/1.0',
    };
  }

  /// Enregistrer un nouveau marchand partenaire
  static Future<Map<String, dynamic>> registerMerchant({
    required String businessName,
    required String businessType,
    required String contactEmail,
    required String contactPhone,
    required String address,
    required Map<String, dynamic> businessDocuments,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: _getAuthHeaders('public_key'),
        body: json.encode({
          'business_name': businessName,
          'business_type': businessType,
          'contact_email': contactEmail,
          'contact_phone': contactPhone,
          'address': address,
          'business_documents': businessDocuments,
          'requested_services': ['payments', 'loyalty', 'analytics'],
          'callback_url': 'https://merchant.example.com/jufa/webhook',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'merchant_id': data['merchant_id'],
          'api_key': data['api_key'],
          'secret_key': data['secret_key'],
          'status': data['status'], // pending, approved, rejected
          'message': 'Demande d\'enregistrement soumise avec succès',
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de l\'enregistrement: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Créer une transaction de paiement
  static Future<Map<String, dynamic>> createPayment({
    required String merchantId,
    required String apiKey,
    required double amount,
    required String currency,
    required String orderId,
    required String customerPhone,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$merchantId/payments'),
        headers: _getAuthHeaders(apiKey),
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'order_id': orderId,
          'customer_phone': customerPhone,
          'description': description ?? 'Paiement Jufa',
          'metadata': metadata ?? {},
          'callback_url': 'https://merchant.example.com/payment/callback',
          'return_url': 'https://merchant.example.com/payment/success',
          'cancel_url': 'https://merchant.example.com/payment/cancel',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'payment_id': data['payment_id'],
          'payment_url': data['payment_url'],
          'qr_code': data['qr_code'],
          'expires_at': data['expires_at'],
          'status': data['status'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la création du paiement: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Vérifier le statut d'un paiement
  static Future<Map<String, dynamic>> checkPaymentStatus({
    required String merchantId,
    required String apiKey,
    required String paymentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$merchantId/payments/$paymentId'),
        headers: _getAuthHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'payment_id': data['payment_id'],
          'status': data['status'], // pending, completed, failed, cancelled
          'amount': data['amount'],
          'currency': data['currency'],
          'customer_phone': data['customer_phone'],
          'completed_at': data['completed_at'],
          'failure_reason': data['failure_reason'],
        };
      } else {
        return {
          'success': false,
          'error': 'Paiement non trouvé: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Rembourser un paiement
  static Future<Map<String, dynamic>> refundPayment({
    required String merchantId,
    required String apiKey,
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$merchantId/payments/$paymentId/refund'),
        headers: _getAuthHeaders(apiKey),
        body: json.encode({
          'amount': amount,
          'reason': reason ?? 'Remboursement demandé par le marchand',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'refund_id': data['refund_id'],
          'status': data['status'],
          'amount': data['amount'],
          'processed_at': data['processed_at'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors du remboursement: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Obtenir les statistiques du marchand
  static Future<Map<String, dynamic>> getMerchantStats({
    required String merchantId,
    required String apiKey,
    String period = 'month', // day, week, month, year
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$merchantId/stats?period=$period'),
        headers: _getAuthHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'period': data['period'],
          'total_transactions': data['total_transactions'],
          'total_amount': data['total_amount'],
          'successful_transactions': data['successful_transactions'],
          'failed_transactions': data['failed_transactions'],
          'refunded_amount': data['refunded_amount'],
          'commission_earned': data['commission_earned'],
          'top_customers': data['top_customers'],
          'transaction_trends': data['transaction_trends'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la récupération des stats: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Gérer les points de fidélité
  static Future<Map<String, dynamic>> manageLoyaltyPoints({
    required String merchantId,
    required String apiKey,
    required String customerPhone,
    required String action, // 'add', 'redeem', 'check'
    int points = 0,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$merchantId/loyalty'),
        headers: _getAuthHeaders(apiKey),
        body: json.encode({
          'customer_phone': customerPhone,
          'action': action,
          'points': points,
          'description': description ?? 'Transaction de points',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'customer_phone': data['customer_phone'],
          'current_points': data['current_points'],
          'points_changed': data['points_changed'],
          'transaction_id': data['transaction_id'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la gestion des points: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Valider un webhook
  static bool validateWebhook(String payload, String signature) {
    try {
      final expectedSignature = _generateWebhookSignature(payload);
      return signature == expectedSignature;
    } catch (e) {
      print('Erreur lors de la validation du webhook: $e');
      return false;
    }
  }

  /// Traiter un webhook
  static Map<String, dynamic> processWebhook(String payload) {
    try {
      final data = json.decode(payload);
      final eventType = data['event_type'] as String;
      final eventData = data['data'] as Map<String, dynamic>;

      switch (eventType) {
        case 'payment.completed':
          return _handlePaymentCompleted(eventData);
        case 'payment.failed':
          return _handlePaymentFailed(eventData);
        case 'refund.processed':
          return _handleRefundProcessed(eventData);
        case 'merchant.approved':
          return _handleMerchantApproved(eventData);
        default:
          return {
            'success': false,
            'error': 'Type d\'événement non supporté: $eventType',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur lors du traitement du webhook: $e',
      };
    }
  }

  /// Obtenir les produits d'un marchand
  static Future<List<Product>> getMerchantProducts({
    required String merchantId,
    required String apiKey,
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
      };
      
      final uri = Uri.parse('$_baseUrl/$merchantId/products')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: _getAuthHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final productsData = data['products'] as List;
        return productsData.map((p) => Product.fromJson(p)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des produits: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  // Méthodes privées

  static String _generateWebhookSignature(String payload) {
    final key = utf8.encode(_webhookSecret);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return 'sha256=${digest.toString()}';
  }

  static Map<String, dynamic> _handlePaymentCompleted(Map<String, dynamic> data) {
    return {
      'success': true,
      'event': 'payment_completed',
      'payment_id': data['payment_id'],
      'amount': data['amount'],
      'customer_phone': data['customer_phone'],
      'completed_at': data['completed_at'],
      'action': 'update_order_status',
    };
  }

  static Map<String, dynamic> _handlePaymentFailed(Map<String, dynamic> data) {
    return {
      'success': true,
      'event': 'payment_failed',
      'payment_id': data['payment_id'],
      'failure_reason': data['failure_reason'],
      'action': 'notify_customer',
    };
  }

  static Map<String, dynamic> _handleRefundProcessed(Map<String, dynamic> data) {
    return {
      'success': true,
      'event': 'refund_processed',
      'refund_id': data['refund_id'],
      'amount': data['amount'],
      'processed_at': data['processed_at'],
      'action': 'update_accounting',
    };
  }

  static Map<String, dynamic> _handleMerchantApproved(Map<String, dynamic> data) {
    return {
      'success': true,
      'event': 'merchant_approved',
      'merchant_id': data['merchant_id'],
      'approved_at': data['approved_at'],
      'action': 'activate_services',
    };
  }
}

/// Classe pour gérer les configurations des partenaires
class MerchantConfig {
  final String merchantId;
  final String apiKey;
  final String secretKey;
  final bool isActive;
  final List<String> enabledServices;
  final Map<String, dynamic> settings;

  const MerchantConfig({
    required this.merchantId,
    required this.apiKey,
    required this.secretKey,
    required this.isActive,
    required this.enabledServices,
    required this.settings,
  });

  factory MerchantConfig.fromJson(Map<String, dynamic> json) {
    return MerchantConfig(
      merchantId: json['merchant_id'] ?? '',
      apiKey: json['api_key'] ?? '',
      secretKey: json['secret_key'] ?? '',
      isActive: json['is_active'] ?? false,
      enabledServices: List<String>.from(json['enabled_services'] ?? []),
      settings: json['settings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'api_key': apiKey,
      'secret_key': secretKey,
      'is_active': isActive,
      'enabled_services': enabledServices,
      'settings': settings,
    };
  }
}
