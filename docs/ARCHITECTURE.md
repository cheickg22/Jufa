# Architecture Technique JUFA

## 1. Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENTS                                         │
├─────────────────────┬─────────────────────┬─────────────────────────────────┤
│   App Mobile JUFA   │   Back-office Web   │      APIs Partenaires           │
│     (Flutter)       │   (React/Vue.js)    │    (Banques, Mobile Money)      │
└──────────┬──────────┴──────────┬──────────┴──────────────┬──────────────────┘
           │                     │                         │
           └─────────────────────┼─────────────────────────┘
                                 │
                         ┌───────▼───────┐
                         │  API Gateway  │
                         │   (Kong/AWS)  │
                         └───────┬───────┘
                                 │
           ┌─────────────────────┼─────────────────────┐
           │                     │                     │
    ┌──────▼──────┐      ┌──────▼──────┐      ┌──────▼──────┐
    │  Auth       │      │  Core       │      │  Notif      │
    │  Service    │      │  Service    │      │  Service    │
    └──────┬──────┘      └──────┬──────┘      └──────┬──────┘
           │                     │                     │
           └─────────────────────┼─────────────────────┘
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
             ┌──────▼──────┐ ┌──▼──┐ ┌───────▼───────┐
             │ PostgreSQL  │ │Redis│ │ Message Queue │
             │  (Primary)  │ │Cache│ │   (RabbitMQ)  │
             └─────────────┘ └─────┘ └───────────────┘
```

---

## 2. Architecture Backend (Microservices)

### 2.1 Stack Technique
- **Framework**: Spring Boot 3.x (Java 21)
- **API Style**: REST + OpenAPI 3.0
- **Base de données**: PostgreSQL 16
- **Cache**: Redis 7.x
- **Message Broker**: RabbitMQ
- **API Gateway**: Kong / Spring Cloud Gateway
- **Conteneurisation**: Docker + Kubernetes

### 2.2 Microservices

```
jufa-backend/
├── api-gateway/                 # Point d'entrée unique
├── auth-service/                # Authentification & autorisation
├── user-service/                # Gestion des utilisateurs
├── kyc-service/                 # Vérification KYC/KYB
├── wallet-service/              # Gestion des wallets
├── transaction-service/         # Paiements & transferts
├── bank-integration-service/    # Intégration bancaire (Ecobank)
├── mobile-money-service/        # Intégration Orange Money, Moov, etc.
├── marketplace-service/         # Marketplace B2B
├── agent-service/               # Réseau d'agents
├── notification-service/        # Push, SMS, Email
├── admin-service/               # Back-office
├── reporting-service/           # Rapports & statistiques
└── common-libs/                 # Librairies partagées
```

### 2.3 Détail des Services

#### AUTH-SERVICE
```yaml
Responsabilités:
  - Inscription / Connexion
  - Gestion des tokens JWT
  - OTP (SMS/Email)
  - PIN / Biométrie
  - Sessions et refresh tokens
  - Audit des connexions

Endpoints:
  POST   /auth/register
  POST   /auth/login
  POST   /auth/verify-otp
  POST   /auth/refresh-token
  POST   /auth/logout
  POST   /auth/reset-password
  POST   /auth/verify-pin

Dépendances:
  - user-service
  - notification-service
  - Redis (sessions)
```

#### USER-SERVICE
```yaml
Responsabilités:
  - Profils utilisateurs
  - Rôles et permissions
  - Gestion des commerçants/particuliers

Endpoints:
  GET    /users/{id}
  PUT    /users/{id}
  GET    /users/{id}/profile
  PUT    /users/{id}/profile
  GET    /users/roles

Modèles:
  - User
  - Profile (Merchant/Individual)
  - Role
  - Permission
```

#### KYC-SERVICE
```yaml
Responsabilités:
  - Collecte documents (CNI, RCCM, NIF)
  - Validation KYC/KYB
  - Statuts de vérification
  - Historique des validations

Endpoints:
  POST   /kyc/submit
  GET    /kyc/{userId}/status
  PUT    /kyc/{id}/validate
  PUT    /kyc/{id}/reject
  GET    /kyc/{userId}/history
  POST   /kyc/documents/upload

Statuts:
  - PENDING
  - UNDER_REVIEW
  - APPROVED
  - REJECTED
  - EXPIRED
```

#### WALLET-SERVICE
```yaml
Responsabilités:
  - Création de wallets
  - Consultation solde
  - Historique transactions
  - Multi-wallets (B2B/B2C)
  - Cantonnement des fonds

Endpoints:
  POST   /wallets
  GET    /wallets/{id}
  GET    /wallets/{id}/balance
  GET    /wallets/{id}/transactions
  GET    /wallets/user/{userId}

Modèles:
  - Wallet
  - WalletType (B2B, B2C, AGENT)
  - Balance
  - WalletTransaction
```

#### TRANSACTION-SERVICE
```yaml
Responsabilités:
  - Transferts wallet ↔ wallet
  - Virements wallet ↔ banque
  - Paiements marchands
  - Gestion des commissions
  - Réconciliation

Endpoints:
  POST   /transactions/transfer
  POST   /transactions/payment
  POST   /transactions/withdraw
  POST   /transactions/deposit
  GET    /transactions/{id}
  GET    /transactions/{id}/status

Types:
  - TRANSFER (P2P)
  - PAYMENT (Marchand)
  - DEPOSIT (Cash-in)
  - WITHDRAWAL (Cash-out)
  - BANK_TRANSFER
```

#### BANK-INTEGRATION-SERVICE
```yaml
Responsabilités:
  - Connexion APIs Ecobank
  - Virements bancaires
  - Collections
  - Réconciliation automatique
  - Gestion des erreurs

Endpoints (internes):
  POST   /bank/transfer
  POST   /bank/collect
  GET    /bank/status/{reference}
  POST   /bank/reconcile

Configuration:
  - Mode: SANDBOX / PRODUCTION
  - Retry policy
  - Circuit breaker
```

#### MOBILE-MONEY-SERVICE
```yaml
Responsabilités:
  - Intégration Orange Money
  - Intégration Moov Money
  - Cash-in / Cash-out
  - Webhooks opérateurs

Endpoints (internes):
  POST   /momo/deposit
  POST   /momo/withdraw
  GET    /momo/status/{reference}
  POST   /momo/webhook/{provider}
```

#### MARKETPLACE-SERVICE
```yaml
Responsabilités:
  - Catalogue produits
  - Gestion commandes
  - Facturation
  - Profils grossistes/boutiquiers

Endpoints:
  GET    /products
  POST   /products
  POST   /orders
  GET    /orders/{id}
  PUT    /orders/{id}/status
  GET    /invoices/{orderId}
```

#### AGENT-SERVICE
```yaml
Responsabilités:
  - Enrôlement agents
  - Opérations cash-in/cash-out
  - Gestion plafonds
  - Commissions
  - Performance

Endpoints:
  POST   /agents/register
  GET    /agents/{id}
  POST   /agents/{id}/cash-in
  POST   /agents/{id}/cash-out
  GET    /agents/{id}/commissions
  GET    /agents/{id}/performance
```

#### NOTIFICATION-SERVICE
```yaml
Responsabilités:
  - Push notifications (FCM)
  - SMS (Orange, Moov)
  - Emails (SendGrid/AWS SES)
  - Templates
  - Historique

Endpoints (internes):
  POST   /notifications/push
  POST   /notifications/sms
  POST   /notifications/email
  GET    /notifications/user/{userId}

Providers:
  - Firebase Cloud Messaging (Push)
  - Orange SMS Gateway
  - SendGrid / AWS SES (Email)
```

---

## 3. Architecture Frontend Mobile (Flutter)

### 3.1 Stack Technique
- **Framework**: Flutter 3.x
- **State Management**: Riverpod / Bloc
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Storage**: Hive / SharedPreferences
- **Sécurité**: flutter_secure_storage

### 3.2 Structure du Projet

```
jufa_mobile/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── interceptors/
│   │   ├── storage/
│   │   └── utils/
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── datasources/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       ├── widgets/
│   │   │       └── providers/
│   │   │
│   │   ├── wallet/
│   │   ├── transactions/
│   │   ├── kyc/
│   │   ├── marketplace/
│   │   ├── agents/
│   │   ├── notifications/
│   │   └── profile/
│   │
│   └── shared/
│       ├── widgets/
│       ├── providers/
│       └── extensions/
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
└── test/
```

### 3.3 Architecture Clean (par feature)

```
feature/
├── data/                    # Couche données
│   ├── models/              # DTOs (JSON serialization)
│   ├── datasources/         # API calls, local storage
│   └── repositories/        # Implémentation repositories
│
├── domain/                  # Couche métier
│   ├── entities/            # Objets métier purs
│   ├── repositories/        # Interfaces repositories
│   └── usecases/            # Cas d'utilisation
│
└── presentation/            # Couche UI
    ├── screens/             # Pages
    ├── widgets/             # Composants
    └── providers/           # State management
```

---

## 4. Architecture Base de Données

### 4.1 Schéma Principal (PostgreSQL)

```sql
-- =============================================
-- SCHEMA: users
-- =============================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    pin_hash VARCHAR(255),
    user_type VARCHAR(20) NOT NULL, -- INDIVIDUAL, MERCHANT, AGENT, ADMIN
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    business_name VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    profile_photo_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id),
    role_id UUID REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    resource VARCHAR(100),
    action VARCHAR(50)
);

-- =============================================
-- SCHEMA: kyc
-- =============================================

CREATE TABLE kyc_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    document_type VARCHAR(50) NOT NULL, -- CNI, PASSPORT, RCCM, NIF
    document_number VARCHAR(100),
    document_url TEXT NOT NULL,
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'PENDING',
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE kyc_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    level VARCHAR(20) NOT NULL, -- LEVEL_1, LEVEL_2, LEVEL_3
    status VARCHAR(20) DEFAULT 'PENDING',
    reviewer_id UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- SCHEMA: wallets
-- =============================================

CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    wallet_type VARCHAR(20) NOT NULL, -- B2B, B2C, AGENT, COMMISSION
    currency VARCHAR(3) DEFAULT 'XOF',
    balance DECIMAL(18, 2) DEFAULT 0.00,
    available_balance DECIMAL(18, 2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID REFERENCES wallets(id),
    transaction_id UUID,
    type VARCHAR(20) NOT NULL, -- CREDIT, DEBIT
    amount DECIMAL(18, 2) NOT NULL,
    balance_before DECIMAL(18, 2),
    balance_after DECIMAL(18, 2),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- SCHEMA: transactions
-- =============================================

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(30) NOT NULL, -- TRANSFER, PAYMENT, DEPOSIT, WITHDRAWAL, BANK_TRANSFER
    status VARCHAR(20) DEFAULT 'PENDING',
    sender_wallet_id UUID REFERENCES wallets(id),
    receiver_wallet_id UUID REFERENCES wallets(id),
    amount DECIMAL(18, 2) NOT NULL,
    fee DECIMAL(18, 2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'XOF',
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE TABLE transaction_fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID REFERENCES transactions(id),
    fee_type VARCHAR(30), -- PLATFORM, AGENT, BANK
    amount DECIMAL(18, 2),
    beneficiary_wallet_id UUID REFERENCES wallets(id)
);

-- =============================================
-- SCHEMA: agents
-- =============================================

CREATE TABLE agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    agent_code VARCHAR(20) UNIQUE NOT NULL,
    commission_rate DECIMAL(5, 2) DEFAULT 0.00,
    daily_limit DECIMAL(18, 2),
    monthly_limit DECIMAL(18, 2),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE agent_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES agents(id),
    transaction_id UUID REFERENCES transactions(id),
    operation_type VARCHAR(20), -- CASH_IN, CASH_OUT
    commission_earned DECIMAL(18, 2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- SCHEMA: marketplace
-- =============================================

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    price DECIMAL(18, 2) NOT NULL,
    unit VARCHAR(50),
    stock_quantity INT DEFAULT 0,
    image_url TEXT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    buyer_id UUID REFERENCES users(id),
    seller_id UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'PENDING',
    total_amount DECIMAL(18, 2),
    transaction_id UUID REFERENCES transactions(id),
    delivery_address TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id),
    product_id UUID REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price DECIMAL(18, 2) NOT NULL,
    total_price DECIMAL(18, 2) NOT NULL
);

-- =============================================
-- SCHEMA: notifications
-- =============================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    type VARCHAR(30) NOT NULL, -- PUSH, SMS, EMAIL
    title VARCHAR(255),
    body TEXT,
    data JSONB,
    status VARCHAR(20) DEFAULT 'PENDING',
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- SCHEMA: audit
-- =============================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource VARCHAR(100),
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- INDEX
-- =============================================

CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_transactions_reference ON transactions(reference);
CREATE INDEX idx_transactions_sender ON transactions(sender_wallet_id);
CREATE INDEX idx_transactions_receiver ON transactions(receiver_wallet_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

---

## 5. Architecture Sécurité

### 5.1 Authentification & Autorisation

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUX D'AUTHENTIFICATION                   │
└─────────────────────────────────────────────────────────────┘

1. INSCRIPTION
   Client → POST /auth/register (phone, password)
         → Création compte (status: PENDING)
         → Envoi OTP SMS
         → POST /auth/verify-otp (otp)
         → Compte activé
         → Création wallet automatique

2. CONNEXION
   Client → POST /auth/login (phone, password)
         → Validation credentials
         → Génération JWT (access + refresh)
         → Retour tokens

3. REFRESH TOKEN
   Client → POST /auth/refresh-token (refresh_token)
         → Validation refresh token
         → Nouveau access token

4. VERIFICATION PIN (transactions sensibles)
   Client → POST /auth/verify-pin (pin)
         → Validation PIN
         → Token temporaire (5 min)
```

### 5.2 Structure JWT

```json
{
  "header": {
    "alg": "RS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user-uuid",
    "iat": 1234567890,
    "exp": 1234571490,
    "type": "access",
    "roles": ["MERCHANT"],
    "permissions": ["wallet:read", "transaction:create"],
    "kyc_level": "LEVEL_2"
  }
}
```

### 5.3 Niveaux de Sécurité par Action

| Action | Authentification | PIN | OTP | KYC Min |
|--------|-----------------|-----|-----|---------|
| Consulter solde | JWT | - | - | LEVEL_1 |
| Transfert < 50K | JWT | PIN | - | LEVEL_1 |
| Transfert 50K-500K | JWT | PIN | - | LEVEL_2 |
| Transfert > 500K | JWT | PIN | OTP | LEVEL_3 |
| Virement bancaire | JWT | PIN | OTP | LEVEL_3 |
| Modification profil | JWT | - | - | LEVEL_1 |
| Changement PIN | JWT | PIN | OTP | LEVEL_1 |

### 5.4 Chiffrement

```yaml
En transit:
  - TLS 1.3 obligatoire
  - Certificate pinning (mobile)

Au repos:
  - AES-256-GCM pour données sensibles
  - Bcrypt pour mots de passe (cost: 12)
  - PBKDF2 pour PIN

Clés:
  - AWS KMS / HashiCorp Vault
  - Rotation automatique (90 jours)
```

### 5.5 Rate Limiting

```yaml
Endpoints publics:
  - /auth/login: 5 req/min par IP
  - /auth/register: 3 req/min par IP
  - /auth/verify-otp: 3 req/min par phone

Endpoints authentifiés:
  - Standard: 100 req/min par user
  - Transactions: 10 req/min par user

Protection DDoS:
  - Cloudflare / AWS Shield
```

---

## 6. Intégrations Externes

### 6.1 Ecobank APIs

```yaml
Environnements:
  Sandbox: https://sandbox.ecobank.com/api/v1
  Production: https://api.ecobank.com/v1

Authentification:
  - OAuth 2.0 Client Credentials
  - API Key + Secret

Endpoints utilisés:
  - POST /transfers/internal     # Virements internes
  - POST /transfers/external     # Virements externes
  - POST /collections/init       # Initier collection
  - GET  /transactions/{ref}     # Statut transaction

Gestion erreurs:
  - Retry avec backoff exponentiel
  - Circuit breaker (Resilience4j)
  - Alerting sur échecs
```

### 6.2 Mobile Money

```yaml
Orange Money Mali:
  API: REST
  Auth: OAuth 2.0
  Operations: Cash-in, Cash-out, Status

Moov Money:
  API: REST
  Auth: API Key
  Operations: Cash-in, Cash-out, Status

Webhook callbacks:
  - POST /webhooks/orange-money
  - POST /webhooks/moov-money
```

### 6.3 SMS Gateway

```yaml
Provider primaire: Orange SMS Pro
Provider backup: Twilio

Configuration:
  - Failover automatique
  - Templates prédéfinis
  - Limite: 5 SMS/jour par user (OTP)
```

---

## 7. Infrastructure & Déploiement

### 7.1 Architecture Cloud

```
┌─────────────────────────────────────────────────────────────┐
│                         CLOUD (AWS/GCP)                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   CDN       │  │ Load        │  │  WAF / DDoS         │  │
│  │ CloudFront  │  │ Balancer    │  │  Protection         │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                     │             │
│         └────────────────┼─────────────────────┘             │
│                          │                                   │
│  ┌───────────────────────▼───────────────────────────────┐  │
│  │              KUBERNETES CLUSTER                        │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐      │  │
│  │  │ Auth    │ │ Wallet  │ │ Txn     │ │ Notif   │      │  │
│  │  │ Service │ │ Service │ │ Service │ │ Service │      │  │
│  │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘      │  │
│  │       └───────────┼───────────┼───────────┘           │  │
│  └───────────────────┼───────────┼───────────────────────┘  │
│                      │           │                           │
│  ┌───────────────────▼───────────▼───────────────────────┐  │
│  │                  DATA LAYER                            │  │
│  │  ┌──────────────┐  ┌───────┐  ┌──────────────────┐    │  │
│  │  │ PostgreSQL   │  │ Redis │  │ RabbitMQ         │    │  │
│  │  │ (Primary +   │  │ Cluster│ │ (HA)             │    │  │
│  │  │  Replica)    │  │       │  │                  │    │  │
│  │  └──────────────┘  └───────┘  └──────────────────┘    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                  MONITORING                            │  │
│  │  Prometheus │ Grafana │ ELK Stack │ Jaeger            │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Environnements

| Environnement | Usage | Données |
|---------------|-------|---------|
| DEV | Développement local | Fake data |
| STAGING | Tests intégration | Données anonymisées |
| UAT | Recette client | Données test |
| PRODUCTION | Live | Données réelles |

### 7.3 CI/CD Pipeline

```yaml
Pipeline:
  1. Code Push (GitHub)
  2. Build & Unit Tests
  3. Security Scan (Snyk, SonarQube)
  4. Docker Build
  5. Integration Tests
  6. Deploy Staging
  7. E2E Tests
  8. Manual Approval (Prod)
  9. Deploy Production
  10. Smoke Tests
  11. Rollback si échec
```

---

## 8. Monitoring & Observabilité

### 8.1 Stack Monitoring

```yaml
Métriques:
  - Prometheus + Grafana
  - Métriques applicatives (latence, throughput, erreurs)
  - Métriques infrastructure (CPU, RAM, disque)

Logs:
  - ELK Stack (Elasticsearch, Logstash, Kibana)
  - Logs structurés (JSON)
  - Retention: 90 jours

Tracing:
  - Jaeger / Zipkin
  - Correlation IDs
  - Spans inter-services

Alerting:
  - PagerDuty / OpsGenie
  - Slack notifications
  - Escalation policies
```

### 8.2 SLA & Métriques Clés

| Métrique | Objectif |
|----------|----------|
| Disponibilité | 99.9% |
| Latence P95 | < 500ms |
| Latence P99 | < 1s |
| Taux d'erreur | < 0.1% |
| Temps de récupération | < 5 min |

---

## 9. Conformité & Réglementation

### 9.1 BCEAO

```yaml
Exigences:
  - Agrément EME (Établissement de Monnaie Électronique)
  - Cantonnement des fonds
  - Reporting mensuel
  - Plafonds réglementaires
  - KYC obligatoire
```

### 9.2 LCB-FT (Lutte contre le blanchiment)

```yaml
Mesures:
  - Vérification identité clients
  - Monitoring transactions suspectes
  - Signalement automatique (seuils)
  - Gel de comptes
  - Conservation données (10 ans)

Seuils d'alerte:
  - Transaction unique > 1M XOF
  - Cumul journalier > 3M XOF
  - Transactions fragmentées
```

### 9.3 Protection des Données

```yaml
RGPD / Loi malienne:
  - Consentement explicite
  - Droit d'accès / rectification
  - Droit à l'oubli (sauf obligations légales)
  - Notification de breach (72h)
  - DPO désigné
```

---

## 10. Roadmap Technique

### Phase 1 (MVP - 3 mois)
- [x] Architecture de base
- [ ] Auth Service
- [ ] User Service
- [ ] Wallet Service (basique)
- [ ] Transaction Service (P2P)
- [ ] App Mobile (écrans principaux)
- [ ] Back-office (admin basique)

### Phase 2 (4-6 mois)
- [ ] KYC Service
- [ ] Intégration Ecobank
- [ ] Intégration Mobile Money
- [ ] Agent Service
- [ ] Notifications (push + SMS)

### Phase 3 (7-9 mois)
- [ ] Marketplace B2B
- [ ] Reporting avancé
- [ ] Optimisations performance
- [ ] Conformité complète BCEAO

### Phase 4 (10-12 mois)
- [ ] Extension B2C
- [ ] Features avancées
- [ ] Internationalisation
- [ ] API partenaires

---

## Annexes

### A. Conventions de Nommage

```yaml
API Endpoints:
  - kebab-case: /user-profiles
  - Pluriel pour collections: /users, /wallets
  - Verbe HTTP pour action: GET, POST, PUT, DELETE

Base de données:
  - snake_case: user_profiles
  - Préfixes: idx_ (index), fk_ (foreign key)

Code:
  - Java: CamelCase classes, camelCase methods
  - Flutter: camelCase variables, PascalCase classes
```

### B. Codes d'Erreur

```yaml
Format: JUFA-[MODULE]-[CODE]

Exemples:
  JUFA-AUTH-001: Invalid credentials
  JUFA-AUTH-002: OTP expired
  JUFA-WALLET-001: Insufficient balance
  JUFA-TXN-001: Transaction failed
  JUFA-KYC-001: Document rejected
```

### C. Configuration Environnements

```yaml
# application-prod.yml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USER}
    password: ${DATABASE_PASSWORD}
  
  redis:
    host: ${REDIS_HOST}
    port: 6379
    password: ${REDIS_PASSWORD}

jwt:
  secret: ${JWT_SECRET}
  expiration: 3600

ecobank:
  base-url: https://api.ecobank.com/v1
  client-id: ${ECOBANK_CLIENT_ID}
  client-secret: ${ECOBANK_CLIENT_SECRET}
```
