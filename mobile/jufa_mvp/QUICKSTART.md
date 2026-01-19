# 🚀 Guide de Démarrage Rapide JUFA

## Installation Express (5 minutes)

```bash
# 1. Cloner et installer
git clone [repository-url]
cd jufa_mvp
flutter pub get

# 2. Générer le code
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Lancer l'app
flutter run
```

## 📱 Tester le MVP

### 1. Onboarding
- Lancer l'app → Voir le splash screen
- Navigation dans les 4 écrans d'onboarding
- Tester "Passer" et "Suivant"

### 2. Inscription/Connexion
- Cliquer sur "Créer un compte"
- Remplir le formulaire
- Ou utiliser "J'ai déjà un compte" pour se connecter

### 3. Dashboard
- Voir le solde (250 000 FCFA en démo)
- Masquer/afficher le solde avec l'icône œil
- Explorer les actions rapides

### 4. Transfert
- Cliquer "Envoyer" ou la carte "Factures"
- Entrer un numéro (ex: +223 76123456)
- Choisir un montant ou utiliser les montants rapides
- Valider le transfert

### 5. Paiements
- Section "Factures" → Choisir EDM, SOMAGEP, etc.
- Section "Airtime" → Choisir Orange, Malitel, Moov
- Entrer les informations et valider

### 6. Nege
- Accéder via le dashboard
- Onglet Or ou Argent
- Tester "Acheter" ou "Vendre"
- Utiliser les quantités rapides (0.5g, 1g, etc.)

### 7. Profil
- Icône profil en haut à droite
- Explorer les sections
- Tester la déconnexion

## 🎨 Personnalisation

### Changer les couleurs
```dart
// lib/core/theme/app_colors.dart
static const Color primary = Color(0xFFD4AF37); // Votre couleur
```

### Modifier l'API
```dart
// lib/core/config/app_config.dart
static const String apiBaseUrl = 'https://votre-api.com';
```

### Ajouter une langue
```dart
// lib/main.dart - supportedLocales
const Locale('yo', 'NG'), // Yoruba
```

## 🔧 Configuration Avancée

### Firebase (Notifications)
1. Créer projet sur [console.firebase.google.com](https://console.firebase.google.com)
2. Télécharger `google-services.json` (Android)
3. Télécharger `GoogleService-Info.plist` (iOS)
4. Placer dans les dossiers appropriés

### Variables d'environnement
```bash
# Créer .env
echo "API_BASE_URL=https://api.jufa.ml/v1" > .env
echo "SKALEET_API_KEY=your_key" >> .env
```

### Build de production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📦 Structure du Projet

```
jufa_mvp/
├── lib/
│   ├── core/                 # Fonctionnalités communes
│   │   ├── config/          # Configuration
│   │   ├── constants/       # Constantes
│   │   ├── theme/           # Thème & couleurs
│   │   ├── network/         # API client
│   │   ├── security/        # Sécurité
│   │   ├── utils/           # Utilitaires
│   │   └── widgets/         # Widgets réutilisables
│   │
│   ├── features/            # Fonctionnalités métier
│   │   ├── auth/           # Authentification
│   │   ├── dashboard/      # Tableau de bord
│   │   ├── transfer/       # Transferts
│   │   ├── payment/        # Paiements
│   │   ├── nege/           # Or/Argent
│   │   └── profile/        # Profil
│   │
│   └── main.dart           # Point d'entrée
│
├── docs/                    # Documentation
├── assets/                  # Images, fonts, etc.
└── test/                    # Tests
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage

# Analyser le code
flutter analyze
```

## 🐛 Problèmes Courants

### Erreur de dépendances
```bash
flutter clean && flutter pub get
```

### Problème de génération de code
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### App ne démarre pas
```bash
# Vérifier Flutter
flutter doctor

# Réinstaller les dépendances
rm -rf pubspec.lock
flutter pub get
```

## 📚 Ressources

- **Documentation**: `/docs`
- **API Integration**: `/docs/API_INTEGRATION.md`
- **Features**: `/docs/FEATURES.md`
- **Installation**: `/docs/INSTALLATION.md`

## 🎯 Prochaines Étapes

1. **Intégration API réelle**: Remplacer les données mock
2. **Tests**: Ajouter tests unitaires et d'intégration
3. **Traductions**: Compléter les traductions bambara et anglais
4. **KYC**: Implémenter le processus KYC complet
5. **Notifications**: Configurer Firebase Cloud Messaging
6. **Analytics**: Ajouter Firebase Analytics
7. **Crash Reporting**: Ajouter Crashlytics

## 💡 Conseils

### Performance
- Utiliser `const` constructeurs autant que possible
- Lazy loading pour les images
- Pagination pour les listes longues

### Sécurité
- Ne JAMAIS commiter les fichiers `.env`
- Utiliser SSL pinning en production
- Activer ProGuard pour Android

### UX
- Toujours afficher un loading indicator
- Messages d'erreur clairs et en français
- Feedback visuel pour chaque action

## 🤝 Contribuer

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📞 Support

- Email: support@jufa.ml
- Documentation: https://docs.jufa.ml
- GitHub Issues: [repository-url]/issues

---

**Note**: Ce MVP est une version de démonstration. Les transactions sont simulées et n'affectent pas de vrais comptes bancaires.
