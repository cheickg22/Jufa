import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/l10n/app_localizations.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  Future<void> _selectLanguage(BuildContext context, String languageCode) async {
    // Changer la langue immédiatement via le provider
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.setLocale(languageCode);
    
    // Sauvegarder la préférence supplémentaire
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_selected', true);
    
    if (!context.mounted) return;
    
    // Rediriger vers l'onboarding
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'JUFA',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Titre
                Text(
                  'Choose your language',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Choisissez votre langue',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 64),
                
                // Bouton Français
                _LanguageButton(
                  flag: '🇫🇷',
                  language: 'Français',
                  subtitle: 'French',
                  onTap: () => _selectLanguage(context, 'fr'),
                ),
                
                const SizedBox(height: 16),
                
                // Bouton Anglais
                _LanguageButton(
                  flag: '🇬🇧',
                  language: 'English',
                  subtitle: 'Anglais',
                  onTap: () => _selectLanguage(context, 'en'),
                ),
                
                const SizedBox(height: 48),
                
                // Note
                Text(
                  'You can change this later in settings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Vous pouvez changer cela plus tard dans les paramètres',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flag;
  final String language;
  final String subtitle;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flag,
    required this.language,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Drapeau
            Text(
              flag,
              style: TextStyle(fontSize: 48),
            ),
            
            const SizedBox(width: 20),
            
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Icône
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
