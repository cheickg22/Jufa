import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/services/legal_service.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  late LegalService _legalService;
  
  // Données utilisateur dynamiques
  String _userName = 'Utilisateur';
  String _userEmail = '';
  String _userPhone = '';
  String _userInitials = 'U';
  
  // Paramètres de l'application
  String _selectedLanguage = 'fr';
  String _currentPin = '';
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userName = await UserService.getFullName();
      final userEmail = await UserService.getEmail();
      final userPhone = await UserService.getPhone();
      final userInitials = await UserService.getInitials();
      
      // Vérifier si un PIN est configuré via l'API
      final hasPin = await _profileService.hasPin();
      
      if (mounted) {
        setState(() {
          _userName = userName;
          _userEmail = userEmail;
          _userPhone = userPhone;
          _userInitials = userInitials;
          _currentPin = hasPin ? 'configured' : '';
        });
      }
    } catch (e) {
      // En cas d'erreur, garder les valeurs par défaut
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // Header avec photo de profil
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    _userInitials,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Informations personnelles
          _buildSection(
            context,
            title: l10n.personalInfo,
            children: [
              _buildInfoTile(
                icon: Icons.email_outlined,
                title: l10n.email,
                value: _userEmail.isEmpty ? l10n.notProvided : _userEmail,
                onTap: () {
                  _showEditDialog(context, 'Email', _userEmail);
                },
              ),
              _buildInfoTile(
                icon: Icons.phone_outlined,
                title: l10n.phone,
                value: _userPhone.isEmpty ? l10n.notProvided : Formatters.formatPhoneNumber(_userPhone),
                onTap: () {
                  _showEditDialog(context, 'Téléphone', _userPhone);
                },
              ),
            ],
          ),
          
          // Sécurité
          _buildSection(
            context,
            title: l10n.security,
            children: [
              _buildMenuTile(
                icon: Icons.fingerprint,
                title: l10n.biometry,
                subtitle: l10n.biometrySubtitle,
                onTap: () {
                  context.push('/biometric-setup');
                },
              ),
              _buildMenuTile(
                icon: Icons.pin_outlined,
                title: l10n.pinCode,
                subtitle: _currentPin.isEmpty ? l10n.notConfigured : null,
                trailing: _currentPin.isEmpty 
                  ? null 
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                l10n.configured,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                onTap: () {
                  _showPinDialog(context);
                },
              ),
            ],
          ),
          
          // Paramètres
          _buildSection(
            context,
            title: l10n.settings,
            children: [
              Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) => _buildMenuTile(
                  icon: Icons.language,
                  title: l10n.language,
                  subtitle: localeProvider.languageName,
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
              ),
              _buildMenuTile(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: _notificationsEnabled ? l10n.enabled : l10n.disabled,
                onTap: () {
                  _showNotificationsDialog(context);
                },
              ),
            ],
          ),
          
          // Support
          _buildSection(
            context,
            title: l10n.support,
            children: [
              _buildMenuTile(
                icon: Icons.help_outline,
                title: l10n.helpCenter,
                subtitle: l10n.helpCenterSubtitle,
                onTap: () {
                  _showHelpCenterDialog(context);
                },
              ),
              _buildMenuTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () {
                  context.push('/privacy-policy');
                },
              ),
              _buildMenuTile(
                icon: Icons.description_outlined,
                title: l10n.termsOfService,
                onTap: () {
                  context.push('/terms-of-service');
                },
              ),
              _buildMenuTile(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.version,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
          
          // Déconnexion
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text(l10n.logout),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Méthodes helper pour l'affichage
  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }
  
  // Formater le numéro de téléphone au format XX XX XX XX
  String _formatPhoneInput(String digits) {
    if (digits.isEmpty) return '';
    
    String formatted = '';
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i > 0 && i % 2 == 0) {
        formatted += ' ';
      }
      formatted += digits[i];
    }
    return formatted;
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2A2A2A) : AppColors.border,
            ),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios, 
            size: 16,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
          onTap: onTap,
        );
      },
    );
  }
  
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          subtitle: subtitle != null 
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ) 
            : null,
          trailing: trailing ?? Icon(
            Icons.arrow_forward_ios, 
            size: 16, 
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
          onTap: onTap,
        );
      },
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Effacer les données utilisateur
              await UserService.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.disconnect),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String field, String currentValue) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: currentValue);
    bool isLoading = false;
    
    // Pour le téléphone, initialiser avec +223 si vide ou formater le numéro existant
    if (field == 'Téléphone') {
      String phoneValue = currentValue.replaceAll(RegExp(r'[^\d]'), '');
      if (phoneValue.isEmpty) {
        controller.text = '+223 ';
      } else if (phoneValue.startsWith('223')) {
        phoneValue = phoneValue.substring(3);
        controller.text = '+223 ${_formatPhoneInput(phoneValue)}';
      } else {
        controller.text = '+223 ${_formatPhoneInput(phoneValue)}';
      }
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${l10n.translate('edit_field')} $field'),
          content: field == 'Téléphone' 
            ? TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: field,
                  border: const OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '🇲🇱',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  hintText: '+223 XX XX XX XX',
                ),
                enabled: !isLoading,
                onChanged: (value) {
                  // Empêcher la suppression du préfixe +223
                  if (!value.startsWith('+223 ')) {
                    controller.text = '+223 ';
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );
                    return;
                  }
                  
                  // Formater automatiquement le numéro
                  String digits = value.substring(5).replaceAll(RegExp(r'[^\d]'), '');
                  if (digits.length <= 8) {
                    String formatted = '+223 ${_formatPhoneInput(digits)}';
                    if (formatted != value) {
                      controller.text = formatted;
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: formatted.length),
                      );
                    }
                  }
                },
              )
            : TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: field,
                  border: const OutlineInputBorder(),
                ),
                enabled: !isLoading,
              ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                
                try {
                  // Déterminer quel champ mettre à jour
                  Map<String, dynamic> updateData = {};
                  if (field == 'Email') {
                    await _profileService.updateProfile(email: controller.text);
                    setState(() => _userEmail = controller.text);
                    await UserService.saveUserInfo(
                      firstName: _userName.split(' ')[0],
                      lastName: _userName.split(' ').length > 1 ? _userName.split(' ')[1] : '',
                      email: controller.text,
                      phone: _userPhone,
                      password: '',
                      balance: 0,
                    );
                  } else if (field == 'Téléphone') {
                    await _profileService.updateProfile(phone: controller.text);
                    setState(() => _userPhone = controller.text);
                    await UserService.saveUserInfo(
                      firstName: _userName.split(' ')[0],
                      lastName: _userName.split(' ').length > 1 ? _userName.split(' ')[1] : '',
                      email: _userEmail,
                      phone: controller.text,
                      password: '',
                      balance: 0,
                    );
                  }
                  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('profile_updated_success')),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  setDialogState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                // Validation
                if (newPasswordController.text.length < 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Le mot de passe doit contenir au moins 8 caractères'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Les mots de passe ne correspondent pas'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                setDialogState(() => isLoading = true);
                
                try {
                  await _profileService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                    confirmPassword: confirmPasswordController.text,
                  );
                  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mot de passe modifié avec succès'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  setDialogState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('La fonctionnalité "$feature" sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    String tempSelectedLanguage = localeProvider.languageCode;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.chooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🇫🇷',
                      style: TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Radio<String>(
                  value: 'fr',
                  groupValue: tempSelectedLanguage,
                  onChanged: (value) {
                    setDialogState(() {
                      tempSelectedLanguage = value!;
                    });
                  },
                    ),
                  ],
                ),
                title: Text(l10n.french),
                onTap: () {
                  setDialogState(() {
                    tempSelectedLanguage = 'fr';
                  });
                },
              ),
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🇬🇧',
                      style: TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Radio<String>(
                  value: 'en',
                  groupValue: tempSelectedLanguage,
                  onChanged: (value) {
                    setDialogState(() {
                      tempSelectedLanguage = value!;
                    });
                  },
                    ),
                  ],
                ),
                title: Text(l10n.english),
                onTap: () {
                  setDialogState(() {
                    tempSelectedLanguage = 'en';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                // Sauvegarder la langue via le provider
                await localeProvider.setLocale(tempSelectedLanguage);
                
                setState(() {
                  _selectedLanguage = tempSelectedLanguage;
                });
                
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.translate('language_changed')} ${_getLanguageDisplayName(tempSelectedLanguage)}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }


  void _showPinDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentPinController = TextEditingController();
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    bool isChangingPin = _currentPin.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChangingPin ? l10n.translate('pin_dialog_title_change') : l10n.translate('pin_dialog_title_new')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isChangingPin) ...[
              TextField(
                controller: currentPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: l10n.translate('current_pin'),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: l10n.translate('new_pin'),
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: l10n.translate('confirm_pin'),
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.info, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.translate('pin_info'),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validation de base
              if (pinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.translate('pin_length_error')),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              if (pinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.translate('pin_mismatch_error')),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              // Si modification, vérifier l'ancien PIN
              if (isChangingPin) {
                if (currentPinController.text.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('pin_current_error')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                try {
                  final isValid = await _profileService.verifyPin(currentPinController.text);
                  if (!isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.translate('pin_incorrect_error')),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('pin_verification_error')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
              }
              
              try {
                // Sauvegarder le PIN via l'API
                await _profileService.setPin(
                  pin: pinController.text,
                  confirmPin: confirmPinController.text,
                );
                
                setState(() {
                  _currentPin = 'configured';
                });
                Navigator.pop(context);
                
                // Badge de succès avec icône
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isChangingPin ? l10n.translate('pin_changed_success') : l10n.translate('pin_configured_success'),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(e.toString().replaceAll('Exception: ', '')),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(isChangingPin ? l10n.translate('modify') : l10n.translate('configure')),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    bool tempNotificationsEnabled = _notificationsEnabled;
    bool tempPushNotifications = _pushNotifications;
    bool tempEmailNotifications = _emailNotifications;
    bool tempSmsNotifications = _smsNotifications;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.translate('notification_settings')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(l10n.translate('general_notifications')),
                subtitle: Text(l10n.translate('general_notifications_subtitle')),
                value: tempNotificationsEnabled,
                onChanged: (value) {
                  setDialogState(() {
                    tempNotificationsEnabled = value;
                    if (!value) {
                      tempPushNotifications = false;
                      tempEmailNotifications = false;
                      tempSmsNotifications = false;
                    }
                  });
                },
              ),
              const Divider(),
              SwitchListTile(
                title: Text(l10n.translate('push_notifications')),
                subtitle: Text(l10n.translate('push_notifications_subtitle')),
                value: tempPushNotifications,
                onChanged: tempNotificationsEnabled ? (value) {
                  setDialogState(() {
                    tempPushNotifications = value;
                  });
                } : null,
              ),
              SwitchListTile(
                title: Text(l10n.translate('email_notifications')),
                subtitle: Text(l10n.translate('email_notifications_subtitle')),
                value: tempEmailNotifications,
                onChanged: tempNotificationsEnabled ? (value) {
                  setDialogState(() {
                    tempEmailNotifications = value;
                  });
                } : null,
              ),
              SwitchListTile(
                title: Text(l10n.translate('sms_notifications')),
                subtitle: Text(l10n.translate('sms_notifications_subtitle')),
                value: tempSmsNotifications,
                onChanged: tempNotificationsEnabled ? (value) {
                  setDialogState(() {
                    tempSmsNotifications = value;
                  });
                } : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _notificationsEnabled = tempNotificationsEnabled;
                  _pushNotifications = tempPushNotifications;
                  _emailNotifications = tempEmailNotifications;
                  _smsNotifications = tempSmsNotifications;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.translate('notification_settings_updated')),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeController = TextEditingController();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'question';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.translate('contact_admin')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('message_type'),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: 'complaint', child: Text(l10n.translate('complaint'))),
                    DropdownMenuItem(value: 'request', child: Text(l10n.translate('request'))),
                    DropdownMenuItem(value: 'question', child: Text(l10n.translate('question'))),
                    DropdownMenuItem(value: 'suggestion', child: Text(l10n.translate('suggestion'))),
                  ],
                  onChanged: isLoading ? null : (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subjectController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: l10n.translate('subject'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  enabled: !isLoading,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l10n.translate('message'),
                    border: OutlineInputBorder(),
                    hintText: l10n.translate('message_placeholder'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('fill_all_fields')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                setDialogState(() => isLoading = true);

                try {
                  await _profileService.sendMessageToAdmin(
                    type: selectedType,
                    subject: subjectController.text,
                    message: messageController.text,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('message_sent_success')),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  setDialogState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.translate('send')),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) async {
    // Afficher un dialog de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Initialiser le service avec le LocaleProvider
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      _legalService = LegalService(localeProvider: localeProvider);
      
      // Récupérer le contenu "À propos" depuis l'API
      final response = await _legalService.getAbout();
      
      if (!context.mounted) return;
      
      // Fermer le dialog de chargement
      Navigator.pop(context);
      
      // Vérifier si la réponse est valide
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final title = data['title'] ?? 'À propos de Jufa';
        final content = data['content'] ?? '';
        final version = data['version'] ?? '1.0';
        
        // Afficher le dialog avec le contenu dynamique
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Html(
                data: content,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "h1": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(bottom: 12),
                  ),
                  "h2": Style(
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(top: 16, bottom: 8),
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "ul": Style(
                    margin: Margins.only(left: 16, bottom: 12),
                  ),
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          ),
        );
      } else {
        // Si pas de contenu, afficher le contenu par défaut
        _showDefaultAboutDialog(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      
      // Fermer le dialog de chargement
      Navigator.pop(context);
      
      // En cas d'erreur, afficher le contenu par défaut
      print('❌ Erreur lors de la récupération du contenu À propos: $e');
      _showDefaultAboutDialog(context);
    }
  }

  void _showDefaultAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('about_jufa')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('jufa_description'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
            Text('Build: 100'),
            SizedBox(height: 16),
            Text(
              l10n.translate('jufa_long_description'),
            ),
            SizedBox(height: 16),
            Text(
              l10n.translate('all_rights_reserved'),
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
