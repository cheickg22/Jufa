# Guide d'Intégration API

Ce document décrit comment intégrer les différentes APIs utilisées dans JUFA.

## 📡 APIs Principales

### 1. API Skaleet (Infrastructure Bancaire)

**Base URL**: `https://api.skaleet.com/v1`

#### Configuration

```dart
// lib/core/config/app_config.dart
static const String skaleetApiUrl = 'https://api.skaleet.com/v1';
static const String skaleetApiKey = String.fromEnvironment('SKALEET_API_KEY');
```

#### Endpoints Principaux

##### Créer un compte
```http
POST /accounts
Content-Type: application/json
Authorization: Bearer {API_KEY}

{
  "customer_id": "string",
  "account_type": "individual",
  "currency": "XOF"
}
```

##### Effectuer un transfert
```http
POST /transfers
Content-Type: application/json
Authorization: Bearer {API_KEY}

{
  "from_account": "string",
  "to_account": "string",
  "amount": 10000,
  "currency": "XOF",
  "description": "string"
}
```

##### Consulter le solde
```http
GET /accounts/{account_id}/balance
Authorization: Bearer {API_KEY}
```

#### Implémentation Flutter

```dart
class SkaleetService {
  final ApiClient apiClient;
  
  Future<Account> createAccount(String customerId) async {
    final response = await apiClient.post(
      '/accounts',
      data: {
        'customer_id': customerId,
        'account_type': 'individual',
        'currency': 'XOF',
      },
    );
    return Account.fromJson(response.data);
  }
  
  Future<Transfer> sendTransfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
  }) async {
    final response = await apiClient.post(
      '/transfers',
      data: {
        'from_account': fromAccount,
        'to_account': toAccount,
        'amount': amount,
        'currency': 'XOF',
      },
    );
    return Transfer.fromJson(response.data);
  }
}
```

---

### 2. API DT One (Airtime & Top-Up)

**Base URL**: `https://api.dtone.com/v1`

#### Configuration

```dart
static const String dtOneApiUrl = 'https://api.dtone.com/v1';
static const String dtOneApiKey = String.fromEnvironment('DTONE_API_KEY');
```

#### Endpoints Principaux

##### Liste des opérateurs
```http
GET /operators?country=ML
Authorization: Bearer {API_KEY}
```

##### Acheter du crédit
```http
POST /transactions
Content-Type: application/json
Authorization: Bearer {API_KEY}

{
  "operator_id": "1234",
  "phone_number": "+22376123456",
  "amount": 5000,
  "product_type": "MOBILE_AIRTIME"
}
```

#### Implémentation Flutter

```dart
class DtOneService {
  final ApiClient apiClient;
  
  Future<List<Operator>> getOperators() async {
    final response = await apiClient.get(
      '/operators',
      queryParameters: {'country': 'ML'},
    );
    return (response.data as List)
        .map((e) => Operator.fromJson(e))
        .toList();
  }
  
  Future<Transaction> purchaseAirtime({
    required String operatorId,
    required String phoneNumber,
    required double amount,
  }) async {
    final response = await apiClient.post(
      '/transactions',
      data: {
        'operator_id': operatorId,
        'phone_number': phoneNumber,
        'amount': amount,
        'product_type': 'MOBILE_AIRTIME',
      },
    );
    return Transaction.fromJson(response.data);
  }
}
```

---

### 3. API BCEAO (Interopérabilité UEMOA)

**Base URL**: `https://api.bceao.int/interop/v1`

#### Endpoints Principaux

##### Vérifier un compte IBAN
```http
GET /accounts/verify?iban={IBAN}
Authorization: Bearer {API_KEY}
```

##### Transfert interopérable
```http
POST /transfers/interop
Content-Type: application/json
Authorization: Bearer {API_KEY}

{
  "sender_iban": "string",
  "receiver_iban": "string",
  "amount": 50000,
  "currency": "XOF",
  "description": "string"
}
```

---

### 4. API Nege (Or/Argent)

**Base URL**: `https://api.raffinerie-km.com/nege/v1`

#### Endpoints Principaux

##### Prix actuels de l'or/argent
```http
GET /prices
```

Response:
```json
{
  "gold": {
    "price_per_gram": 38500,
    "currency": "XOF"
  },
  "silver": {
    "price_per_gram": 520,
    "currency": "XOF"
  }
}
```

##### Acheter de l'or
```http
POST /transactions/buy
Content-Type: application/json
Authorization: Bearer {API_KEY}

{
  "user_id": "string",
  "metal_type": "gold",
  "grams": 2.5,
  "payment_method": "wallet"
}
```

---

## 🔐 Sécurité

### Gestion des API Keys

**Ne jamais** hardcoder les clés API. Utiliser des variables d'environnement:

```bash
# .env
SKALEET_API_KEY=your_key_here
DTONE_API_KEY=your_key_here
BCEAO_API_KEY=your_key_here
NEGE_API_KEY=your_key_here
```

### SSL Pinning

Implémenter le SSL pinning pour sécuriser les communications:

```dart
class SslPinningService {
  static Future<SecurityContext> getSecurityContext() async {
    final context = SecurityContext(withTrustedRoots: false);
    
    // Ajouter les certificats
    final certBytes = await rootBundle.load('assets/certs/cert.pem');
    context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
    
    return context;
  }
}
```

---

## 🧪 Tests

### Mock des APIs pour les tests

```dart
class MockSkaleetService extends Mock implements SkaleetService {}

void main() {
  group('Skaleet Service Tests', () {
    late MockSkaleetService mockService;
    
    setUp(() {
      mockService = MockSkaleetService();
    });
    
    test('should create account successfully', () async {
      // Arrange
      when(mockService.createAccount(any))
          .thenAnswer((_) async => Account(id: '123'));
      
      // Act
      final result = await mockService.createAccount('user123');
      
      // Assert
      expect(result.id, '123');
    });
  });
}
```

---

## 📊 Gestion des Erreurs

Toutes les APIs doivent gérer les erreurs de manière cohérente:

```dart
try {
  final result = await skaleetService.sendTransfer(...);
  return Right(result);
} on ServerException catch (e) {
  return Left(ServerFailure(message: e.message));
} on NetworkException catch (e) {
  return Left(NetworkFailure(message: e.message));
} catch (e) {
  return Left(UnknownFailure(message: e.toString()));
}
```

---

## 🔄 Rate Limiting

Respecter les limites de taux de chaque API:

- **Skaleet**: 100 requêtes/minute
- **DT One**: 60 requêtes/minute
- **BCEAO**: 50 requêtes/minute

Implémenter un système de retry avec exponential backoff.

---

## 📝 Logging

Logger toutes les requêtes API en développement:

```dart
dio.interceptors.add(
  PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    error: true,
  ),
);
```

En production, logger seulement les erreurs.
