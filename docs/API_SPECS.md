# Spécifications API - JUFA Backend

## Base URL

| Environnement | URL |
|---------------|-----|
| Development | `http://localhost:8080/api/v1` |
| Staging | `https://staging-api.jufa.ml/api/v1` |
| Production | `https://api.jufa.ml/api/v1` |

## Authentification

Toutes les requêtes (sauf inscription/connexion) nécessitent un header `Authorization`:

```
Authorization: Bearer <access_token>
```

---

## 1. Auth Service

### 1.1 Inscription

```http
POST /auth/register
```

**Request Body:**
```json
{
  "phone": "+22370000000",
  "password": "SecureP@ss123",
  "userType": "INDIVIDUAL"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "phone": "+22370000000",
    "message": "OTP envoyé par SMS"
  }
}
```

### 1.2 Vérification OTP

```http
POST /auth/verify-otp
```

**Request Body:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "otp": "123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "expiresIn": 3600,
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "phone": "+22370000000",
      "userType": "INDIVIDUAL",
      "status": "ACTIVE",
      "kycLevel": "LEVEL_0"
    }
  }
}
```

### 1.3 Connexion

```http
POST /auth/login
```

**Request Body:**
```json
{
  "phone": "+22370000000",
  "password": "SecureP@ss123"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "expiresIn": 3600,
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "phone": "+22370000000",
      "userType": "INDIVIDUAL",
      "status": "ACTIVE",
      "kycLevel": "LEVEL_2"
    }
  }
}
```

### 1.4 Refresh Token

```http
POST /auth/refresh-token
```

**Request Body:**
```json
{
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

### 1.5 Vérification PIN

```http
POST /auth/verify-pin
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "pin": "1234"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "tempToken": "temp_token_valid_5min",
    "expiresIn": 300
  }
}
```

### 1.6 Déconnexion

```http
POST /auth/logout
```

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "message": "Déconnexion réussie"
}
```

### 1.7 Réinitialisation mot de passe

```http
POST /auth/reset-password/request
```

**Request Body:**
```json
{
  "phone": "+22370000000"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "OTP envoyé par SMS"
}
```

```http
POST /auth/reset-password/confirm
```

**Request Body:**
```json
{
  "phone": "+22370000000",
  "otp": "123456",
  "newPassword": "NewSecureP@ss456"
}
```

---

## 2. User Service

### 2.1 Profil utilisateur

```http
GET /users/me
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "phone": "+22370000000",
    "email": "user@example.com",
    "userType": "MERCHANT",
    "status": "ACTIVE",
    "kycLevel": "LEVEL_2",
    "profile": {
      "firstName": "Amadou",
      "lastName": "Diallo",
      "businessName": "Diallo Commerce",
      "address": "Hamdallaye ACI 2000",
      "city": "Bamako",
      "profilePhotoUrl": "https://storage.jufa.ml/profiles/user123.jpg"
    },
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### 2.2 Mise à jour profil

```http
PUT /users/me/profile
```

**Request Body:**
```json
{
  "firstName": "Amadou",
  "lastName": "Diallo",
  "businessName": "Diallo Commerce SARL",
  "address": "Hamdallaye ACI 2000, Rue 305",
  "city": "Bamako"
}
```

### 2.3 Changement PIN

```http
PUT /users/me/pin
```

**Request Body:**
```json
{
  "currentPin": "1234",
  "newPin": "5678",
  "otp": "123456"
}
```

---

## 3. KYC Service

### 3.1 Soumettre un document

```http
POST /kyc/documents
Content-Type: multipart/form-data
```

**Form Data:**
- `documentType`: `CNI` | `PASSPORT` | `RCCM` | `NIF`
- `documentNumber`: `ML123456789`
- `expiryDate`: `2028-12-31` (optional)
- `file`: (binary)

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "doc-uuid",
    "documentType": "CNI",
    "status": "PENDING",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### 3.2 Statut KYC

```http
GET /kyc/status
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "currentLevel": "LEVEL_1",
    "nextLevel": "LEVEL_2",
    "documents": [
      {
        "id": "doc-uuid-1",
        "type": "CNI",
        "status": "APPROVED",
        "submittedAt": "2024-01-10T10:00:00Z",
        "verifiedAt": "2024-01-11T14:30:00Z"
      }
    ],
    "requirements": {
      "LEVEL_2": ["RCCM", "NIF"],
      "LEVEL_3": ["BANK_STATEMENT", "PROOF_OF_ADDRESS"]
    }
  }
}
```

---

## 4. Wallet Service

### 4.1 Liste des wallets

```http
GET /wallets
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "wallet-uuid-1",
      "type": "B2C",
      "currency": "XOF",
      "balance": 150000.00,
      "availableBalance": 145000.00,
      "status": "ACTIVE"
    },
    {
      "id": "wallet-uuid-2",
      "type": "B2B",
      "currency": "XOF",
      "balance": 2500000.00,
      "availableBalance": 2500000.00,
      "status": "ACTIVE"
    }
  ]
}
```

### 4.2 Détail d'un wallet

```http
GET /wallets/{walletId}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "wallet-uuid-1",
    "type": "B2C",
    "currency": "XOF",
    "balance": 150000.00,
    "availableBalance": 145000.00,
    "status": "ACTIVE",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-20T15:45:00Z"
  }
}
```

### 4.3 Historique des transactions d'un wallet

```http
GET /wallets/{walletId}/transactions?page=1&size=20&from=2024-01-01&to=2024-01-31
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "txn-uuid-1",
        "type": "CREDIT",
        "amount": 50000.00,
        "balanceBefore": 100000.00,
        "balanceAfter": 150000.00,
        "description": "Reçu de +22376543210",
        "transactionRef": "TXN-2024-00001",
        "createdAt": "2024-01-20T10:30:00Z"
      }
    ],
    "page": 1,
    "size": 20,
    "totalElements": 45,
    "totalPages": 3
  }
}
```

---

## 5. Transaction Service

### 5.1 Transfert P2P

```http
POST /transactions/transfer
```

**Headers:** 
- `Authorization: Bearer <token>`
- `X-Pin-Token: <temp_token>` (obtenu via /auth/verify-pin)

**Request Body:**
```json
{
  "receiverPhone": "+22376543210",
  "amount": 25000.00,
  "description": "Paiement facture"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "txn-uuid",
    "reference": "TXN-2024-00123",
    "type": "TRANSFER",
    "status": "COMPLETED",
    "amount": 25000.00,
    "fee": 250.00,
    "currency": "XOF",
    "sender": {
      "phone": "+22370000000",
      "name": "Amadou D."
    },
    "receiver": {
      "phone": "+22376543210",
      "name": "Fatou T."
    },
    "createdAt": "2024-01-20T10:30:00Z",
    "completedAt": "2024-01-20T10:30:01Z"
  }
}
```

### 5.2 Paiement marchand

```http
POST /transactions/payment
```

**Request Body:**
```json
{
  "merchantId": "merchant-uuid",
  "amount": 75000.00,
  "reference": "ORDER-2024-001"
}
```

### 5.3 Dépôt Mobile Money

```http
POST /transactions/momo/deposit
```

**Request Body:**
```json
{
  "provider": "ORANGE_MONEY",
  "amount": 100000.00,
  "phone": "+22370000000"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "txn-uuid",
    "reference": "TXN-2024-00124",
    "status": "PENDING",
    "amount": 100000.00,
    "provider": "ORANGE_MONEY",
    "instructions": "Composez *144# et suivez les instructions",
    "expiresAt": "2024-01-20T10:45:00Z"
  }
}
```

### 5.4 Retrait Mobile Money

```http
POST /transactions/momo/withdraw
```

**Request Body:**
```json
{
  "provider": "ORANGE_MONEY",
  "amount": 50000.00,
  "phone": "+22370000000"
}
```

### 5.5 Virement bancaire

```http
POST /transactions/bank-transfer
```

**Headers:** 
- `Authorization: Bearer <token>`
- `X-Pin-Token: <temp_token>`
- `X-OTP: 123456` (requis pour montants > 500K)

**Request Body:**
```json
{
  "bankCode": "ECOBANK",
  "accountNumber": "00123456789",
  "accountName": "Amadou Diallo",
  "amount": 500000.00,
  "description": "Virement salaire"
}
```

### 5.6 Détail d'une transaction

```http
GET /transactions/{transactionId}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "txn-uuid",
    "reference": "TXN-2024-00123",
    "type": "TRANSFER",
    "status": "COMPLETED",
    "amount": 25000.00,
    "fee": 250.00,
    "currency": "XOF",
    "description": "Paiement facture",
    "sender": {
      "walletId": "wallet-uuid-1",
      "phone": "+22370000000",
      "name": "Amadou D."
    },
    "receiver": {
      "walletId": "wallet-uuid-2",
      "phone": "+22376543210",
      "name": "Fatou T."
    },
    "metadata": {},
    "createdAt": "2024-01-20T10:30:00Z",
    "completedAt": "2024-01-20T10:30:01Z"
  }
}
```

### 5.7 Historique des transactions

```http
GET /transactions?page=1&size=20&type=TRANSFER&status=COMPLETED
```

---

## 6. Agent Service

### 6.1 Cash-In (Dépôt client)

```http
POST /agents/cash-in
```

**Request Body:**
```json
{
  "customerPhone": "+22376543210",
  "amount": 50000.00
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "transactionId": "txn-uuid",
    "reference": "CASHIN-2024-00001",
    "amount": 50000.00,
    "commission": 500.00,
    "customerPhone": "+22376543210",
    "status": "COMPLETED"
  }
}
```

### 6.2 Cash-Out (Retrait client)

```http
POST /agents/cash-out
```

**Request Body:**
```json
{
  "customerPhone": "+22376543210",
  "amount": 30000.00,
  "customerPin": "1234"
}
```

### 6.3 Solde et limites agent

```http
GET /agents/me/balance
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "float": 500000.00,
    "commissions": 15000.00,
    "dailyLimit": 5000000.00,
    "dailyUsed": 1250000.00,
    "dailyRemaining": 3750000.00
  }
}
```

### 6.4 Historique des opérations agent

```http
GET /agents/me/transactions?page=1&size=20
```

---

## 7. Marketplace Service

### 7.1 Liste des produits

```http
GET /products?category=electronics&page=1&size=20
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "product-uuid",
        "name": "Téléphone Samsung A54",
        "description": "Smartphone 128GB",
        "category": "electronics",
        "price": 250000.00,
        "unit": "pièce",
        "stockQuantity": 50,
        "imageUrl": "https://storage.jufa.ml/products/samsung-a54.jpg",
        "merchant": {
          "id": "merchant-uuid",
          "name": "Tech Store Mali",
          "rating": 4.5
        }
      }
    ],
    "page": 1,
    "size": 20,
    "totalElements": 150
  }
}
```

### 7.2 Créer une commande

```http
POST /orders
```

**Request Body:**
```json
{
  "items": [
    {
      "productId": "product-uuid",
      "quantity": 2
    }
  ],
  "deliveryAddress": "Hamdallaye ACI 2000, Bamako"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "orderNumber": "ORD-2024-00001",
    "status": "PENDING_PAYMENT",
    "items": [...],
    "totalAmount": 500000.00,
    "paymentDeadline": "2024-01-20T12:30:00Z"
  }
}
```

### 7.3 Payer une commande

```http
POST /orders/{orderId}/pay
```

---

## 8. Notifications

### 8.1 Liste des notifications

```http
GET /notifications?page=1&size=20&unreadOnly=true
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "notif-uuid",
        "type": "TRANSACTION",
        "title": "Paiement reçu",
        "body": "Vous avez reçu 25,000 XOF de Amadou D.",
        "data": {
          "transactionId": "txn-uuid"
        },
        "read": false,
        "createdAt": "2024-01-20T10:30:00Z"
      }
    ],
    "unreadCount": 5
  }
}
```

### 8.2 Marquer comme lu

```http
PUT /notifications/{notificationId}/read
```

### 8.3 Marquer toutes comme lues

```http
PUT /notifications/read-all
```

---

## Codes d'erreur

| Code | Description |
|------|-------------|
| `JUFA-AUTH-001` | Identifiants invalides |
| `JUFA-AUTH-002` | OTP expiré ou invalide |
| `JUFA-AUTH-003` | Token expiré |
| `JUFA-AUTH-004` | PIN invalide |
| `JUFA-AUTH-005` | Compte bloqué |
| `JUFA-WALLET-001` | Solde insuffisant |
| `JUFA-WALLET-002` | Wallet non trouvé |
| `JUFA-WALLET-003` | Wallet inactif |
| `JUFA-TXN-001` | Transaction échouée |
| `JUFA-TXN-002` | Limite dépassée |
| `JUFA-TXN-003` | Bénéficiaire non trouvé |
| `JUFA-KYC-001` | Document rejeté |
| `JUFA-KYC-002` | KYC insuffisant pour cette opération |
| `JUFA-AGENT-001` | Limite journalière atteinte |
| `JUFA-AGENT-002` | Float insuffisant |

## Format des erreurs

```json
{
  "success": false,
  "error": {
    "code": "JUFA-WALLET-001",
    "message": "Solde insuffisant",
    "details": {
      "required": 50000,
      "available": 25000
    }
  },
  "timestamp": "2024-01-20T10:30:00Z",
  "path": "/api/v1/transactions/transfer"
}
```
