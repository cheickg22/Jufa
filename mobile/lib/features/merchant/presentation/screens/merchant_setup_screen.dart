import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/merchant_entity.dart';
import '../providers/merchant_provider.dart';

class MerchantSetupScreen extends ConsumerStatefulWidget {
  const MerchantSetupScreen({super.key});

  @override
  ConsumerState<MerchantSetupScreen> createState() => _MerchantSetupScreenState();
}

class _MerchantSetupScreenState extends ConsumerState<MerchantSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  MerchantType _selectedType = MerchantType.retailer;
  final _businessNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _rccmController = TextEditingController();
  final _nifController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _categoryController.dispose();
    _rccmController.dispose();
    _nifController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(merchantActionNotifierProvider);

    ref.listen<MerchantActionState>(merchantActionNotifierProvider, (_, state) {
      if (state.success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil commerçant créé!'), backgroundColor: AppColors.success),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer mon profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type de commerçant', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.warehouse,
                      title: 'Grossiste',
                      subtitle: 'Je vends en gros',
                      isSelected: _selectedType == MerchantType.wholesaler,
                      onTap: () => setState(() => _selectedType = MerchantType.wholesaler),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.store,
                      title: 'Détaillant',
                      subtitle: 'Je vends au détail',
                      isSelected: _selectedType == MerchantType.retailer,
                      onTap: () => setState(() => _selectedType = MerchantType.retailer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Informations de l\'entreprise', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _businessNameController,
                decoration: _inputDecoration('Nom de l\'entreprise *', Icons.business),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _categoryController,
                decoration: _inputDecoration('Catégorie (ex: Alimentation)', Icons.category),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _rccmController,
                decoration: _inputDecoration('Numéro RCCM', Icons.description),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nifController,
                decoration: _inputDecoration('Numéro NIF', Icons.numbers),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Localisation', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration('Ville', Icons.location_city),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration('Adresse complète', Icons.location_on),
                maxLines: 2,
              ),
              if (actionState.error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(actionState.error!, style: TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: actionState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: actionState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Créer mon profil', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      filled: true,
      fillColor: AppColors.surface,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(merchantActionNotifierProvider.notifier).createProfile(
          merchantType: _selectedType,
          businessName: _businessNameController.text.trim(),
          businessCategory: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
          rccmNumber: _rccmController.text.trim().isNotEmpty ? _rccmController.text.trim() : null,
          nifNumber: _nifController.text.trim().isNotEmpty ? _nifController.text.trim() : null,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
