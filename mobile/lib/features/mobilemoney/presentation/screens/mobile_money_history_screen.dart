import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/mobile_money_entity.dart';
import '../providers/mobile_money_provider.dart';

class MobileMoneyHistoryScreen extends ConsumerStatefulWidget {
  const MobileMoneyHistoryScreen({super.key});

  @override
  ConsumerState<MobileMoneyHistoryScreen> createState() => _MobileMoneyHistoryScreenState();
}

class _MobileMoneyHistoryScreenState extends ConsumerState<MobileMoneyHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(mobileMoneyNotifierProvider.notifier).loadOperations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileMoneyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique Mobile Money'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tout'),
            Tab(text: 'Dépôts'),
            Tab(text: 'Retraits'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(mobileMoneyNotifierProvider.notifier).loadOperations(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOperationList(state.operations),
            _buildOperationList(
              state.operations.where((op) => op.isDeposit).toList(),
            ),
            _buildOperationList(
              state.operations.where((op) => op.isWithdrawal).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationList(List<MobileMoneyOperationEntity> operations) {
    final state = ref.watch(mobileMoneyNotifierProvider);

    if (state.isLoading && operations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (operations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucune opération',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: operations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return _OperationCard(operation: operations[index]);
      },
    );
  }
}

class _OperationCard extends StatelessWidget {
  final MobileMoneyOperationEntity operation;

  const _OperationCard({required this.operation});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(_getIcon(), color: _getIconColor()),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      operation.operationType.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${operation.isDeposit ? '+' : '-'}${currencyFormat.format(operation.amount)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: operation.isDeposit ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      operation.provider.displayName,
                      style: AppTextStyles.caption,
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dateFormat.format(operation.createdAt),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    if (operation.isDeposit) {
      return Icons.arrow_downward;
    } else {
      return Icons.arrow_upward;
    }
  }

  Color _getIconColor() {
    switch (operation.status) {
      case MobileMoneyOperationStatus.completed:
        return operation.isDeposit ? AppColors.success : AppColors.primary;
      case MobileMoneyOperationStatus.failed:
      case MobileMoneyOperationStatus.cancelled:
      case MobileMoneyOperationStatus.expired:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;

    switch (operation.status) {
      case MobileMoneyOperationStatus.completed:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case MobileMoneyOperationStatus.failed:
      case MobileMoneyOperationStatus.cancelled:
      case MobileMoneyOperationStatus.expired:
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
      default:
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        operation.status.displayName,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
