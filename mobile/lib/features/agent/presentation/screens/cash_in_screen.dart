import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/agent_provider.dart';

class CashInScreen extends ConsumerStatefulWidget {
  const CashInScreen({super.key});

  @override
  ConsumerState<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends ConsumerState<CashInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+223 ');
  final _amountController = TextEditingController();
  final currencyFormat = NumberFormat('#,###', 'fr_FR');

  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _usePhoneInput = false;
  String? _scannedPhone;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '${currencyFormat.format(amount).replaceAll(',', ' ')} FCFA';
  }

  void _onQrCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      setState(() {
        _scannedPhone = code;
        _isScanning = false;
      });
      _searchClient(code);
    }
  }

  void _onPhoneChanged(String value) {
    final cleanedPhone = value.replaceAll(' ', '').replaceAll('+', '');
    if (cleanedPhone.length == 11 && cleanedPhone.startsWith('223')) {
      _searchClient('+$cleanedPhone');
    }
  }

  Future<void> _searchClient(String phone) async {
    final cleanPhone = phone.replaceAll(' ', '');
    final success = await ref.read(agentNotifierProvider.notifier).searchClient(cleanPhone);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Client non trouvé'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool> _showPinConfirmationDialog() async {
    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez votre code PIN pour confirmer cette opération',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Code PIN',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                counterText: '',
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Le code PIN doit contenir 4 chiffres'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              final success = await ref.read(agentNotifierProvider.notifier).verifySecretCode(pinController.text);
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Code PIN incorrect'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _handleDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(agentNotifierProvider);
    final client = state.currentClient;
    if (client == null && _scannedPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez scanner le QR code ou entrer le numéro du client'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final pinConfirmed = await _showPinConfirmationDialog();
    if (!pinConfirmed) return;

    final amount = double.parse(_amountController.text.replaceAll(' ', ''));
    final customerPhone = client?.phone ?? _scannedPhone!;

    final success = await ref.read(agentNotifierProvider.notifier).processCashIn(
          customerPhone: customerPhone,
          amount: amount,
        );

    if (success && mounted) {
      _showSuccessDialog(amount, customerPhone);
    }
  }

  void _showSuccessDialog(double amount, String customerPhone) {
    final now = DateTime.now();
    final state = ref.read(agentNotifierProvider);
    final transaction = state.lastTransaction;
    final client = state.currentClient;

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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dépôt réussi',
                  style: AppTextStyles.h2.copyWith(color: AppColors.success),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)}, ${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                if (transaction?.reference != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      transaction!.reference,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.success, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatCurrency(amount),
                        style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (transaction != null) ...[
                        const SizedBox(height: 12),
                        Divider(color: AppColors.success),
                        const SizedBox(height: 12),
                        _buildInfoRow('Frais', _formatCurrency(transaction.fee)),
                        const SizedBox(height: 8),
                        _buildInfoRow('Commission', _formatCurrency(transaction.agentCommission)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('De', 'Agent'),
                      const SizedBox(height: 8),
                      _buildInfoRow('À', client?.name ?? 'Client'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Numéro', customerPhone),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Terminer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetForm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Nouveau dépôt'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _resetForm() {
    ref.read(agentNotifierProvider.notifier).clearClient();
    ref.read(agentNotifierProvider.notifier).clearFees();
    ref.read(agentNotifierProvider.notifier).clearLastTransaction();
    setState(() {
      _scannedPhone = null;
      _isScanning = true;
      _usePhoneInput = false;
      _phoneController.text = '+223 ';
      _amountController.clear();
    });
    _scannerController?.start();
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentNotifierProvider);
    final client = state.currentClient;

    ref.listen<AgentState>(agentNotifierProvider, (previous, next) {
      if (next.error != null && previous?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        title: const Text('Dépôt Client'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isScanning) _buildQrScanner(),
            if (_usePhoneInput) _buildPhoneInput(state.isSearchingClient),
            if (!_isScanning && !_usePhoneInput && client != null) _buildClientFound(client),
            if (!_isScanning && !_usePhoneInput && client == null && _scannedPhone == null) _buildClientNotFound(),
            _buildAmountForm(state),
          ],
        ),
      ),
    );
  }

  Widget _buildQrScanner() {
    return Container(
      height: 350,
      color: Colors.black,
      child: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onQrCodeDetected,
          ),
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.success, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Scannez le QR code du client',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isScanning = false;
                    _usePhoneInput = true;
                  });
                  _scannerController?.stop();
                },
                icon: const Text('ML', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                label: const Text('Saisir le numéro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(bool isSearching) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.success.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('ML', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Numéro du client',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: AppColors.success),
                onPressed: () {
                  setState(() {
                    _usePhoneInput = false;
                    _isScanning = true;
                  });
                  _scannerController?.start();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: _onPhoneChanged,
            decoration: InputDecoration(
              labelText: 'Téléphone',
              hintText: '+223 XX XX XX XX',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('ML', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              suffixIcon: isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.success, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Entrez le numéro complet pour rechercher automatiquement',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClientFound(dynamic client) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.success.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client trouvé',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(client.name ?? 'Client', style: AppTextStyles.bodyMedium),
                Text(client.phone ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _resetForm,
          ),
        ],
      ),
    );
  }

  Widget _buildClientNotFound() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.warning, color: AppColors.warning, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aucun client sélectionné',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isScanning = true;
              });
              _scannerController?.start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Scanner'),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountForm(AgentState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Montant du dépôt', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final number = int.parse(newValue.text);
                  final formatted = number.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]} ',
                      );
                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
              style: AppTextStyles.h2.copyWith(color: AppColors.success),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: 'FCFA',
                suffixStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.success, width: 2),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final amount = double.tryParse(value.replaceAll(' ', ''));
                  if (amount != null) {
                    ref.read(agentNotifierProvider.notifier).calculateCashInFees(amount);
                  }
                } else {
                  ref.read(agentNotifierProvider.notifier).clearFees();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Veuillez entrer un montant';
                final amount = double.tryParse(value.replaceAll(' ', ''));
                if (amount == null || amount <= 0) return 'Montant invalide';
                if (amount < 100) return 'Montant minimum: 100 FCFA';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text('Montants rapides', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickAmountButton('1 000'),
                _buildQuickAmountButton('5 000'),
                _buildQuickAmountButton('10 000'),
                _buildQuickAmountButton('25 000'),
                _buildQuickAmountButton('50 000'),
                _buildQuickAmountButton('100 000'),
              ],
            ),
            if (state.currentFees != null) ...[
              const SizedBox(height: 16),
              _buildFeeInfo(state.currentFees!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (state.isLoading || (state.currentClient == null && _scannedPhone == null))
                    ? null
                    : _handleDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Valider le dépôt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return OutlinedButton(
      onPressed: () {
        _amountController.text = amount;
        final numAmount = double.tryParse(amount.replaceAll(' ', ''));
        if (numAmount != null) {
          ref.read(agentNotifierProvider.notifier).calculateCashInFees(numAmount);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.success,
        side: BorderSide(color: AppColors.success),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('$amount F'),
    );
  }

  Widget _buildFeeInfo(dynamic fees) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Montant'),
              Text(_formatCurrency(fees.amount)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Frais'),
              Text(_formatCurrency(fees.fee)),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Votre commission', style: TextStyle(color: AppColors.success)),
              Text(
                _formatCurrency(fees.agentCommission),
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
