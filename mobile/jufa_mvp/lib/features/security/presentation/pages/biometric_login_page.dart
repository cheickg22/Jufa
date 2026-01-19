import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/error/exceptions.dart';

class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});

  @override
  State<BiometricLoginPage> createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage>
    with TickerProviderStateMixin {
  final BiometricService _biometricService = BiometricService(LocalAuthentication());
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isAuthenticating = false;
  bool _isDeviceSupported = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkBiometricSupport();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final isSupported = await _biometricService.isDeviceSupported();
      final canCheck = await _biometricService.canCheckBiometrics();
      
      setState(() {
        _isDeviceSupported = isSupported && canCheck;
      });
      
      if (_isDeviceSupported) {
        // Démarrer automatiquement l'authentification
        _authenticateWithBiometric();
      }
    } catch (e) {
      setState(() {
        _isDeviceSupported = false;
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (!_isDeviceSupported || _isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final success = await _biometricService.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à votre compte',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      
      if (success) {
        // Authentification réussie
        _onAuthenticationSuccess();
      } else {
        setState(() => _isAuthenticating = false);
      }
    } on BiometricException catch (e) {
      setState(() => _isAuthenticating = false);
      _showErrorDialog('Erreur d\'authentification', e.message);
    } catch (e) {
      setState(() => _isAuthenticating = false);
      _showErrorDialog('Erreur', 'Une erreur inattendue s\'est produite.');
    }
  }

  void _onAuthenticationSuccess() {
    // Animation de succès
    _pulseController.stop();
    
    // Rediriger vers le dashboard
    context.go('/dashboard');
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Proposer de réessayer
              _authenticateWithBiometric();
            },
            child: Text('Réessayer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retourner à la page de connexion normale
              context.go('/login');
            },
            child: Text('Connexion normale'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo ou icône de l'app
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'JUFA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Titre
              Text(
                'Authentification Biométrique',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Utilisez votre empreinte digitale ou votre visage pour vous connecter rapidement et en toute sécurité',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Icône biométrique animée
              if (_isDeviceSupported) ...[
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _isAuthenticating 
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 60,
                          color: _isAuthenticating 
                              ? AppColors.primary 
                              : AppColors.primary.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                if (_isAuthenticating) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Authentification en cours...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _authenticateWithBiometric,
                    icon: Icon(Icons.fingerprint),
                    label: Text('S\'authentifier'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // Device non supporté
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Biométrie non disponible',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Votre appareil ne supporte pas l\'authentification biométrique ou aucune biométrie n\'est configurée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
              
              const Spacer(),
              
              // Bouton de connexion alternative
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text('Utiliser mot de passe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
