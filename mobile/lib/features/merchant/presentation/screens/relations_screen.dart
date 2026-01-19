import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/merchant_entity.dart';
import '../providers/merchant_provider.dart';

class RelationsScreen extends ConsumerWidget {
  const RelationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(merchantProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Erreur: $error'))),
      data: (profile) {
        if (profile.merchantType == MerchantType.wholesaler) {
          return _WholesalerRelationsView(profile: profile);
        } else {
          return _RetailerRelationsView(profile: profile);
        }
      },
    );
  }
}

class _WholesalerRelationsView extends ConsumerWidget {
  final MerchantProfileEntity profile;

  const _WholesalerRelationsView({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retailersAsync = ref.watch(myRetailersProvider);
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Détaillants'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: retailersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
        data: (retailers) {
          if (retailers.isEmpty) {
            return _buildEmptyState(
              'Aucun détaillant',
              'Ajoutez des détaillants pour commencer à travailler avec eux.',
            );
          }

          final pending = retailers.where((r) => r.status == RelationStatus.pending).toList();
          final active = retailers.where((r) => r.status == RelationStatus.active).toList();
          final suspended = retailers.where((r) => r.status == RelationStatus.suspended).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myRetailersProvider),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (pending.isNotEmpty) ...[
                  _buildSectionHeader('En attente d\'approbation', pending.length),
                  ...pending.map((r) => _RelationCard(relation: r, currencyFormat: currencyFormat, isWholesaler: true)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (active.isNotEmpty) ...[
                  _buildSectionHeader('Actifs', active.length),
                  ...active.map((r) => _RelationCard(relation: r, currencyFormat: currencyFormat, isWholesaler: true)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (suspended.isNotEmpty) ...[
                  _buildSectionHeader('Suspendus', suspended.length),
                  ...suspended.map((r) => _RelationCard(relation: r, currencyFormat: currencyFormat, isWholesaler: true)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text('$count', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RetailerRelationsView extends ConsumerWidget {
  final MerchantProfileEntity profile;

  const _RetailerRelationsView({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wholesalersAsync = ref.watch(myWholesalersProvider);
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Grossistes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: wholesalersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
        data: (wholesalers) {
          if (wholesalers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 64, color: AppColors.textHint),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Aucun grossiste', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Attendez qu\'un grossiste vous ajoute à sa liste ou recherchez des grossistes.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final pending = wholesalers.where((r) => r.status == RelationStatus.pending).toList();
          final active = wholesalers.where((r) => r.status == RelationStatus.active).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myWholesalersProvider),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (pending.isNotEmpty) ...[
                  _buildSectionHeader('En attente de votre approbation', pending.length),
                  ...pending.map((r) => _RelationCard(
                    relation: r,
                    currencyFormat: currencyFormat,
                    isWholesaler: false,
                    showApproveButton: true,
                  )),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (active.isNotEmpty) ...[
                  _buildSectionHeader('Mes grossistes', active.length),
                  ...active.map((r) => _RelationCard(relation: r, currencyFormat: currencyFormat, isWholesaler: false)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.h3)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text('$count', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _RelationCard extends ConsumerWidget {
  final RetailerRelationEntity relation;
  final NumberFormat currencyFormat;
  final bool isWholesaler;
  final bool showApproveButton;

  const _RelationCard({
    required this.relation,
    required this.currencyFormat,
    required this.isWholesaler,
    this.showApproveButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = isWholesaler ? relation.retailer : relation.wholesaler;
    final statusColor = _getStatusColor(relation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(partner.initials, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(partner.businessName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(partner.phone, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(relation.statusLabel, style: AppTextStyles.caption.copyWith(color: statusColor)),
              ),
            ],
          ),
          if (relation.status == RelationStatus.active) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoColumn('Crédit', currencyFormat.format(relation.creditLimit)),
                _InfoColumn('Utilisé', currencyFormat.format(relation.creditUsed)),
                _InfoColumn('Disponible', currencyFormat.format(relation.availableCredit)),
              ],
            ),
            if (relation.creditLimit > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: (relation.creditUsagePercent / 100).clamp(0, 1),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  relation.creditUsagePercent > 80 ? AppColors.error : AppColors.success,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ],
          ],
          if (showApproveButton && relation.status == RelationStatus.pending) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, ref),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approve(ref),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Accepter', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(RelationStatus status) {
    switch (status) {
      case RelationStatus.pending:
        return AppColors.warning;
      case RelationStatus.active:
        return AppColors.success;
      case RelationStatus.suspended:
        return AppColors.error;
    }
  }

  void _approve(WidgetRef ref) {
    ref.read(merchantActionNotifierProvider.notifier).approveRelation(relation.id);
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser cette demande?'),
        content: const Text('Vous pouvez toujours accepter une nouvelle demande du même grossiste plus tard.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(merchantActionNotifierProvider.notifier).suspendRelation(relation.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Refuser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
