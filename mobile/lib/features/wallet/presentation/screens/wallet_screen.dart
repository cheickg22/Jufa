import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Wallet'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/momo-history'),
            tooltip: 'Historique',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletsProvider);
        },
        child: walletsAsync.when(
          data: (wallets) {
            if (wallets.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _buildTotalBalance(wallets),
                const SizedBox(height: AppSpacing.xl),
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.xl),
                Text('Mes portefeuilles', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                ...wallets.map((wallet) => _buildWalletCard(context, wallet)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(context, ref, error),
        ),
      ),
    );
  }

  Widget _buildTotalBalance(List wallets) {
    final total = wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final formatted = _formatBalance(total);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Solde total',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$formatted XOF',
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.add_circle_outline,
          label: 'Dépôt',
          color: AppColors.success,
          onTap: () => context.push('/deposit'),
        ),
        _ActionButton(
          icon: Icons.remove_circle_outline,
          label: 'Retrait',
          color: AppColors.warning,
          onTap: () => context.push('/withdrawal'),
        ),
        _ActionButton(
          icon: Icons.send,
          label: 'Envoyer',
          color: AppColors.primary,
          onTap: () => context.push('/transfer'),
        ),
        _ActionButton(
          icon: Icons.qr_code_scanner,
          label: 'Scanner',
          color: AppColors.info,
          onTap: () => context.push('/qr/scan'),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, wallet) {
    final iconData = _getWalletIcon(wallet.walletType);
    final color = _getWalletColor(wallet.walletType);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(iconData, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWalletName(wallet.walletType),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  wallet.status == 'ACTIVE' ? 'Actif' : 'Inactif',
                  style: AppTextStyles.caption.copyWith(
                    color: wallet.status == 'ACTIVE' ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                wallet.formattedBalance,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Disponible',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun portefeuille',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Vous n\'avez pas encore de portefeuille.\nContactez le support pour en créer un.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getErrorMessage(error),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(walletsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBalance(double balance) {
    return balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('SocketException') || message.contains('connection')) {
      return 'Impossible de se connecter au serveur.\nVérifiez votre connexion internet.';
    }
    if (message.contains('timeout') || message.contains('Timeout')) {
      return 'Le serveur met trop de temps à répondre.\nVeuillez réessayer.';
    }
    if (message.contains('401') || message.contains('Unauthorized')) {
      return 'Votre session a expiré.\nVeuillez vous reconnecter.';
    }
    return 'Une erreur est survenue.\nVeuillez réessayer.';
  }

  IconData _getWalletIcon(String type) {
    switch (type.toUpperCase()) {
      case 'B2C':
        return Icons.person;
      case 'B2B':
        return Icons.business;
      case 'AGENT':
        return Icons.support_agent;
      case 'COMMISSION':
        return Icons.monetization_on;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getWalletColor(String type) {
    switch (type.toUpperCase()) {
      case 'B2C':
        return AppColors.primary;
      case 'B2B':
        return AppColors.secondary;
      case 'AGENT':
        return Colors.orange;
      case 'COMMISSION':
        return Colors.purple;
      default:
        return AppColors.info;
    }
  }

  String _getWalletName(String type) {
    switch (type.toUpperCase()) {
      case 'B2C':
        return 'Portefeuille Personnel';
      case 'B2B':
        return 'Portefeuille Professionnel';
      case 'AGENT':
        return 'Portefeuille Agent';
      case 'COMMISSION':
        return 'Commissions';
      default:
        return 'Portefeuille';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
