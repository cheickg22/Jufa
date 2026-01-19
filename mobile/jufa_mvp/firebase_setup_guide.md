# 🔥 Guide Configuration Firebase pour Jufa (Projet Existant)

## 📱 Configuration Android - Projet Existant

### 1. Utiliser le projet Firebase existant
1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionner le projet existant "Jufa" (`com.jufa.ml`)
3. Vérifier que Cloud Messaging est activé

### 2. Ajouter l'app Android au projet existant
1. Dans le projet Firebase → "Ajouter une app" → Android
2. Package name: `ml.jufa.app` (correspond au applicationId dans build.gradle)
3. App nickname: `Jufa MVP Android`
4. SHA-1: `B3:A2:E1:D8:51:20:CB:A9:90:7B:4A:D7:E2:E2:73:55:45:84:32:B0`

> ✅ **Clé SHA-1 générée automatiquement pour votre environnement**

### 3. Télécharger google-services.json
1. Télécharger le fichier `google-services.json`
2. Placer dans: `android/app/google-services.json`

### 4. Configuration build.gradle

#### android/build.gradle (projet)
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

#### android/app/build.gradle
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.2.1'
    implementation 'com.google.firebase:firebase-analytics:21.3.0'
}
```

## 🍎 Configuration iOS

### 1. Ajouter l'app iOS au projet existant
1. Dans Firebase Console → "Ajouter une app" → iOS
2. Bundle ID: `ml.jufa.app` (même que Android pour cohérence)
3. App nickname: `Jufa MVP iOS`

### 2. Télécharger GoogleService-Info.plist
1. Télécharger le fichier `GoogleService-Info.plist`
2. Placer dans: `ios/Runner/GoogleService-Info.plist`
3. Ajouter au projet Xcode

### 3. Configuration iOS
Dans `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 🔔 Configuration Notifications

### Android Permissions
Dans `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<application>
    <!-- Service pour les notifications background -->
    <service
        android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
    
    <!-- Icône de notification -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/ic_notification" />
    
    <!-- Couleur de notification -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@color/notification_color" />
    
    <!-- Canal par défaut -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="jufa_default" />
</application>
```

### iOS Capabilities
1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Sélectionner Runner → Signing & Capabilities
3. Ajouter "Push Notifications"
4. Ajouter "Background Modes" → "Background processing" et "Remote notifications"

## 🔑 Clés API

### FCM Server Key
1. Firebase Console → Paramètres du projet → Cloud Messaging
2. Copier la "Clé du serveur"
3. Remplacer dans `firebase_notification_service.dart`:
```dart
static const String _fcmServerKey = 'VOTRE_CLE_SERVEUR_FCM';
```

## 🧪 Test des Notifications

### 1. Test via Firebase Console
1. Firebase Console → Cloud Messaging
2. "Envoyer votre premier message"
3. Sélectionner l'app et envoyer

### 2. Test via code
```dart
// Initialiser
await FirebaseNotificationService.initialize();

// Obtenir le token
final token = FirebaseNotificationService.fcmToken;
print('Token: $token');

// Envoyer une notification test
await FirebaseNotificationService.sendTransactionNotification(
  userToken: token!,
  type: 'payment',
  amount: 50000,
  currency: 'FCFA',
  status: 'completed',
);
```

## 📋 Checklist de Configuration

- [ ] Projet Firebase créé
- [ ] App Android ajoutée avec bon package name
- [ ] App iOS ajoutée avec bon bundle ID
- [ ] `google-services.json` téléchargé et placé
- [ ] `GoogleService-Info.plist` téléchargé et placé
- [ ] build.gradle configuré
- [ ] AppDelegate.swift configuré
- [ ] Permissions Android ajoutées
- [ ] Capabilities iOS activées
- [ ] Clé serveur FCM configurée
- [ ] Test de notification réussi

## 🚀 Commandes de Test

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get

# Tester Android
flutter run -d android

# Tester iOS
flutter run -d ios

# Build de production
flutter build apk --release
flutter build ios --release
```

## 🔧 Dépannage

### Erreurs communes:
1. **Token null**: Vérifier les permissions et la configuration
2. **Notifications non reçues**: Vérifier la clé serveur FCM
3. **Build failed**: Vérifier les fichiers de configuration
4. **iOS signing**: Configurer les certificats de développement

### Logs utiles:
```bash
# Logs Android
adb logcat | grep -i firebase

# Logs iOS
flutter logs
```
