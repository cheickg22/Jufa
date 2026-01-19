import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/agent_provider.dart';

class CashOutScreen extends ConsumerStatefulWidget {
  const CashOutScreen({super.key});

  @override
  ConsumerState<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends ConsumerState<CashOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+223 ');
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  final currencyFormat = NumberFormat('#,###', 'fr_FR');

  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _usePhoneInput = false;
  String? _scannedPhone;
  bool _obscurePin = true;

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
    _pinController.dispose();
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

  Future<void> _handleWithdrawal() async {
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

    final amount = double.parse(_amountController.text.replaceAll(' ', ''));
    final customerPhone = client?.phone ?? _scannedPhone!;

    final success = await ref.read(agentNotifierProvider.notifier).processCashOut(
          customerPhone: customerPhone,
          amount: amount,
          customerPin: _pinController.text,
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
                    color: AppColors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.warning,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Retrait réussi',
                  style: AppTextStyles.h2.copyWith(color: AppColors.warning),
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
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('Cash à remettre', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(amount),
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (transaction != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Frais', _formatCurrency(transaction.fee)),
                        const SizedBox(height: 8),
                        _buildInfoRow('Commission', _formatCurrency(transaction.agentCommission)),
                        Divider(height: 16, color: AppColors.border),
                        _buildInfoRow('De', client?.name ?? 'Client'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Numéro', customerPhone),
                      ],
                    ),
                  ),
                ],
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
                          foregroundColor: AppColors.warning,
                          side: BorderSide(color: AppColors.warning),
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
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Nouveau retrait'),
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
      _pinController.clear();
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
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        title: const Text('Retrait Client'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isScanning) _buildQrScanner(),
            if (_usePhoneInput) _buildPhoneInput(state.isSearchingClient),
            if (!_isScanning && !_usePhoneInput && client != null) _buildClientFound(client),
            if (!_isScanning && !_usePhoneInput && client == null && _scannedPhone == null) _buildClientNotFound(),
            _buildWithdrawalForm(state),
          ],
        ),
      ),
    );
  }

  Widget _buildQrScanner() {
    return Container(
      height: 300,
      color: Colors.black,
      child: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onQrCodeDetected,
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.warning, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
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
            bottom: 12,
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
                  backgroundColor: AppColors.warning,
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
      color: AppColors.warning.withValues(alpha: 0.1),
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
                icon: Icon(Icons.qr_code_scanner, color: AppColors.warning),
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
                borderSide: BorderSide(color: AppColors.warning, width: 2),
              ),
            ),
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
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Scanner'),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(AgentState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Montant du retrait', style: AppTextStyles.h3),
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
              style: AppTextStyles.h2.copyWith(color: AppColors.warning),
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
                  borderSide: BorderSide(color: AppColors.warning, width: 2),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final amount = double.tryParse(value.replaceAll(' ', ''));
                  if (amount != null) {
                    ref.read(agentNotifierProvider.notifier).calculateCashOutFees(amount);
                  }
                } else {
                  ref.read(agentNotifierProvider.notifier).clearFees();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Veuillez entrer un montant';
                final amount = double.tryParse(value.replaceAll(' ', ''));
                if (amount == null || amount <= 0) return 'Montant invalide';
                if (amount < 500) return 'Montant minimum: 500 FCFA';
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
                _buildQuickAmountButton('5 000'),
                _buildQuickAmountButton('10 000'),
                _buildQuickAmountButton('25 000'),
                _buildQuickAmountButton('50 000'),
                _buildQuickAmountButton('100 000'),
              ],
            ),
            const SizedBox(height: 20),
            Text('Code PIN du client', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: _obscurePin,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: 'PIN à 4-6 chiffres',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.warning, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'PIN requis';
                if (value.length < 4) return 'PIN invalide (minimum 4 chiffres)';
                return null;
              },
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
                    : _handleWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
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
                    : const Text('Valider le retrait', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          ref.read(agentNotifierProvider.notifier).calculateCashOutFees(numAmount);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.warning,
        side: BorderSide(color: AppColors.warning),
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
              const Text('Montant demandé'),
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
              Text('Cash à remettre', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
              Text(
                _formatCurrency(fees.amount),
                style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
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
