# Guide d'Installation JUFA

## Prérequis

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code / Xcode
- Git

## Installation

### 1. Cloner le projet

```bash
git clone [repository-url]
cd jufa_mvp
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Générer le code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configuration Firebase

1. Créer un projet Firebase sur [console.firebase.google.com](https://console.firebase.google.com)
2. Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
3. Placer les fichiers dans les dossiers appropriés:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 5. Variables d'environnement

Créer un fichier `.env` à la racine:

```env
API_BASE_URL=https://api.jufa.ml/v1
SKALEET_API_KEY=your_skaleet_key
DTONE_API_KEY=your_dtone_key
ENCRYPTION_KEY=your_32_char_encryption_key
```

### 6. Lancer l'application

```bash
# Mode développement
flutter run

# Mode release
flutter run --release
```

## Build Production

### Android

```bash
# APK
flutter build apk --release

# App Bundle (pour Play Store)
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage

# Analyser le code
flutter analyze
```

## Dépannage

### Problème de dépendances

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erreur de version Flutter

```bash
flutter upgrade
flutter doctor
```

### Problème de cache

```bash
flutter pub cache repair
```

## Structure des Branches

- `main`: Version stable en production
- `develop`: Version de développement
- `feature/*`: Nouvelles fonctionnalités
- `hotfix/*`: Corrections urgentes

## Contact Support

- Email: dev@jufa.ml
- Documentation: https://docs.jufa.ml
