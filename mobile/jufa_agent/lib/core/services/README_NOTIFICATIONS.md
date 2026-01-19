# 🔔 Services de Notifications Jufa

## 📁 Fichiers Disponibles

### ✅ **firebase_simple_service.dart** (ACTUEL)
- **Status** : ✅ Actif et fonctionnel
- **Dépendances** : Firebase Core + Messaging uniquement
- **Fonctionnalités** :
  - Notifications push Firebase
  - Gestion des tokens FCM
  - Envoi de notifications
  - Topics et abonnements
  - Pas de notifications locales

### ⚠️ **firebase_notification_service.dart** (DÉSACTIVÉ)
- **Status** : ❌ Temporairement désactivé
- **Problème** : Conflits avec flutter_local_notifications v15+
- **Fonctionnalités** : Service complet avec notifications locales
- **Réactivation** : Quand les conflits seront résolus

### 📱 **notification_service.dart** (SIMPLE)
- **Status** : ✅ Service de base
- **Fonctionnalités** : Notifications simulées pour développement

## 🚀 Utilisation Recommandée

### Initialisation
```dart
import 'package:jufa_mvp/core/services/firebase_simple_service.dart';

// Dans main.dart
await FirebaseSimpleService.initialize();
```

### Obtenir le Token FCM
```dart
final token = FirebaseSimpleService.fcmToken;
print('Token FCM: $token');
```

### Envoyer une Notification
```dart
await FirebaseSimpleService.sendTransactionNotification(
  userToken: 'user_fcm_token',
  type: 'payment',
  amount: 50000,
  currency: 'FCFA',
  status: 'completed',
  merchantName: 'Boutique ABC',
);
```

### Écouter les Notifications
```dart
FirebaseSimpleService.notificationStream?.listen((notification) {
  print('Notification reçue: ${notification['title']}');
  print('Type: ${notification['type']}');
  print('Data: ${notification['data']}');
});
```

### S'abonner à des Topics
```dart
// S'abonner aux promotions
await FirebaseSimpleService.subscribeToTopic('promotions');

// S'abonner aux alertes sécurité
await FirebaseSimpleService.subscribeToTopic('security_alerts');

// Se désabonner
await FirebaseSimpleService.unsubscribeFromTopic('promotions');
```

## 🔧 Configuration Firebase

### 1. Console Firebase
1. Projet existant : `com.jufa.ml`
2. Ajouter app Android : `ml.jufa.app`
3. SHA-1 : `B3:A2:E1:D8:51:20:CB:A9:90:7B:4A:D7:E2:E2:73:55:45:84:32:B0`

### 2. Fichiers Requis
- `android/app/google-services.json` (à télécharger)
- `ios/Runner/GoogleService-Info.plist` (à télécharger)

### 3. Clé Serveur FCM
Remplacer dans `firebase_simple_service.dart` :
```dart
static const String _fcmServerKey = 'VOTRE_CLE_SERVEUR_FCM';
```

## 📱 Types de Notifications Supportées

### Notifications de Transaction
```dart
await FirebaseSimpleService.sendTransactionNotification(
  userToken: token,
  type: 'payment',      // payment, transfer, deposit, withdrawal
  amount: 25000,
  currency: 'FCFA',
  status: 'completed',  // completed, pending, failed
  merchantName: 'Optionnel',
  transactionId: 'TXN123',
);
```

### Notifications Génériques
```dart
await FirebaseSimpleService.sendPushNotification(
  token: token,
  title: 'Titre',
  body: 'Message',
  data: {'custom': 'data'},
  imageUrl: 'https://example.com/image.jpg',
);
```

### Notifications en Masse
```dart
final result = await FirebaseSimpleService.sendBulkNotification(
  tokens: ['token1', 'token2', 'token3'],
  title: 'Promotion Spéciale',
  body: 'Offre limitée !',
);

print('Envoyées: ${result['success_count']}');
print('Échecs: ${result['failure_count']}');
```

## 🔮 Migration Future

Quand `flutter_local_notifications` sera compatible :

1. **Réactiver** le package dans `pubspec.yaml`
2. **Décommenter** `firebase_notification_service.dart`
3. **Remplacer** `FirebaseSimpleService` par `FirebaseNotificationService`
4. **Tester** les notifications locales

## 🐛 Dépannage

### Token null
```dart
// Vérifier les permissions
final settings = await FirebaseMessaging.instance.requestPermission();
print('Status: ${settings.authorizationStatus}');
```

### Notifications non reçues
1. Vérifier la clé serveur FCM
2. Tester avec Firebase Console
3. Vérifier les logs : `flutter logs`

### Erreurs de compilation
1. `flutter clean`
2. `flutter pub get`
3. Vérifier les versions dans `pubspec.yaml`

## 📊 Monitoring

### Logs Disponibles
- `🔥 Firebase Simple Service initialisé`
- `📱 Message foreground: [titre]`
- `🔓 Message ouvert: [titre]`
- `✅ Notification envoyée avec succès`
- `❌ Erreur envoi: [détails]`

### Métriques
- Tokens FCM générés
- Notifications envoyées/reçues
- Taux de succès des envois
- Abonnements aux topics
