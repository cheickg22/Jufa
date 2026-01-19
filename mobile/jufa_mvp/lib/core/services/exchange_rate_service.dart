import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../features/international/domain/models/international_models.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const String _fallbackUrl = 'https://api.fixer.io/latest';
  static const String _cryptoUrl = 'https://api.coingecko.com/api/v3/simple/price';
  
  // Cache pour éviter trop d'appels API
  static final Map<String, ExchangeRate> _cache = {};
  static DateTime? _lastUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 15);

  /// Obtenir le taux de change entre deux devises
  static Future<ExchangeRate?> getExchangeRate(String fromCurrency, String toCurrency) async {
    try {
      final cacheKey = '${fromCurrency}_$toCurrency';
      
      // Vérifier le cache
      if (_cache.containsKey(cacheKey) && _isCacheValid()) {
        return _cache[cacheKey];
      }

      // Appel API principal
      ExchangeRate? rate = await _fetchFromPrimaryAPI(fromCurrency, toCurrency);
      
      // Fallback si l'API principale échoue
      rate ??= await _fetchFromFallbackAPI(fromCurrency, toCurrency);
      
      // Fallback local si toutes les APIs échouent
      rate ??= _getFallbackRate(fromCurrency, toCurrency);

      if (rate != null) {
        _cache[cacheKey] = rate;
        _lastUpdate = DateTime.now();
      }

      return rate;
    } catch (e) {
      print('Erreur lors de la récupération du taux de change: $e');
      return _getFallbackRate(fromCurrency, toCurrency);
    }
  }

  /// Obtenir plusieurs taux de change en une fois
  static Future<Map<String, ExchangeRate>> getMultipleRates(
    String baseCurrency,
    List<String> targetCurrencies,
  ) async {
    final Map<String, ExchangeRate> rates = {};
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$baseCurrency'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ratesData = data['rates'] as Map<String, dynamic>;
        
        for (final targetCurrency in targetCurrencies) {
          if (ratesData.containsKey(targetCurrency)) {
            final rate = (ratesData[targetCurrency] as num).toDouble();
            rates[targetCurrency] = ExchangeRate(
              id: '${baseCurrency}_$targetCurrency',
              fromCurrency: baseCurrency,
              toCurrency: targetCurrency,
              rate: rate,
              inverseRate: 1 / rate,
              margin: 0.02, // 2% de marge
              timestamp: DateTime.now(),
              validUntil: DateTime.now().add(_cacheTimeout),
              provider: 'ExchangeRate-API',
              metadata: {'source': 'primary'},
            );
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des taux multiples: $e');
    }

    // Compléter avec les taux de fallback si nécessaire
    for (final targetCurrency in targetCurrencies) {
      if (!rates.containsKey(targetCurrency)) {
        final fallbackRate = _getFallbackRate(baseCurrency, targetCurrency);
        if (fallbackRate != null) {
          rates[targetCurrency] = fallbackRate;
        }
      }
    }

    return rates;
  }

  /// Obtenir les taux de crypto-monnaies
  static Future<Map<String, double>> getCryptoRates(List<String> cryptos) async {
    try {
      final cryptoIds = cryptos.join(',');
      final response = await http.get(
        Uri.parse('$_cryptoUrl?ids=$cryptoIds&vs_currencies=usd,eur,xof'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, double> rates = {};
        
        data.forEach((crypto, prices) {
          final priceData = prices as Map<String, dynamic>;
          rates['${crypto}_usd'] = (priceData['usd'] ?? 0.0).toDouble();
          rates['${crypto}_eur'] = (priceData['eur'] ?? 0.0).toDouble();
          rates['${crypto}_xof'] = (priceData['xof'] ?? 0.0).toDouble();
        });
        
        return rates;
      }
    } catch (e) {
      print('Erreur lors de la récupération des taux crypto: $e');
    }
    
    return {};
  }

  /// Calculer les frais de transfert
  static double calculateTransferFee(
    double amount,
    String fromCurrency,
    String toCurrency,
    String corridor,
  ) {
    // Frais de base par corridor
    final Map<String, double> baseFees = {
      'ML-FR': 2500.0, // Mali vers France
      'ML-US': 3000.0, // Mali vers USA
      'ML-CA': 3500.0, // Mali vers Canada
      'FR-ML': 5.0,    // France vers Mali (EUR)
      'US-ML': 5.0,    // USA vers Mali (USD)
      'CA-ML': 7.0,    // Canada vers Mali (CAD)
    };

    // Pourcentage par montant
    final Map<String, double> percentageFees = {
      'ML-FR': 0.02, // 2%
      'ML-US': 0.025, // 2.5%
      'ML-CA': 0.03, // 3%
      'FR-ML': 0.015, // 1.5%
      'US-ML': 0.015, // 1.5%
      'CA-ML': 0.02, // 2%
    };

    final baseFee = baseFees[corridor] ?? 2500.0;
    final percentageFee = percentageFees[corridor] ?? 0.02;
    
    return baseFee + (amount * percentageFee);
  }

  /// Estimer le temps de transfert
  static int estimateTransferTime(String corridor, String method) {
    final Map<String, Map<String, int>> transferTimes = {
      'ML-FR': {
        'bank_transfer': 60,    // 1 heure
        'mobile_wallet': 15,   // 15 minutes
        'cash_pickup': 30,     // 30 minutes
      },
      'ML-US': {
        'bank_transfer': 120,   // 2 heures
        'mobile_wallet': 45,   // 45 minutes
        'cash_pickup': 60,     // 1 heure
      },
      'ML-CA': {
        'bank_transfer': 180,   // 3 heures
        'mobile_wallet': 60,   // 1 heure
        'cash_pickup': 90,     // 1h30
      },
    };

    return transferTimes[corridor]?[method] ?? 60;
  }

  // Méthodes privées

  static Future<ExchangeRate?> _fetchFromPrimaryAPI(String from, String to) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$from'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        if (rates.containsKey(to)) {
          final rate = (rates[to] as num).toDouble();
          return ExchangeRate(
            id: '${from}_$to',
            fromCurrency: from,
            toCurrency: to,
            rate: rate,
            inverseRate: 1 / rate,
            margin: 0.02,
            timestamp: DateTime.now(),
            validUntil: DateTime.now().add(_cacheTimeout),
            provider: 'ExchangeRate-API',
            metadata: {'source': 'primary'},
          );
        }
      }
    } catch (e) {
      print('Erreur API principale: $e');
    }
    return null;
  }

  static Future<ExchangeRate?> _fetchFromFallbackAPI(String from, String to) async {
    try {
      // Note: Fixer.io nécessite une clé API pour les requêtes HTTPS
      // Ici on simule une réponse de fallback
      await Future.delayed(const Duration(milliseconds: 500));
      
      final fallbackRate = _getFallbackRate(from, to);
      if (fallbackRate != null) {
        return fallbackRate.copyWith(
          provider: 'Fixer.io',
          metadata: {'source': 'fallback'},
        );
      }
    } catch (e) {
      print('Erreur API fallback: $e');
    }
    return null;
  }

  static ExchangeRate? _getFallbackRate(String from, String to) {
    // Taux de change statiques de fallback (mis à jour manuellement)
    final Map<String, double> fallbackRates = {
      'XOF_EUR': 0.00152, // 1 FCFA = 0.00152 EUR
      'XOF_USD': 0.00163, // 1 FCFA = 0.00163 USD
      'XOF_CAD': 0.00221, // 1 FCFA = 0.00221 CAD
      'EUR_XOF': 655.957, // 1 EUR = 655.957 FCFA
      'USD_XOF': 613.25,  // 1 USD = 613.25 FCFA
      'CAD_XOF': 452.49,  // 1 CAD = 452.49 FCFA
      'EUR_USD': 1.08,    // 1 EUR = 1.08 USD
      'USD_EUR': 0.93,    // 1 USD = 0.93 EUR
      'CAD_USD': 0.74,    // 1 CAD = 0.74 USD
      'USD_CAD': 1.35,    // 1 USD = 1.35 CAD
    };

    final key = '${from}_$to';
    final rate = fallbackRates[key];
    
    if (rate != null) {
      return ExchangeRate(
        id: key,
        fromCurrency: from,
        toCurrency: to,
        rate: rate,
        inverseRate: 1 / rate,
        margin: 0.03, // 3% de marge pour les taux de fallback
        timestamp: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(hours: 1)),
        provider: 'Jufa-Fallback',
        metadata: {'source': 'static', 'warning': 'Taux de fallback utilisé'},
      );
    }

    return null;
  }

  static bool _isCacheValid() {
    if (_lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!).compareTo(_cacheTimeout) < 0;
  }

  /// Nettoyer le cache
  static void clearCache() {
    _cache.clear();
    _lastUpdate = null;
  }

  /// Obtenir les devises supportées
  static List<String> getSupportedCurrencies() {
    return ['XOF', 'EUR', 'USD', 'CAD', 'GBP', 'CHF', 'JPY', 'CNY'];
  }

  /// Obtenir les corridors populaires
  static List<String> getPopularCorridors() {
    return ['ML-FR', 'ML-US', 'ML-CA', 'FR-ML', 'US-ML', 'CA-ML'];
  }
}

// Extension pour ExchangeRate
extension ExchangeRateExtension on ExchangeRate {
  ExchangeRate copyWith({
    String? id,
    String? fromCurrency,
    String? toCurrency,
    double? rate,
    double? inverseRate,
    double? margin,
    DateTime? timestamp,
    DateTime? validUntil,
    String? provider,
    Map<String, dynamic>? metadata,
  }) {
    return ExchangeRate(
      id: id ?? this.id,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      inverseRate: inverseRate ?? this.inverseRate,
      margin: margin ?? this.margin,
      timestamp: timestamp ?? this.timestamp,
      validUntil: validUntil ?? this.validUntil,
      provider: provider ?? this.provider,
      metadata: metadata ?? this.metadata,
    );
  }
}
