import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/services/airtime_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/l10n/app_localizations.dart';

class AirtimePage extends StatefulWidget {
  const AirtimePage({super.key});

  @override
  State<AirtimePage> createState() => _AirtimePageState();
}

class _AirtimePageState extends State<AirtimePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  
  final AirtimeService _airtimeService = AirtimeService();
  final WalletService _walletService = WalletService();
  
  bool _isLoading = false;
  double _availableBalance = 0.0;
  String _selectedOperator = 'orange';
  bool _isMyNumber = true;
  String? _userPhone;

  final List<Map<String, dynamic>> _operators = [
    {
      'id': 'orange',
      'name': 'Orange Ml',
      'color': Color(0xFFFF6600),
      'icon': Icons.phone_android,
    },
    {
      'id': 'moov',
      'name': 'Moov Africa',
      'color': Color(0xFF0066CC),
      'icon': Icons.smartphone,
    },
  ];

  final List<int> _quickAmounts = [500, 1000, 2000, 5000, 10000, 20000];

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadUserPhone();
    _phoneController.text = '+223 ';
    
    _amountController.addListener(() {
      setState(() {});
    });
    
    // Formater le numéro pendant la saisie
    _phoneController.addListener(_formatPhoneNumber);
  }
  
  void _formatPhoneNumber() {
    final text = _phoneController.text;
    final cursorPosition = _phoneController.selection.base.offset;
    
    // Retirer tous les espaces sauf après +223
    String cleaned = text.replaceAll(' ', '');
    
    // S'assurer que ça commence par +223
    if (!cleaned.startsWith('+223')) {
      cleaned = '+223';
    }
    
    // Extraire les chiffres après +223
    String digits = cleaned.substring(4);
    
    // Formater: +223 XX XX XX XX
    String formatted = '+223';
    if (digits.isNotEmpty) {
      formatted += ' ';
      for (int i = 0; i < digits.length && i < 8; i++) {
        if (i > 0 && i % 2 == 0) {
          formatted += ' ';
        }
        formatted += digits[i];
      }
    }
    
    // Mettre à jour seulement si différent pour éviter les boucles
    if (formatted != text) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_formatPhoneNumber);
    _phoneController.dispose();
    _amountController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    try {
      final balance = await _walletService.getBalance();
      setState(() => _availableBalance = balance);
    } catch (e) {
      print('❌ Erreur chargement solde: $e');
    }
  }

  Future<void> _loadUserPhone() async {
    try {
      final phone = await UserService.getPhone();
      setState(() {
        _userPhone = phone;
        if (_isMyNumber && _userPhone != null && _userPhone!.isNotEmpty) {
          _phoneController.text = _userPhone!;
        }
      });
    } catch (e) {
      print('❌ Erreur chargement téléphone: $e');
    }
  }

  void _toggleRecipient(bool isMyNumber) {
    setState(() {
      _isMyNumber = isMyNumber;
      if (isMyNumber && _userPhone != null) {
        _phoneController.text = _userPhone!;
      } else {
        _phoneController.text = '+223 ';
      }
    });
  }

  Future<void> _processRecharge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final phoneNumber = _phoneController.text.replaceAll(' ', '');

      final result = await _airtimeService.rechargeAirtime(
        phoneNumber: phoneNumber,
        amount: amount,
        operator: _selectedOperator,
      );

      if (!mounted) return;

      _showSuccessDialog(
        phoneNumber: phoneNumber,
        amount: amount,
        operator: _selectedOperator,
        transactionId: result['transaction_id'],
      );

      _amountController.clear();
      await _loadBalance();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog({
    required String phoneNumber,
    required double amount,
    required String operator,
    required String transactionId,
  }) {
    final l10n = AppLocalizations.of(context);
    final operatorData = _operators.firstWhere((op) => op['id'] == operator);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('recharge_successful'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.translate('operator'), style: TextStyle(color: Colors.grey.shade600)),
                        Row(
                          children: [
                            Icon(operatorData['icon'], color: operatorData['color'], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              operatorData['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.translate('number'), style: TextStyle(color: Colors.grey.shade600)),
                        Text(phoneNumber, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.translate('amount_label'), style: TextStyle(color: Colors.grey.shade600)),
                        Text(
                          Formatters.formatCurrency(amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.translate('transaction'), style: TextStyle(color: Colors.grey.shade600)),
                        Text(transactionId, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: l10n.translate('finish'),
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.translate('airtime_recharge')),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // Toggle Mon numéro / Autre numéro
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleRecipient(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isMyNumber ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.translate('my_number'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isMyNumber ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleRecipient(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isMyNumber ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.translate('other_number'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isMyNumber ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sélection opérateur
            Text(
              l10n.translate('operator'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _operators.map((operator) {
                final isSelected = _selectedOperator == operator['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedOperator = operator['id']),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? operator['color'].withOpacity(0.1) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? operator['color'] : Colors.grey.shade300,
                              width: isSelected ? 3 : 2,
                            ),
                          ),
                          child: Icon(
                            operator['icon'],
                            color: operator['color'],
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          operator['name'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? operator['color'] : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Numéro de téléphone avec drapeau
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('phone_number'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Drapeau du Mali
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '🇲🇱',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      // Champ de saisie
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          enabled: !_isMyNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: '+223 XX XX XX XX',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.translate('phone_required');
                            }
                            final cleaned = value.replaceAll(' ', '');
                            if (cleaned.length < 12) {
                              return l10n.translate('invalid_number');
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Montant
            CustomTextField(
              controller: _amountController,
              label: l10n.translate('amount'),
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.translate('amount_required');
                }
                final amount = double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount < 100) {
                  return l10n.translate('minimum_amount');
                }
                if (amount > _availableBalance) {
                  return l10n.translate('insufficient_balance');
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Montants rapides
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return GestureDetector(
                  onTap: () => _amountController.text = amount.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      Formatters.formatCurrency(amount.toDouble()),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Résumé
            if (_amountController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('summary'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.translate('amount_label'), style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          Formatters.formatCurrency(
                            double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0,
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.translate('fees'), style: TextStyle(color: AppColors.textSecondary)),
                        Text('0 CFA', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.translate('total'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(
                            double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Bouton de recharge
            CustomButton(
              text: l10n.translate('recharge'),
              onPressed: _isLoading ? null : _processRecharge,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 16),

            // Note d'information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.translate('simulation_note'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
