import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBiometricLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final biometricState = ref.watch(biometricNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? AppColorsDark.background : AppColors.background;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.surface;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final dividerColor = isDark ? AppColorsDark.divider : AppColors.divider;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Paramètres', style: TextStyle(color: textPrimary)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSectionTitle('Apparence', textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                _buildThemeTile(
                  context: context,
                  title: 'Thème système',
                  subtitle: 'Suivre les paramètres de l\'appareil',
                  isSelected: themeMode == ThemeMode.system,
                  icon: Icons.brightness_auto,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => _setThemeMode(ThemeMode.system),
                ),
                Divider(height: 1, color: dividerColor, indent: 56),
                _buildThemeTile(
                  context: context,
                  title: 'Thème clair',
                  subtitle: 'Interface claire',
                  isSelected: themeMode == ThemeMode.light,
                  icon: Icons.light_mode,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => _setThemeMode(ThemeMode.light),
                ),
                Divider(height: 1, color: dividerColor, indent: 56),
                _buildThemeTile(
                  context: context,
                  title: 'Thème sombre',
                  subtitle: 'Interface sombre, économie de batterie',
                  isSelected: themeMode == ThemeMode.dark,
                  icon: Icons.dark_mode,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => _setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Sécurité', textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                if (biometricState.isAvailable) ...[
                  ListTile(
                    leading: Icon(
                      biometricState.biometricTypeName == 'Face ID'
                          ? Icons.face
                          : Icons.fingerprint,
                      color: textSecondary,
                    ),
                    title: Text(
                      biometricState.biometricTypeName,
                      style: TextStyle(color: textPrimary),
                    ),
                    subtitle: Text(
                      biometricState.isEnabled
                          ? 'Connexion rapide activée'
                          : 'Activez pour une connexion rapide',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    trailing: _isBiometricLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                            value: biometricState.isEnabled,
                            onChanged: (value) => _toggleBiometric(value),
                          ),
                  ),
                  if (biometricState.isEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                      child: Text(
                        'Vos identifiants sont stockés de manière sécurisée sur votre appareil.',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ),
                ] else
                  ListTile(
                    leading: Icon(Icons.fingerprint, color: textSecondary),
                    title: Text('Biométrie', style: TextStyle(color: textPrimary)),
                    subtitle: Text(
                      'Non disponible sur cet appareil',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    trailing: Icon(Icons.info_outline, color: textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Mode hors-ligne', textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wifi_off, color: textSecondary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Consultation hors-ligne',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Actif',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Consultez votre solde et historique même sans connexion. '
                  'Les données sont synchronisées automatiquement lors de la reconnexion.',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required IconData icon,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textSecondary),
      title: Text(title, style: TextStyle(color: textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12)),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : Icon(Icons.circle_outlined, color: textSecondary),
      onTap: onTap,
    );
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await ref.read(themeModeProvider.notifier).setThemeMode(mode);
  }

  Future<void> _toggleBiometric(bool enable) async {
    setState(() => _isBiometricLoading = true);
    
    try {
      final biometricNotifier = ref.read(biometricNotifierProvider.notifier);
      
      if (enable) {
        final authenticated = await biometricNotifier.authenticate();
        if (authenticated && mounted) {
          await _showCredentialsDialog();
        }
      } else {
        await biometricNotifier.disable();
      }
    } finally {
      if (mounted) {
        setState(() => _isBiometricLoading = false);
      }
    }
  }

  Future<void> _showCredentialsDialog() async {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Activer la biométrie'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez vos identifiants pour activer la connexion biométrique.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  hintText: '+223...',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await ref.read(biometricNotifierProvider.notifier).enable(
        phoneController.text.trim(),
        passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biométrie activée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
