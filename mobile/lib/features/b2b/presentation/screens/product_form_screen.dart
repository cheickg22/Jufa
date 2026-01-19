import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/jufa_widgets.dart';
import '../providers/product_management_provider.dart';
import '../../domain/entities/product_unit.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  
  const ProductFormScreen({super.key, this.productId});

  bool get isEditing => productId != null && productId != 'new';

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minOrderController = TextEditingController(text: '1');
  
  String? _selectedCategoryId;
  ProductUnit _selectedUnit = ProductUnit.piece;
  bool _featured = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    ref.read(productManagementProvider.notifier).loadCategories();
    if (widget.isEditing) {
      _loadProduct();
    }
  }

  void _loadProduct() {
    final products = ref.read(productManagementProvider).products;
    final product = products.where((p) => p.id == widget.productId).firstOrNull;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _unitPriceController.text = product.unitPrice.toStringAsFixed(0);
      _wholesalePriceController.text = product.wholesalePrice?.toStringAsFixed(0) ?? '';
      _stockController.text = product.stockQuantity.toString();
      _minOrderController.text = product.minOrderQuantity.toString();
      _selectedCategoryId = product.categoryId;
      _selectedUnit = product.unit;
      _featured = product.featured;
      _active = product.active;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitPriceController.dispose();
    _wholesalePriceController.dispose();
    _stockController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productManagementProvider);

    ref.listen<ProductManagementState>(productManagementProvider, (_, state) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
        );
        ref.read(productManagementProvider.notifier).clearMessages();
        context.pop();
      }
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
        );
        ref.read(productManagementProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Modifier le produit' : 'Nouveau produit'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Informations générales', [
                JufaTextField(
                  controller: _nameController,
                  label: 'Nom du produit *',
                  validator: (v) => v?.isEmpty == true ? 'Champ requis' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                JufaTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildCategoryDropdown(state),
              ]),
              const SizedBox(height: AppSpacing.xl),
              _buildSection('Prix et unité', [
                Row(
                  children: [
                    Expanded(
                      child: JufaTextField(
                        controller: _unitPriceController,
                        label: 'Prix unitaire (XOF) *',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Champ requis';
                          if (double.tryParse(v!) == null) return 'Prix invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: JufaTextField(
                        controller: _wholesalePriceController,
                        label: 'Prix de gros (XOF)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildUnitDropdown(),
              ]),
              const SizedBox(height: AppSpacing.xl),
              _buildSection('Stock et commande', [
                Row(
                  children: [
                    Expanded(
                      child: JufaTextField(
                        controller: _stockController,
                        label: 'Stock initial',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: JufaTextField(
                        controller: _minOrderController,
                        label: 'Commande minimum',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              _buildSection('Options', [
                SwitchListTile(
                  title: const Text('Produit en vedette'),
                  subtitle: const Text('Afficher dans les recommandations'),
                  value: _featured,
                  onChanged: (v) => setState(() => _featured = v),
                  activeColor: AppColors.primary,
                ),
                if (widget.isEditing)
                  SwitchListTile(
                    title: const Text('Produit actif'),
                    subtitle: const Text('Visible dans le catalogue'),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                    activeColor: AppColors.primary,
                  ),
              ]),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.isEditing ? 'Enregistrer les modifications' : 'Créer le produit',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(ProductManagementState state) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Sans catégorie')),
        ...state.categories.map((cat) => DropdownMenuItem(
              value: cat.id,
              child: Text(cat.name),
            )),
      ],
      onChanged: (value) => setState(() => _selectedCategoryId = value),
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<ProductUnit>(
      value: _selectedUnit,
      decoration: InputDecoration(
        labelText: 'Unité de vente',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      items: ProductUnit.values.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text(_getUnitLabel(unit)),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedUnit = value!),
    );
  }

  String _getUnitLabel(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.piece:
        return 'Pièce';
      case ProductUnit.kg:
        return 'Kilogramme (kg)';
      case ProductUnit.litre:
        return 'Litre (L)';
      case ProductUnit.box:
        return 'Boîte';
      case ProductUnit.carton:
        return 'Carton';
      case ProductUnit.pack:
        return 'Pack';
      case ProductUnit.sack:
        return 'Sac';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(productManagementProvider.notifier);
    
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final unitPrice = double.parse(_unitPriceController.text);
    final wholesalePrice = double.tryParse(_wholesalePriceController.text);
    final stock = int.tryParse(_stockController.text) ?? 0;
    final minOrder = int.tryParse(_minOrderController.text) ?? 1;

    if (widget.isEditing) {
      await notifier.updateProduct(
        productId: widget.productId!,
        name: name,
        description: description.isEmpty ? null : description,
        categoryId: _selectedCategoryId,
        unit: _selectedUnit.name.toUpperCase(),
        unitPrice: unitPrice,
        wholesalePrice: wholesalePrice,
        stockQuantity: stock,
        minOrderQuantity: minOrder,
        active: _active,
        featured: _featured,
      );
    } else {
      await notifier.createProduct(
        name: name,
        description: description.isEmpty ? null : description,
        categoryId: _selectedCategoryId,
        unit: _selectedUnit.name.toUpperCase(),
        unitPrice: unitPrice,
        wholesalePrice: wholesalePrice,
        stockQuantity: stock,
        minOrderQuantity: minOrder,
        featured: _featured,
      );
    }
  }
}
