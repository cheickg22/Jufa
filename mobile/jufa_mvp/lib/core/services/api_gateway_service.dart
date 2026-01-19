import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class APIGatewayService {
  static const String _baseUrl = 'https://api.jufa.ml/v1';
  static const String _publicKey = 'jufa_public_key_2024';
  static const String _privateKey = 'jufa_private_key_2024';
  
  // Cache pour les tokens d'authentification
  static String? _accessToken;
  static DateTime? _tokenExpiry;
  static final Map<String, dynamic> _requestCache = {};

  /// Authentifier et obtenir un token d'accès
  static Future<String?> authenticate({
    required String clientId,
    required String clientSecret,
    List<String> scopes = const ['read', 'write'],
  }) async {
    try {
      // Vérifier si le token est encore valide
      if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
        return _accessToken;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
          'scope': scopes.join(' '),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60)); // 1 min de marge
        
        return _accessToken;
      } else {
        print('Erreur d\'authentification: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de l\'authentification: $e');
      return null;
    }
  }

  /// Effectuer une requête API sécurisée
  static Future<Map<String, dynamic>> secureRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool useCache = false,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    try {
      // Générer la clé de cache
      final cacheKey = _generateCacheKey(method, endpoint, body, queryParams);
      
      // Vérifier le cache si activé
      if (useCache && _requestCache.containsKey(cacheKey)) {
        final cachedData = _requestCache[cacheKey];
        final cacheTime = cachedData['timestamp'] as DateTime;
        if (DateTime.now().difference(cacheTime) < cacheDuration) {
          return cachedData['data'];
        }
      }

      // Construire l'URL
      final uri = Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: queryParams);
      
      // Générer la signature
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final nonce = _generateNonce();
      final signature = _generateSignature(method, endpoint, body, timestamp, nonce);
      
      // Headers de sécurité
      final secureHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': _publicKey,
        'X-Timestamp': timestamp,
        'X-Nonce': nonce,
        'X-Signature': signature,
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        ...?headers,
      };

      // Effectuer la requête
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: secureHeaders);
          break;
        case 'POST':
          response = await http.post(uri, headers: secureHeaders, body: body != null ? json.encode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: secureHeaders, body: body != null ? json.encode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: secureHeaders);
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      // Traiter la réponse
      final responseData = _processResponse(response);
      
      // Mettre en cache si demandé
      if (useCache && responseData['success'] == true) {
        _requestCache[cacheKey] = {
          'data': responseData,
          'timestamp': DateTime.now(),
        };
      }

      return responseData;
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de requête: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Uploader un fichier de manière sécurisée
  static Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, String>? additionalFields,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Ajouter le fichier
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      
      // Ajouter les champs additionnels
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      // Générer la signature pour l'upload
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final nonce = _generateNonce();
      final signature = _generateSignature('POST', endpoint, additionalFields, timestamp, nonce);
      
      // Headers de sécurité
      request.headers.addAll({
        'X-API-Key': _publicKey,
        'X-Timestamp': timestamp,
        'X-Nonce': nonce,
        'X-Signature': signature,
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        ...?headers,
      });

      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur d\'upload: $e',
      };
    }
  }

  /// Valider un webhook entrant
  static bool validateWebhook({
    required String payload,
    required String signature,
    required String timestamp,
    int maxAge = 300, // 5 minutes
  }) {
    try {
      // Vérifier l'âge du timestamp
      final requestTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      final age = DateTime.now().difference(requestTime).inSeconds;
      if (age > maxAge) {
        print('Webhook trop ancien: ${age}s');
        return false;
      }

      // Générer la signature attendue
      final expectedSignature = _generateWebhookSignature(payload, timestamp);
      
      // Comparer les signatures
      return _secureCompare(signature, expectedSignature);
    } catch (e) {
      print('Erreur lors de la validation du webhook: $e');
      return false;
    }
  }

  /// Chiffrer des données sensibles
  static String encryptSensitiveData(String data) {
    try {
      // Implémentation simple avec Base64 + clé
      // En production, utiliser AES ou autre algorithme robuste
      final bytes = utf8.encode(data + _privateKey);
      final digest = sha256.convert(bytes);
      return base64.encode(digest.bytes);
    } catch (e) {
      print('Erreur lors du chiffrement: $e');
      return data;
    }
  }

  /// Déchiffrer des données sensibles
  static String decryptSensitiveData(String encryptedData) {
    try {
      // Implémentation correspondante au chiffrement
      // En production, implémenter le déchiffrement AES
      return encryptedData; // Placeholder
    } catch (e) {
      print('Erreur lors du déchiffrement: $e');
      return encryptedData;
    }
  }

  /// Générer un token d'API pour un partenaire
  static Map<String, dynamic> generatePartnerToken({
    required String partnerId,
    required List<String> permissions,
    Duration validity = const Duration(days: 30),
  }) {
    try {
      final payload = {
        'partner_id': partnerId,
        'permissions': permissions,
        'issued_at': DateTime.now().millisecondsSinceEpoch,
        'expires_at': DateTime.now().add(validity).millisecondsSinceEpoch,
        'nonce': _generateNonce(),
      };

      final token = base64.encode(utf8.encode(json.encode(payload)));
      final signature = _signToken(token);

      return {
        'success': true,
        'token': token,
        'signature': signature,
        'expires_at': payload['expires_at'],
        'permissions': permissions,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur lors de la génération du token: $e',
      };
    }
  }

  /// Valider un token de partenaire
  static Map<String, dynamic> validatePartnerToken(String token, String signature) {
    try {
      // Vérifier la signature
      if (!_verifyTokenSignature(token, signature)) {
        return {
          'valid': false,
          'error': 'Signature invalide',
        };
      }

      // Décoder le payload
      final decodedBytes = base64.decode(token);
      final payload = json.decode(utf8.decode(decodedBytes));

      // Vérifier l'expiration
      final expiresAt = payload['expires_at'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        return {
          'valid': false,
          'error': 'Token expiré',
        };
      }

      return {
        'valid': true,
        'partner_id': payload['partner_id'],
        'permissions': payload['permissions'],
        'expires_at': expiresAt,
      };
    } catch (e) {
      return {
        'valid': false,
        'error': 'Token invalide: $e',
      };
    }
  }

  /// Obtenir les limites de taux pour un endpoint
  static Map<String, int> getRateLimits(String endpoint) {
    final Map<String, Map<String, int>> limits = {
      'auth/token': {'requests': 10, 'window': 60}, // 10 req/min
      'payments/create': {'requests': 100, 'window': 60}, // 100 req/min
      'transfers/international': {'requests': 50, 'window': 60}, // 50 req/min
      'users/profile': {'requests': 200, 'window': 60}, // 200 req/min
      'default': {'requests': 1000, 'window': 60}, // 1000 req/min par défaut
    };

    return limits[endpoint] ?? limits['default']!;
  }

  /// Nettoyer le cache
  static void clearCache() {
    _requestCache.clear();
    _accessToken = null;
    _tokenExpiry = null;
  }

  // Méthodes privées

  static String _generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  static String _generateSignature(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
    String timestamp,
    String nonce,
  ) {
    final bodyString = body != null ? json.encode(body) : '';
    final message = '$method|$endpoint|$bodyString|$timestamp|$nonce';
    final key = utf8.encode(_privateKey);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(digest.bytes);
  }

  static String _generateWebhookSignature(String payload, String timestamp) {
    final message = '$timestamp.$payload';
    final key = utf8.encode(_privateKey);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return 'sha256=${digest.toString()}';
  }

  static String _signToken(String token) {
    final key = utf8.encode(_privateKey);
    final bytes = utf8.encode(token);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(digest.bytes);
  }

  static bool _verifyTokenSignature(String token, String signature) {
    final expectedSignature = _signToken(token);
    return _secureCompare(signature, expectedSignature);
  }

  static bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  static String _generateCacheKey(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  ) {
    final components = [
      method,
      endpoint,
      body != null ? json.encode(body) : '',
      queryParams != null ? json.encode(queryParams) : '',
    ];
    final combined = components.join('|');
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'status_code': response.statusCode,
          'headers': response.headers,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erreur HTTP ${response.statusCode}',
          'status_code': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur lors du parsing de la réponse: $e',
        'status_code': response.statusCode,
        'raw_body': response.body,
      };
    }
  }
}

/// Configuration de l'API Gateway
class APIGatewayConfig {
  final String baseUrl;
  final String publicKey;
  final String privateKey;
  final Duration timeout;
  final int maxRetries;
  final bool enableCache;
  final Duration cacheTimeout;
  final Map<String, String> defaultHeaders;

  const APIGatewayConfig({
    required this.baseUrl,
    required this.publicKey,
    required this.privateKey,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.enableCache = true,
    this.cacheTimeout = const Duration(minutes: 5),
    this.defaultHeaders = const {},
  });

  factory APIGatewayConfig.fromJson(Map<String, dynamic> json) {
    return APIGatewayConfig(
      baseUrl: json['base_url'] ?? '',
      publicKey: json['public_key'] ?? '',
      privateKey: json['private_key'] ?? '',
      timeout: Duration(seconds: json['timeout'] ?? 30),
      maxRetries: json['max_retries'] ?? 3,
      enableCache: json['enable_cache'] ?? true,
      cacheTimeout: Duration(minutes: json['cache_timeout'] ?? 5),
      defaultHeaders: Map<String, String>.from(json['default_headers'] ?? {}),
    );
  }
}
