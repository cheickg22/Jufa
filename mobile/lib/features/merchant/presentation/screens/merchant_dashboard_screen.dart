import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/merchant_entity.dart';
import '../providers/merchant_provider.dart';

class MerchantDashboardScreen extends ConsumerWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(merchantDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Espace Commerçant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorOrSetup(context, ref, error.toString()),
        data: (dashboard) => _buildDashboard(context, ref, dashboard),
      ),
    );
  }

  Widget _buildErrorOrSetup(BuildContext context, WidgetRef ref, String error) {
    if (error.contains('not found') || error.contains('JUFA-MERCHANT-002')) {
      return _buildSetupPrompt(context);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Erreur: $error', textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => ref.invalidate(merchantDashboardProvider),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Icon(Icons.store, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Devenez Commerçant', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Créez votre profil commerçant pour accéder aux fonctionnalités de gestion de votre activité.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/merchant/setup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: const Text('Créer mon profil', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, MerchantDashboardEntity dashboard) {
    final isWholesaler = dashboard.profile.merchantType == MerchantType.wholesaler;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(merchantDashboardProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(dashboard.profile),
            const SizedBox(height: AppSpacing.lg),
            _buildStatsGrid(dashboard, isWholesaler, currencyFormat),
            const SizedBox(height: AppSpacing.lg),
            _buildCreditCard(dashboard, currencyFormat),
            const SizedBox(height: AppSpacing.lg),
            _buildQuickActions(context, isWholesaler),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(MerchantProfileEntity profile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                profile.initials,
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.businessName,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    profile.merchantTypeLabel,
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
                if (profile.city != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(profile.city!, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (profile.verified)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(MerchantDashboardEntity dashboard, bool isWholesaler, NumberFormat format) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            title: isWholesaler ? 'Détaillants' : 'Grossistes',
            value: '${dashboard.activeRelations}',
            subtitle: 'Actifs',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.pending,
            title: 'En attente',
            value: '${dashboard.pendingRelations}',
            subtitle: 'Demandes',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCard(MerchantDashboardEntity dashboard, NumberFormat format) {
    final isWholesaler = dashboard.profile.merchantType == MerchantType.wholesaler;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(isWholesaler ? 'Crédit Accordé' : 'Crédit Disponible', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: AppTextStyles.caption),
                  Text(format.format(dashboard.totalCreditGiven), style: AppTextStyles.h2),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Utilisé', style: AppTextStyles.caption),
                  Text(
                    format.format(dashboard.totalCreditUsed),
                    style: AppTextStyles.h3.copyWith(color: AppColors.warning),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: (dashboard.creditUsagePercent / 100).clamp(0, 1),
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(
              dashboard.creditUsagePercent > 80 ? AppColors.error : AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Disponible: ${format.format(dashboard.availableCredit)}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isWholesaler) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions rapides', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.people,
                label: isWholesaler ? 'Mes détaillants' : 'Mes grossistes',
                onTap: () => context.push('/merchant/relations'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (isWholesaler)
              Expanded(
                child: _ActionButton(
                  icon: Icons.person_add,
                  label: 'Ajouter détaillant',
                  onTap: () => context.push('/merchant/add-retailer'),
                ),
              )
            else
              Expanded(
                child: _ActionButton(
                  icon: Icons.search,
                  label: 'Trouver grossiste',
                  onTap: () => context.push('/merchant/wholesalers'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTextStyles.h2),
          Text(subtitle, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
