import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';

class RetailerStockItem {
  final String id;
  final String name;
  final String? category;
  final int quantity;
  final int minStock;
  final double unitPrice;
  final double? purchasePrice;

  RetailerStockItem({
    required this.id,
    required this.name,
    this.category,
    required this.quantity,
    required this.minStock,
    required this.unitPrice,
    this.purchasePrice,
  });

  bool get isLowStock => quantity <= minStock;
}

final retailerStockProvider = StateNotifierProvider<RetailerStockNotifier, RetailerStockState>((ref) {
  return RetailerStockNotifier();
});

class RetailerStockState {
  final List<RetailerStockItem> items;
  final bool isLoading;
  final String? error;

  RetailerStockState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  RetailerStockState copyWith({
    List<RetailerStockItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return RetailerStockState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalItems => items.length;
  int get lowStockCount => items.where((i) => i.isLowStock).length;
  double get totalValue => items.fold(0, (sum, i) => sum + (i.quantity * i.unitPrice));
}

class RetailerStockNotifier extends StateNotifier<RetailerStockState> {
  RetailerStockNotifier() : super(RetailerStockState()) {
    _loadSampleData();
  }

  void _loadSampleData() {
    state = state.copyWith(
      items: [
        RetailerStockItem(id: '1', name: 'Lait Gloria 400g', category: 'Alimentaire', quantity: 25, minStock: 10, unitPrice: 750),
        RetailerStockItem(id: '2', name: 'Sucre 1kg', category: 'Alimentaire', quantity: 8, minStock: 15, unitPrice: 800),
        RetailerStockItem(id: '3', name: 'Huile Dinor 1L', category: 'Alimentaire', quantity: 12, minStock: 10, unitPrice: 1500),
        RetailerStockItem(id: '4', name: 'Savon Omo 500g', category: 'Ménage', quantity: 30, minStock: 20, unitPrice: 1200),
        RetailerStockItem(id: '5', name: 'Eau Minérale 1.5L', category: 'Boissons', quantity: 5, minStock: 20, unitPrice: 500),
      ],
    );
  }

  void updateStock(String id, int newQuantity) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return RetailerStockItem(
            id: item.id,
            name: item.name,
            category: item.category,
            quantity: newQuantity,
            minStock: item.minStock,
            unitPrice: item.unitPrice,
            purchasePrice: item.purchasePrice,
          );
        }
        return item;
      }).toList(),
    );
  }

  void addItem(RetailerStockItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void removeItem(String id) {
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
  }
}

class RetailerStockScreen extends ConsumerStatefulWidget {
  const RetailerStockScreen({super.key});

  @override
  ConsumerState<RetailerStockScreen> createState() => _RetailerStockScreenState();
}

class _RetailerStockScreenState extends ConsumerState<RetailerStockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(retailerStockProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Stock'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Tout (${state.totalItems})'),
            Tab(text: 'Stock bas (${state.lowStockCount})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(state),
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStockList(state.items),
                _buildStockList(state.items.where((i) => i.isLowStock).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(RetailerStockState state) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${state.totalItems}',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              Text('Articles', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Column(
            children: [
              Text(
                '${state.lowStockCount}',
                style: AppTextStyles.h2.copyWith(color: state.lowStockCount > 0 ? AppColors.warning : Colors.white),
              ),
              Text('Stock bas', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Column(
            children: [
              Text(
                _formatCurrency(state.totalValue),
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              Text('Valeur', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Rechercher un article...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
        ),
      ),
    );
  }

  Widget _buildStockList(List<RetailerStockItem> items) {
    var filtered = items;
    if (_searchQuery.isNotEmpty) {
      filtered = items.where((i) => 
        i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (i.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),
            Text('Aucun article', style: AppTextStyles.h3),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _StockItemCard(
          item: item,
          onUpdateStock: (quantity) {
            ref.read(retailerStockProvider.notifier).updateStock(item.id, quantity);
          },
          onDelete: () {
            ref.read(retailerStockProvider.notifier).removeItem(item.id);
          },
        );
      },
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final minStockController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un article'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom de l\'article'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantité'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: minStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock min'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix unitaire (XOF)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0;
              final minStock = int.tryParse(minStockController.text) ?? 10;

              if (name.isNotEmpty && quantity > 0 && price > 0) {
                ref.read(retailerStockProvider.notifier).addItem(
                  RetailerStockItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    quantity: quantity,
                    minStock: minStock,
                    unitPrice: price,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _StockItemCard extends StatefulWidget {
  final RetailerStockItem item;
  final Function(int) onUpdateStock;
  final VoidCallback onDelete;

  const _StockItemCard({
    required this.item,
    required this.onUpdateStock,
    required this.onDelete,
  });

  @override
  State<_StockItemCard> createState() => _StockItemCardState();
}

class _StockItemCardState extends State<_StockItemCard> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant _StockItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity) {
      _controller.text = widget.item.quantity.toString();
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
          color: widget.item.isLowStock ? AppColors.warning.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.item.isLowStock 
                ? AppColors.warning.withValues(alpha: 0.2) 
                : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.inventory_2,
              color: widget.item.isLowStock ? AppColors.warning : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (widget.item.category != null)
                  Text(widget.item.category!, style: AppTextStyles.caption),
                Row(
                  children: [
                    Text(
                      '${widget.item.unitPrice.toStringAsFixed(0)} XOF',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                    if (widget.item.isLowStock) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Stock bas',
                          style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_isEditing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.success),
                  onPressed: () {
                    final newQuantity = int.tryParse(_controller.text);
                    if (newQuantity != null) {
                      widget.onUpdateStock(newQuantity);
                    }
                    setState(() => _isEditing = false);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () {
                    _controller.text = widget.item.quantity.toString();
                    setState(() => _isEditing = false);
                  },
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: widget.item.isLowStock 
                      ? AppColors.warning.withValues(alpha: 0.2)
                      : AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    '${widget.item.quantity}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.item.isLowStock ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => setState(() => _isEditing = true),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
