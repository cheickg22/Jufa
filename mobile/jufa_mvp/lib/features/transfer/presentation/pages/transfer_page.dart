import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/biometric_preferences.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  
  final TransactionService _transactionService = TransactionService();
  final WalletService _walletService = WalletService();
  
  bool _isLoading = false;
  String? _recipientName;
  double _availableBalance = 0.0;
  double _depositFeePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadFees();
    // Initialiser avec +223
    _recipientController.text = '+223 ';
    
    // Écouter les changements pour mettre à jour le résumé
    _amountController.addListener(() {
      setState(() {}); // Rafraîchir l'affichage
    });
    _recipientController.addListener(() {
      setState(() {}); // Rafraîchir l'affichage
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
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
  
  Future<void> _loadFees() async {
    try {
      final response = await _transactionService.getFees();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _depositFeePercentage = (response['data']['user_transfer_fee'] ?? 0).toDouble();
        });
        print('💰 Frais de transfert P2P: $_depositFeePercentage%');
      }
    } catch (e) {
      print('❌ Erreur chargement frais: $e');
    }
  }

  Future<void> _verifyRecipient() async {
    if (_recipientController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Nettoyer et formater l'identifiant
      var identifier = _recipientController.text.trim().replaceAll(' ', '');
      
      // Ajouter +223 si nécessaire
      if (!identifier.startsWith('+') && !identifier.startsWith('JF') && identifier.length >= 8) {
        identifier = '+223$identifier';
      }
      
      // Rechercher l'utilisateur
      final user = await _transactionService.searchUser(identifier);
      
      setState(() {
        if (user != null) {
          _recipientName = user['name'];
          print('✅ Utilisateur trouvé: ${user['name']}');
        } else {
          _recipientName = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur recherche utilisateur: $e');
      setState(() {
        _recipientName = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    
    final l10n = AppLocalizations.of(context);
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    // Nettoyer le destinataire : supprimer tous les espaces
    var recipient = _recipientController.text.trim().replaceAll(' ', '');
    
    // Ajouter +223 si c'est un numéro sans préfixe et ne commence pas par JF (wallet)
    if (!recipient.startsWith('+') && !recipient.startsWith('JF') && recipient.length >= 8) {
      recipient = '+223$recipient';
    }
    
    print('🔍 Destinataire final: "$recipient"');
    
    if (amount > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('insufficient_balance')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Authentification avant le transfert
    final authenticated = await _authenticateUser();
    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('authentication_required')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Appel API pour effectuer le transfert
      final transaction = await _transactionService.createTransfer(
        receiverIdentifier: recipient,
        amount: amount,
      );
      
      print('✅ Transfert réussi: ${transaction['transaction_id']}');
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Recharger le solde
      await _loadBalance();
      
      // Afficher la confirmation
      _showSuccessDialog(amount);
    } catch (e) {
      print('❌ Erreur transfert: $e');
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool> _authenticateUser() async {
    try {
      print('🔐 Début authentification...');
      
      // Vérifier si la biométrie est activée
      final isBiometricEnabled = await BiometricPreferences.isBiometricEnabled();
      print('🔐 Biométrie activée: $isBiometricEnabled');
      
      if (isBiometricEnabled) {
        // Authentification biométrique
        final localAuth = LocalAuthentication();
        final biometricService = BiometricService(localAuth);
        final l10n = AppLocalizations.of(context);
        final authenticated = await biometricService.authenticate(
          localizedReason: l10n.translate('authenticate_transfer'),
        );
        print('🔐 Résultat biométrie: $authenticated');
        return authenticated;
      } else {
        // Authentification par code PIN
        print('🔐 Demande de code PIN...');
        final result = await _showPinDialog();
        print('🔐 Résultat PIN: $result');
        return result;
      }
    } catch (e) {
      print('❌ Erreur authentification: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('authentication_error')}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> _showPinDialog() async {
    final l10n = AppLocalizations.of(context);
    final pinController = TextEditingController();
    
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.translate('pin_code')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.translate('enter_pin_confirm'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.translate('pin_code'),
                  border: OutlineInputBorder(),
                  counterText: '',
                  hintText: '****',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: pinController.text.length == 4
                  ? () {
                      Navigator.pop(dialogContext, true);
                    }
                  : null,
              child: Text(l10n.translate('confirm')),
            ),
          ],
        ),
      ),
    );
    
    return result ?? false;
  }

  void _showSuccessDialog(double amount) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final transactionId = 'TXN${now.millisecondsSinceEpoch}';
    final fees = (amount * _depositFeePercentage / 100);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge de succès bleu
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blue.shade600,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Transfert réussi
                Text(
                  l10n.translate('transfer_successful'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                
                // Date, heure et ID sur une seule ligne
                Text(
                  '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)}, ${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} | $transactionId',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Cadre avec Montant principal, Montant et Frais
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade600, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Montant principal en grand
                      Text(
                        Formatters.formatCurrency(amount),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Ligne de séparation bleue
                      Container(
                        width: double.infinity,
                        height: 1.5,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.translate('amount_label'),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(amount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.translate('fees'),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(fees),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Cadre De et À fusionnés
                FutureBuilder<String>(
                  future: UserService.getPhone(),
                  builder: (context, snapshot) {
                    final userPhone = snapshot.data ?? '+223 XX XX XX XX';
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // De
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.translate('from'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                l10n.translate('sender'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.translate('number'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                userPhone,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Ligne de séparation
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: AppColors.border,
                          ),
                          const SizedBox(height: 12),
                          
                          // À
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.translate('to'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  _recipientName ?? l10n.translate('recipient_label'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.translate('number'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _recipientController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Bouton
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop(); // Fermer le dialog
                      context.pop(); // Retourner au dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.translate('done')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    final l10n = AppLocalizations.of(context);
    final months = l10n.translate('months').split(',');
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('send_money')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Solde disponible
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.translate('available_balance'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(_availableBalance),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Destinataire
            CustomTextField(
              controller: _recipientController,
              label: l10n.translate('recipient'),
              hint: l10n.translate('recipient_hint'),
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                _PhoneNumberFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.translate('enter_number');
                }
                final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (digitsOnly.length < 11) {
                  return l10n.translate('incomplete_number');
                }
                return null;
              },
              onChanged: (value) {
                final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (digitsOnly.length >= 11) {
                  _verifyRecipient();
                } else {
                  setState(() => _recipientName = null);
                }
              },
              suffixIcon: _recipientName != null
                  ? Icon(Icons.check_circle, color: AppColors.success)
                  : null,
            ),
            
            if (_recipientName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _recipientName!,
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Montant
            CustomTextField(
              controller: _amountController,
              label: l10n.translate('amount'),
              hint: l10n.translate('enter_amount'),
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validateAmount(
                value,
                maxAmount: _availableBalance,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Montants rapides
            Wrap(
              spacing: 8,
              children: [1000, 5000, 10000, 25000, 50000].map((amount) {
                return ActionChip(
                  label: Text(Formatters.formatCurrency(amount.toDouble())),
                  onPressed: () {
                    _amountController.text = amount.toString();
                  },
                  backgroundColor: AppColors.inputBackground,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Résumé
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('transaction_summary'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    l10n.translate('recipient'),
                    _recipientName ?? (_recipientController.text.isEmpty ? l10n.translate('not_provided') : _recipientController.text),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(l10n.translate('amount_label'), _amountController.text.isEmpty
                      ? '0 CFA'
                      : Formatters.formatCurrency(
                          double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0)),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    '${l10n.translate('fees')} ($_depositFeePercentage%)',
                    _amountController.text.isEmpty
                        ? '0 CFA'
                        : Formatters.formatCurrency(
                            (double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0) * (_depositFeePercentage / 100)),
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    l10n.translate('total'),
                    _amountController.text.isEmpty
                        ? '0 CFA'
                        : Formatters.formatCurrency(
                            (double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0) * (1 + _depositFeePercentage / 100)),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Bouton d'envoi
            CustomButton(
              text: l10n.translate('send'),
              icon: Icons.send,
              onPressed: _handleTransfer,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Formatter pour le numéro de téléphone
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Si l'utilisateur efface tout, remettre +223
    if (text.isEmpty) {
      return const TextEditingValue(
        text: '+223 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }
    
    // Empêcher de supprimer +223
    if (!text.startsWith('+223')) {
      return oldValue;
    }
    
    // Extraire uniquement les chiffres après +223
    final digitsOnly = text.substring(4).replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limiter à 8 chiffres
    final limitedDigits = digitsOnly.length > 8 ? digitsOnly.substring(0, 8) : digitsOnly;
    
    // Formater: +223 XX XX XX XX
    String formatted = '+223';
    if (limitedDigits.isNotEmpty) {
      formatted += ' ';
      for (int i = 0; i < limitedDigits.length; i++) {
        if (i > 0 && i % 2 == 0) {
          formatted += ' ';
        }
        formatted += limitedDigits[i];
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
