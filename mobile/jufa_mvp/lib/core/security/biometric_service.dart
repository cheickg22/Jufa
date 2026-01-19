import 'package:local_auth/local_auth.dart';
import '../error/exceptions.dart';

class BiometricService {
  final LocalAuthentication _localAuth;
  
  BiometricService(this._localAuth);
  
  // Vérifier si le device supporte la biométrie
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
  
  // Vérifier si la biométrie est disponible
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
  
  // Obtenir les types de biométrie disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  // Authentifier avec la biométrie
  Future<bool> authenticate({
    String localizedReason = 'Authentifiez-vous pour continuer',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      print('🔐 BiometricService: Début de l\'authentification');
      
      final isSupported = await isDeviceSupported();
      print('🔐 BiometricService: Device supporté: $isSupported');
      if (!isSupported) {
        throw BiometricException('Biométrie non supportée sur cet appareil');
      }
      
      final canCheck = await canCheckBiometrics();
      print('🔐 BiometricService: Peut vérifier biométrie: $canCheck');
      if (!canCheck) {
        throw BiometricException('Biométrie non configurée sur cet appareil');
      }
      
      final availableBiometrics = await getAvailableBiometrics();
      print('🔐 BiometricService: Biométries disponibles: $availableBiometrics');
      if (availableBiometrics.isEmpty) {
        throw BiometricException('Aucune biométrie configurée. Veuillez configurer une empreinte digitale ou reconnaissance faciale dans les paramètres de votre appareil.');
      }
      
      print('🔐 BiometricService: Lancement de l\'authentification...');
      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
      
      print('🔐 BiometricService: Résultat authentification: $result');
      return result;
    } on BiometricException {
      rethrow;
    } catch (e) {
      print('🔐 BiometricService: Erreur: $e');
      
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('notavailable') || errorString.contains('not available')) {
        throw BiometricException('Biométrie non disponible sur cet appareil');
      } else if (errorString.contains('notenrolled') || errorString.contains('not enrolled')) {
        throw BiometricException('Aucune biométrie enregistrée. Configurez une empreinte digitale ou reconnaissance faciale dans les paramètres.');
      } else if (errorString.contains('lockedout') || errorString.contains('locked out')) {
        throw BiometricException('Biométrie verrouillée temporairement. Réessayez plus tard.');
      } else if (errorString.contains('permanentlylockedout') || errorString.contains('permanently locked')) {
        throw BiometricException('Biométrie verrouillée définitivement. Utilisez votre mot de passe.');
      } else if (errorString.contains('usecancel') || errorString.contains('user cancel')) {
        throw BiometricException('Authentification annulée par l\'utilisateur');
      } else if (errorString.contains('fragmentactivity') || errorString.contains('fragment activity')) {
        throw BiometricException('Erreur de configuration Android. Redémarrez l\'application et réessayez.');
      }
      
      throw BiometricException('Erreur d\'authentification: ${e.toString()}');
    }
  }
  
  // Annuler l'authentification en cours
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }
}
