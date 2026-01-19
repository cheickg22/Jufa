import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/theme/agent_colors.dart';
import '../../../../../core/utils/phone_formatter.dart';
import '../../../../../core/services/agent_api_service.dart';
import '../../../../../core/services/agent_auth_service.dart';
import '../../../../../core/models/agent.dart';

class AgentDepositPage extends StatefulWidget {
  const AgentDepositPage({super.key});

  @override
  State<AgentDepositPage> createState() => _AgentDepositPageState();
}

class _AgentDepositPageState extends State<AgentDepositPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+223 ');
  final _amountController = TextEditingController();
  final AgentApiService _agentApiService = AgentApiService();
  
  MobileScannerController? _scannerController;
  String? _scannedQrCode;
  String? _clientPhone;
  Map<String, dynamic>? _clientInfo;
  bool _isScanning = true;
  bool _isLoading = false;
  bool _usePhoneInput = false;

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

  void _onQrCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    
    if (code != null && code.isNotEmpty) {
      setState(() {
        _scannedQrCode = code;
        _isScanning = false;
      });
      
      // Simuler la récupération des infos client
      // TODO: Appeler l'API pour récupérer les vraies infos
      setState(() {
        _clientInfo = {
          'name': 'Client Test',
          'phone': '+223 XX XX XX XX',
          'balance': '50000',
        };
      });
    }
  }

  void _onPhoneChanged(String value) {
    final cleanedPhone = value.replaceAll(' ', '').replaceAll('+', '');
    
    // Si le numéro est complet (11 chiffres avec 223), rechercher automatiquement
    if (cleanedPhone.length == 11 && cleanedPhone.startsWith('223')) {
      _searchClientByPhone();
    }
  }

  Future<void> _searchClientByPhone() async {
    if (_isLoading) return; // Éviter les recherches multiples
    
    setState(() => _isLoading = true);

    try {
      // Appeler l'API pour rechercher le client
      final result = await _agentApiService.searchClient(_phoneController.text.replaceAll(' ', ''));
      final user = result['user'] as Map<String, dynamic>? ?? {};
      final wallet = result['wallet'] as Map<String, dynamic>? ?? {};
      
      if (mounted) {
        setState(() {
          _clientPhone = _phoneController.text;
          _clientInfo = {
            'name': user['name'] ?? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
            'phone': user['phone'] ?? '',
            'balance': wallet['balance']?.toString() ?? '0',
            'wallet_number': wallet['wallet_number'] ?? '',
          };
          _usePhoneInput = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Client non trouvé'),
            backgroundColor: AgentColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
            const Text(
              'Entrez votre code PIN pour confirmer cette opération',
              style: TextStyle(color: AgentColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Code PIN',
                border: OutlineInputBorder(),
                counterText: '',
                prefixIcon: Icon(Icons.lock),
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
                  const SnackBar(content: Text('Le code PIN doit contenir 4 chiffres')),
                );
                return;
              }
              
              // Vérifier le code PIN via l'API
              try {
                await _agentApiService.verifySecretCode(pinController.text);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AgentColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AgentColors.primary,
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
    if (_scannedQrCode == null && _clientPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez scanner le QR code ou entrer le numéro du client'),
          backgroundColor: AgentColors.error,
        ),
      );
      return;
    }

    // Demander le code PIN avant de continuer
    final pinConfirmed = await _showPinConfirmationDialog();
    if (!pinConfirmed) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.replaceAll(' ', ''));
      
      // Nettoyer le numéro de téléphone (enlever les espaces)
      final clientPhone = (_scannedQrCode ?? _clientPhone!).replaceAll(' ', '');
      
      final depositResponse = await _agentApiService.processDeposit(
        clientQrCode: clientPhone,
        amount: amount,
      );

      // Recharger le profil de l'agent pour mettre à jour le solde
      final token = await AgentAuthService.getToken();
      Agent? updatedAgent;
      if (token != null) {
        final profileResponse = await _agentApiService.getProfile(token);
        if (profileResponse.isNotEmpty) {
          updatedAgent = Agent.fromJson(profileResponse);
          await AgentAuthService.saveAgent(updatedAgent);
        }
      }

      if (mounted) {
        final now = DateTime.now();
        // Lire le transaction_code depuis la réponse API
        final transactionId = depositResponse['data']?['transaction_code'] ?? 'TXN${now.millisecondsSinceEpoch}';
        // Lire les frais depuis la réponse API (user_deposit_fee, pas la commission agent)
        final fees = (depositResponse['data']?['fees'] ?? 0.0).toStringAsFixed(0);
        
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
                  
                  // Dépôt réussi
                  Text(
                    'Dépôt réussi',
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AgentColors.textSecondary,
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
                          '${amount.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AgentColors.textPrimary,
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
                            const Text(
                              'Montant',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgentColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${amount.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AgentColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Frais',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgentColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$fees FCFA',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AgentColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Cadre De et À fusionnés
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AgentColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // De
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'De',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgentColors.textSecondary,
                              ),
                            ),
                            const Text(
                              'Agent',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AgentColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Numéro',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgentColors.textSecondary,
                              ),
                            ),
                            FutureBuilder<Agent?>(
                              future: AgentAuthService.getAgent(),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data?.phone ?? '+223 XX XX XX XX',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AgentColors.textPrimary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Ligne de séparation
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AgentColors.border,
                        ),
                        const SizedBox(height: 12),
                        
                        // À
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'À',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgentColors.textSecondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _clientInfo?['name'] ?? 'Client',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AgentColors.textPrimary,
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
                            const Text(
                              'Numéro',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgentColors.textSecondary,
                              ),
                            ),
                            Text(
                              _clientInfo?['phone'] ?? '+223 XX XX XX XX',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AgentColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AgentColors.primary,
                            side: const BorderSide(color: AgentColors.primary),
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
                            backgroundColor: AgentColors.primary,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AgentColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _scannedQrCode = null;
      _clientPhone = null;
      _clientInfo = null;
      _isScanning = true;
      _usePhoneInput = false;
      _phoneController.text = '+223 ';
      _amountController.clear();
    });
    _scannerController?.start();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AgentColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Dépôt Client'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Scanner QR Code
            if (_isScanning) ...[
              Container(
                height: 400,
                color: Colors.black,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onQrCodeDetected,
                    ),
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: AgentColors.primary, width: 3),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
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
                          icon: const Text('🇲🇱', style: TextStyle(fontSize: 20)),
                          label: const Text('Saisir le numéro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgentColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_usePhoneInput) ...[
              // Saisie manuelle du numéro
              Container(
                padding: const EdgeInsets.all(20),
                color: AgentColors.primaryLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text('🇲🇱', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Numéro du client',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AgentColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: AgentColors.primary),
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
                      inputFormatters: [
                        PhoneInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        hintText: '+223 XX XX XX XX',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                        ),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AgentColors.primary),
                                  ),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Entrez le numéro complet pour rechercher automatiquement',
                      style: TextStyle(
                        fontSize: 12,
                        color: AgentColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Client trouvé
              Container(
                padding: const EdgeInsets.all(20),
                color: AgentColors.success.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AgentColors.success, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _scannedQrCode != null ? 'QR Code scanné' : 'Client trouvé',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AgentColors.success,
                            ),
                          ),
                          if (_clientInfo != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _clientInfo!['name'] ?? 'Client',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AgentColors.textPrimary,
                              ),
                            ),
                            Text(
                              _clientInfo!['phone'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AgentColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AgentColors.primary),
                      onPressed: _resetForm,
                    ),
                  ],
                ),
              ),
            ],
            
            // Formulaire de montant
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Montant du dépôt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AgentColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ montant
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
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AgentColors.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: 'FCFA',
                        suffixStyle: const TextStyle(
                          fontSize: 20,
                          color: AgentColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AgentColors.border, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        final amount = double.tryParse(value.replaceAll(' ', ''));
                        if (amount == null || amount <= 0) {
                          return 'Montant invalide';
                        }
                        if (amount < 100) {
                          return 'Montant minimum: 100 FCFA';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Montants rapides
                    const Text(
                      'Montants rapides',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AgentColors.textSecondary,
                      ),
                    ),
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
                    const SizedBox(height: 32),
                    
                    // Bouton valider
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isLoading || (_scannedQrCode == null && _clientPhone == null)) ? null : _handleDeposit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AgentColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Valider le dépôt',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
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
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AgentColors.primary,
        side: const BorderSide(color: AgentColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text('$amount F'),
    );
  }
}
