# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2025-10-18

### ✨ Ajouté

#### Authentification
- Écran splash avec animation
- Onboarding interactif (4 écrans)
- Inscription utilisateur avec validation complète
- Connexion par email ou téléphone
- Gestion de session sécurisée
- Support biométrique (Touch/Face ID)

#### Dashboard
- Affichage du solde avec masquage
- Actions rapides (Envoyer, Recevoir, Recharger)
- Grille de services
- Transactions récentes
- Accès rapide au profil

#### Transfert
- Envoi d'argent vers compte JUFA
- Vérification du destinataire
- Montants rapides pré-définis
- Description optionnelle
- Résumé et confirmation
- Validation du solde

#### Paiements
- Paiement factures EDM (électricité)
- Paiement factures SOMAGEP (eau)
- Paiement Internet (Orange, Malitel)
- Recharge airtime Orange Mali
- Recharge airtime Malitel
- Recharge airtime Moov Africa

#### Nege (Or/Argent)
- Consultation prix temps réel
- Visualisation solde en grammes
- Achat d'or et d'argent
- Vente de métaux
- Historique des transactions
- Calculateur de valeur

#### Profil
- Affichage informations utilisateur
- Gestion sécurité (mot de passe, PIN)
- Paramètres application
- Support et aide
- Déconnexion

#### Infrastructure
- Clean Architecture (Domain/Data/Presentation)
- State management avec BLoC
- Injection de dépendances (GetIt)
- Routing avec GoRouter
- Stockage sécurisé (Flutter Secure Storage)
- Chiffrement AES-256
- Client API avec Dio
- Gestion réseau et cache
- Gestion des erreurs robuste
- Logs structurés

#### Design
- Thème personnalisé JUFA
- Palette couleurs or/vert Mali
- Widgets réutilisables
- Animations fluides
- Responsive design
- Support mode sombre (préparé)

#### Sécurité
- Chiffrement des données sensibles
- Hash SHA-256 pour mots de passe
- Secure Storage natif
- Session timeout
- Validation côté client

#### Documentation
- README complet
- Guide d'installation
- Documentation des features
- Guide d'intégration API
- Architecture détaillée

### 🔧 Configuration
- pubspec.yaml avec toutes dépendances
- analysis_options.yaml pour linting
- .gitignore pour Flutter
- Structure de dossiers Clean Architecture

### 📦 Dépendances principales
- flutter_bloc: ^8.1.3
- get_it: ^7.6.4
- dio: ^5.3.3
- hive: ^2.2.3
- go_router: ^12.1.1
- flutter_secure_storage: ^9.0.0
- local_auth: ^2.1.7
- firebase_core: ^2.24.0
- encrypt: ^5.0.3

## [0.1.0] - 2025-10-15

### 🎯 Planification
- Définition du MVP
- Architecture du projet
- Choix des technologies
- Design UI/UX initial

---

## Types de changements

- **✨ Ajouté**: pour les nouvelles fonctionnalités
- **🔧 Modifié**: pour les changements de fonctionnalités existantes
- **🐛 Corrigé**: pour les corrections de bugs
- **🗑️ Supprimé**: pour les fonctionnalités supprimées
- **🔒 Sécurité**: pour les corrections de sécurité
- **📚 Documentation**: pour les changements de documentation
- **⚡ Performance**: pour les améliorations de performance
