import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../merchant/presentation/providers/merchant_provider.dart';
import '../providers/product_management_provider.dart';
import '../../domain/entities/product.dart';

class StockManagementScreen extends ConsumerStatefulWidget {
  const StockManagementScreen({super.key});

  @override
  ConsumerState<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends ConsumerState<StockManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadData() async {
    final notifier = ref.read(productManagementProvider.notifier);
    await notifier.loadMyProducts();
    await notifier.loadLowStockProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchantProfile = ref.watch(merchantProfileProvider);
    final state = ref.watch(productManagementProvider);

    if (merchantProfile.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Gestion du stock'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (merchantProfile.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Gestion du stock'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Erreur: ${merchantProfile.error}', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(merchantProfileProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized && merchantProfile.hasValue) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }

    ref.listen<ProductManagementState>(productManagementProvider, (_, state) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
        );
        ref.read(productManagementProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion du stock'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 8),
                  Text('Stock bas (${state.lowStockProducts.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2, size: 18),
                  const SizedBox(width: 8),
                  Text('Tous (${state.products.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLowStockTab(state),
          _buildAllProductsTab(state),
        ],
      ),
    );
  }

  Widget _buildLowStockTab(ProductManagementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.lowStockProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: AppColors.success.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.lg),
            Text('Aucune alerte de stock', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tous vos produits ont un stock suffisant',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.lowStockProducts.length,
        itemBuilder: (context, index) => _StockCard(
          product: state.lowStockProducts[index],
          isLowStock: true,
          onUpdate: (quantity) => _updateStock(state.lowStockProducts[index], quantity),
        ),
      ),
    );
  }

  Widget _buildAllProductsTab(ProductManagementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.lg),
            Text('Aucun produit', style: AppTextStyles.h3),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.products.length,
        itemBuilder: (context, index) => _StockCard(
          product: state.products[index],
          isLowStock: state.products[index].lowStock,
          onUpdate: (quantity) => _updateStock(state.products[index], quantity),
        ),
      ),
    );
  }

  void _updateStock(Product product, int quantity) async {
    await ref.read(productManagementProvider.notifier).updateStock(product.id, quantity);
  }
}

class _StockCard extends StatefulWidget {
  final Product product;
  final bool isLowStock;
  final Function(int) onUpdate;

  const _StockCard({
    required this.product,
    required this.isLowStock,
    required this.onUpdate,
  });

  @override
  State<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<_StockCard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.product.stockQuantity.toString());
  }

  @override
  void didUpdateWidget(covariant _StockCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.stockQuantity != widget.product.stockQuantity) {
      _controller.text = widget.product.stockQuantity.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: widget.isLowStock ? AppColors.warning.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.isLowStock
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              widget.isLowStock ? Icons.warning_amber : Icons.inventory_2,
              color: widget.isLowStock ? AppColors.warning : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.product.unitPrice.toStringAsFixed(0)} XOF / ${widget.product.unitName}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (_isEditing)
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.success),
                  onPressed: () {
                    final quantity = int.tryParse(_controller.text);
                    if (quantity != null) {
                      widget.onUpdate(quantity);
                      setState(() => _isEditing = false);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () {
                    _controller.text = widget.product.stockQuantity.toString();
                    setState(() => _isEditing = false);
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: widget.isLowStock
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    '${widget.product.stockQuantity}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isLowStock ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () => setState(() => _isEditing = true),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
