# Modifications de l'Authentification

## Résumé des changements

L'authentification a été modifiée pour utiliser le **numéro de téléphone** comme identifiant principal au lieu de l'email.

## Changements effectués

### 1. Page d'inscription (`register_page.dart`)

#### Avant :
- Email : **obligatoire**
- Téléphone : obligatoire
- Identifiant de connexion : email OU téléphone

#### Après :
- Email : **optionnel** (mais validé s'il est rempli)
- Téléphone : **obligatoire** (identifiant principal)
- Identifiant de connexion : **téléphone uniquement**

**Modifications visuelles :**
- Label du champ email : `"Email (optionnel)"`
- Label du champ téléphone : `"Téléphone *"` avec helper text `"Numéro requis pour la connexion"`
- Le téléphone est toujours utilisé comme identifiant lors de la sauvegarde

### 2. Page de connexion (`login_page.dart`)

#### Avant :
- Champ : "Email ou téléphone"
- Type de clavier : email
- Icône : personne

#### Après :
- Champ : "Numéro de téléphone"
- Type de clavier : téléphone
- Icône : téléphone
- Helper text : "Utilisez votre numéro de téléphone"
- Message : "Connectez-vous avec votre numéro de téléphone"

### 3. Modèle de données (`user_entity.dart` & `user_model.dart`)

#### Avant :
```dart
final String email;  // Obligatoire
final String phone;  // Obligatoire
```

#### Après :
```dart
final String? email;  // Optionnel
final String phone;   // Obligatoire (identifiant principal)
```

## Impact sur l'API

Si vous utilisez une API backend, assurez-vous que :

1. Le champ `phone` est **obligatoire** lors de l'inscription
2. Le champ `email` est **optionnel** (nullable)
3. L'endpoint de connexion accepte le téléphone comme identifiant
4. La validation du numéro de téléphone malien est correcte : `+223 XX XX XX XX`

## Format du numéro de téléphone

Le format malien est automatiquement appliqué :
- Indicatif : `+223` (non modifiable)
- Format : `+223 XX XX XX XX` (8 chiffres après l'indicatif)
- Exemple : `+223 76 12 34 56`

## Tests recommandés

1. **Inscription avec téléphone uniquement** (sans email)
2. **Inscription avec téléphone + email**
3. **Connexion avec le numéro de téléphone**
4. **Vérification du format du numéro malien**

## Notes importantes

- L'email reste dans la base de données pour compatibilité future
- Le téléphone est maintenant l'identifiant unique principal
- Le formatage automatique du numéro malien est conservé
- La validation du mot de passe reste inchangée (minimum 6 caractères)

## Fichiers modifiés

1. `/lib/features/auth/presentation/pages/register_page.dart`
2. `/lib/features/auth/presentation/pages/login_page.dart`
3. `/lib/features/auth/domain/entities/user_entity.dart`
4. `/lib/features/auth/data/models/user_model.dart`

---

**Date de modification :** 19 novembre 2025
**Version :** 1.0.0
