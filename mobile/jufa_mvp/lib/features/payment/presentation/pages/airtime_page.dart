import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class AirtimePage extends StatefulWidget {
  const AirtimePage({super.key});

  @override
  State<AirtimePage> createState() => _AirtimePageState();
}

class _AirtimePageState extends State<AirtimePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _phoneController.text = '+223 ';
    _phoneController.addListener(_formatPhoneNumber);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.removeListener(_formatPhoneNumber);
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _formatPhoneNumber() {
    final text = _phoneController.text;
    if (text.length < 5) {
      if (!text.startsWith('+223 ')) {
        _phoneController.value = const TextEditingValue(
          text: '+223 ',
          selection: TextSelection.collapsed(offset: 5),
        );
      }
      return;
    }

    // Extraire uniquement les chiffres après +223
    final digitsOnly = text.substring(5).replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length > 8) {
      final truncated = digitsOnly.substring(0, 8);
      final formatted = '+223 ${truncated.substring(0, 2)} ${truncated.substring(2, 4)} ${truncated.substring(4, 6)} ${truncated.substring(6, 8)}';
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      return;
    }

    // Formater le numéro
    String formatted = '+223 ';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 2 == 0) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    if (formatted != text) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _handlePurchase() async {
    final operator = _tabController.index == 0 ? 'Orange Mali' : 'Moov Africa Malitel';
    
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Crédit $operator acheté avec succès'),
        backgroundColor: AppColors.success,
      ),
    );
    
    _phoneController.text = '+223 ';
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recharger du crédit'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Sélecteur d'opérateur avec cercles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOperatorCircle(
                color: AppColors.orangeMali,
                label: 'Orange',
                isSelected: _tabController.index == 0,
                onTap: () {
                  setState(() {
                    _tabController.index = 0;
                  });
                },
              ),
              const SizedBox(width: 32),
              _buildOperatorCircle(
                color: AppColors.moov,
                label: 'Moov',
                isSelected: _tabController.index == 1,
                onTap: () {
                  setState(() {
                    _tabController.index = 1;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Formulaire
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOperatorForm(AppColors.orangeMali, 'Orange Mali'),
                _buildOperatorForm(AppColors.moov, 'Moov Malitel'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorCircle({
    required Color color,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : color.withOpacity(0.2),
              border: Border.all(
                color: color,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Icon(
              Icons.phone_android,
              color: isSelected ? Colors.white : color,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorForm(Color color, String operatorName) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '+223 XX XX XX XX',
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('🇲🇱', style: TextStyle(fontSize: 24)),
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant',
              hintText: 'Ex: 1000',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
              suffixText: 'FCFA',
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [500, 1000, 2500, 5000, 10000].map((amount) {
              return ActionChip(
                label: Text('$amount F'),
                backgroundColor: color.withOpacity(0.1),
                onPressed: () {
                  _amountController.text = amount.toString();
                },
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePurchase,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: color,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Recharger', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
