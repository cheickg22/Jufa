import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/biometric_preferences.dart';
import '../../../../core/error/exceptions.dart';

class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  State<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage> {
  final BiometricService _biometricService = BiometricService(LocalAuthentication());
  
  bool _isLoading = false;
  bool _isBiometricEnabled = false;
  bool _isDeviceSupported = false;
  bool _isSimulationMode = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadBiometricPreferences();
  }

  Future<void> _loadBiometricPreferences() async {
    final isEnabled = await BiometricPreferences.isBiometricEnabled();
    setState(() {
      _isBiometricEnabled = isEnabled;
    });
  }

  Future<void> _checkBiometricSupport() async {
    setState(() => _isLoading = true);
    
    try {
      final isSupported = await _biometricService.isDeviceSupported();
      final canCheck = await _biometricService.canCheckBiometrics();
      final availableBiometrics = await _biometricService.getAvailableBiometrics();
      
      setState(() {
        _isDeviceSupported = isSupported && canCheck;
        _isSimulationMode = !isSupported || !canCheck || availableBiometrics.isEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isDeviceSupported = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric() async {
    setState(() => _isLoading = true);

    try {
      if (!_isBiometricEnabled) {
        // Activer la biométrie
        bool success = false;
        
        if (_isSimulationMode) {
          // Mode simulation pour émulateurs
          await Future.delayed(const Duration(seconds: 1));
          success = true;
          _showInfoDialog('Mode Simulation', 
            'Biométrie simulée activée. Cette fonctionnalité nécessite un appareil physique avec biométrie configurée pour fonctionner réellement.');
        } else {
          // Mode réel pour appareils physiques
          success = await _biometricService.authenticate(
            localizedReason: 'Authentifiez-vous pour activer la biométrie',
          );
        }
        
        if (success) {
          setState(() => _isBiometricEnabled = true);
          await BiometricPreferences.setBiometricEnabled(true);
          if (!_isSimulationMode) {
            _showSuccessDialog('Biométrie activée', 
              'L\'authentification biométrique a été activée avec succès.');
          }
        }
      } else {
        // Désactiver la biométrie
        setState(() => _isBiometricEnabled = false);
        await BiometricPreferences.setBiometricEnabled(false);
        _showSuccessDialog('Biométrie désactivée', 
          'L\'authentification biométrique a été désactivée.');
      }
    } on BiometricException catch (e) {
      _showErrorDialog('Erreur biométrique', e.message);
    } catch (e) {
      _showErrorDialog('Erreur', 'Une erreur inattendue s\'est produite: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testBiometric() async {
    if (!_isBiometricEnabled) {
      _showErrorDialog('Biométrie désactivée', 
        'Veuillez d\'abord activer l\'authentification biométrique.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _biometricService.authenticate(
        localizedReason: 'Test d\'authentification biométrique',
      );
      
      if (success) {
        _showSuccessDialog('Test réussi', 
          'L\'authentification biométrique fonctionne correctement.');
      }
    } on BiometricException catch (e) {
      _showErrorDialog('Test échoué', e.message);
    } catch (e) {
      _showErrorDialog('Erreur', 'Une erreur inattendue s\'est produite.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppColors.info),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Compris'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration Biométrique'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec icône
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isBiometricEnabled 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.fingerprint,
                            size: 40,
                            color: _isBiometricEnabled 
                                ? AppColors.success 
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Authentification Biométrique',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sécurisez votre compte avec votre biométrie',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Statut du support biométrique
                  _buildStatusCard(),

                  const SizedBox(height: 24),


                  // Configuration
                  _buildConfigurationCard(),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    Color cardColor;
    Color iconColor;
    IconData iconData;
    String title;
    String subtitle;

    if (_isSimulationMode) {
      cardColor = AppColors.warning.withOpacity(0.1);
      iconColor = AppColors.warning;
      iconData = Icons.science;
      title = 'Mode Simulation';
      subtitle = 'Émulateur détecté - Fonctionnalité simulée pour les tests';
    } else if (_isDeviceSupported) {
      cardColor = AppColors.success.withOpacity(0.1);
      iconColor = AppColors.success;
      iconData = Icons.check_circle;
      title = 'Biométrie supportée';
      subtitle = 'Votre appareil supporte l\'authentification biométrique';
    } else {
      cardColor = AppColors.error.withOpacity(0.1);
      iconColor = AppColors.error;
      iconData = Icons.error;
      title = 'Biométrie non supportée';
      subtitle = 'Votre appareil ne supporte pas la biométrie ou aucune biométrie n\'est configurée';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildConfigurationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Activer la biométrie'),
            subtitle: Text(
              _isBiometricEnabled
                  ? 'L\'authentification biométrique est activée'
                  : 'L\'authentification biométrique est désactivée',
            ),
            value: _isBiometricEnabled,
            onChanged: (_isDeviceSupported || _isSimulationMode) ? (_) => _toggleBiometric() : null,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isBiometricEnabled) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testBiometric,
              icon: Icon(Icons.security),
              label: Text('Tester la biométrie'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
