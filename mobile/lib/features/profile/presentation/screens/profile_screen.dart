import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: AppSpacing.xl),
            _buildKycStatus(user, context),
            const SizedBox(height: AppSpacing.lg),
            _buildMenuSection(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity? user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Center(
              child: Text(
                _getInitials(user?.phone ?? 'U'),
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(user?.phone ?? 'Utilisateur', style: AppTextStyles.h3),
          if (user?.email != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(user!.email!, style: AppTextStyles.bodySmall),
            ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _getUserTypeLabel(user?.userType),
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStatus(UserEntity? user, BuildContext context) {
    final kycLevel = user?.kycLevel ?? KycLevel.level0;
    final kycInfo = _getKycInfo(kycLevel);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: kycInfo['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: kycInfo['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kycInfo['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(kycInfo['icon'], color: kycInfo['color']),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vérification KYC', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(kycInfo['label'], style: AppTextStyles.bodySmall.copyWith(color: kycInfo['color'])),
              ],
            ),
          ),
          if (kycLevel != KycLevel.level3)
            TextButton(
              onPressed: () => context.push('/kyc'),
              child: const Text('Améliorer'),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, UserEntity? user) {
    final userType = user?.userType;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline,
            title: 'Informations personnelles',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.security,
            title: 'Sécurité',
            subtitle: 'PIN, mot de passe',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.verified_user_outlined,
            title: 'Vérification KYC',
            subtitle: 'Documents d\'identité',
            onTap: () => context.push('/kyc'),
          ),
          if (userType == UserType.wholesaler) ...[
            _buildDivider(),
            _MenuItem(
              icon: Icons.warehouse_outlined,
              title: 'Mon espace Grossiste',
              subtitle: 'Gérer produits, stock, commandes reçues',
              onTap: () => context.push('/b2b/wholesaler'),
            ),
            _buildDivider(),
            _MenuItem(
              icon: Icons.store,
              title: 'Profil entreprise',
              subtitle: 'Informations commerciales',
              onTap: () => context.push('/merchant'),
            ),
          ],
          if (userType == UserType.retailer) ...[
            _buildDivider(),
            _MenuItem(
              icon: Icons.storefront_outlined,
              title: 'Mon espace Détaillant',
              subtitle: 'Commander chez les grossistes',
              onTap: () => context.push('/b2b/retailer'),
            ),
            _buildDivider(),
            _MenuItem(
              icon: Icons.store,
              title: 'Profil boutique',
              subtitle: 'Informations commerciales',
              onTap: () => context.push('/merchant'),
            ),
          ],
          if (userType == UserType.agent) ...[
            _buildDivider(),
            _MenuItem(
              icon: Icons.support_agent_outlined,
              title: 'Mon espace Agent',
              subtitle: 'Transactions, commissions',
              onTap: () => context.push('/agent-home'),
            ),
          ],
          if (userType == UserType.merchant) ...[
            _buildDivider(),
            _MenuItem(
              icon: Icons.store,
              title: 'Espace Commerçant',
              subtitle: 'Gestion de votre activité',
              onTap: () => context.push('/merchant'),
            ),
          ],
          _buildDivider(),
          _MenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.help_outline,
            title: 'Aide & Support',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.info_outline,
            title: 'À propos de JUFA',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String phone) {
    if (phone.startsWith('+')) {
      return phone.substring(phone.length - 2);
    }
    return phone.substring(0, 2).toUpperCase();
  }

  String _getUserTypeLabel(UserType? type) {
    switch (type) {
      case UserType.individual:
        return 'Particulier';
      case UserType.wholesaler:
        return 'Grossiste';
      case UserType.retailer:
        return 'Détaillant';
      case UserType.merchant:
        return 'Commerçant';
      case UserType.agent:
        return 'Agent JUFA';
      case UserType.admin:
        return 'Administrateur';
      case UserType.bankAdmin:
        return 'Admin Banque';
      case UserType.superAdmin:
        return 'Super Admin';
      default:
        return 'Utilisateur';
    }
  }

  Map<String, dynamic> _getKycInfo(KycLevel? level) {
    switch (level) {
      case KycLevel.level1:
        return {'label': 'Niveau 1 - Basique', 'color': AppColors.warning, 'icon': Icons.verified_outlined};
      case KycLevel.level2:
        return {'label': 'Niveau 2 - Intermédiaire', 'color': AppColors.info, 'icon': Icons.verified};
      case KycLevel.level3:
        return {'label': 'Niveau 3 - Complet', 'color': AppColors.success, 'icon': Icons.verified};
      default:
        return {'label': 'Non vérifié', 'color': AppColors.textSecondary, 'icon': Icons.warning_outlined};
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.caption) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
