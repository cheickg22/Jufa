# JUFA - Application Mobile

Application mobile fintech pour l'inclusion financière au Mali.

## 🎯 Objectif

JUFA est une plateforme mobile sécurisée pour:
- **B2C**: Particuliers (transferts, paiements, airtime, épargne Nege)
- **B2B**: Entreprises (paiements massifs, trésorerie)
- **B2G**: Institutions (collecte impôts, services publics)

## 🏗️ Architecture

Le projet suit les principes de **Clean Architecture**:

```
lib/
├── core/                    # Fonctionnalités communes
│   ├── config/             # Configuration app
│   ├── constants/          # Constantes globales
│   ├── error/              # Gestion erreurs
│   ├── network/            # Configuration réseau
│   ├── security/           # Sécurité & chiffrement
│   ├── theme/              # Thèmes UI
│   └── utils/              # Utilitaires
├── features/               # Fonctionnalités métier
│   ├── auth/              # Authentification
│   ├── dashboard/         # Tableau de bord
│   ├── transfer/          # Transferts d'argent
│   ├── payment/           # Paiements (factures, airtime)
│   ├── nege/              # Épargne or/argent
│   └── profile/           # Profil utilisateur
└── main.dart              # Point d'entrée

Chaque feature suit:
- data/          # Data sources, models, repositories
- domain/        # Entities, use cases, repository interfaces
- presentation/  # UI, BLoC, widgets
```

## 📦 Prérequis

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode
- Firebase CLI (pour les notifications)

## 🚀 Installation

```bash
# Cloner le dépôt
git clone [repository-url]
cd jufa_mvp

# Installer les dépendances
flutter pub get

# Générer le code (models, injection)
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer l'application
flutter run
```

## 🔐 Configuration Sécurité

### Variables d'environnement

Créer un fichier `.env` à la racine:

```
API_BASE_URL=https://api.jufa.ml
SKALEET_API_KEY=your_key_here
DTONE_API_KEY=your_key_here
ENCRYPTION_KEY=your_encryption_key
```

### SSL Pinning

Les certificats SSL sont configurés dans `lib/core/security/ssl_pinning.dart`.

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Couverture de code
flutter test --coverage
```

## 📱 Build Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔗 Intégrations

- **Skaleet**: Infrastructure bancaire digitale
- **DT One**: Airtime et top-up mobile
- **BCEAO**: Interopérabilité UEMOA
- **Raffinerie Kankou Moussa**: Solution Nege (or/argent)

## 📄 Documentation

- [Guide d'intégration API](docs/API_INTEGRATION.md)
- [Architecture détaillée](docs/ARCHITECTURE.md)
- [Guide de sécurité](docs/SECURITY.md)
- [Guide utilisateur](docs/USER_GUIDE.md)

## 🌍 Localisation

L'application supporte:
- Français (défaut)
- Bambara
- Anglais

## 📞 Support

Pour toute question: support@jufa.ml

## 📜 Licence

Propriétaire - JUFA Mali © 2025
