import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/l10n/app_localizations.dart';

class PiSpiPage extends StatefulWidget {
  const PiSpiPage({super.key});
  
  @override
  State<PiSpiPage> createState() => _PiSpiPageState();
}

class _PiSpiPageState extends State<PiSpiPage> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedOperatorIndex = 0;
  String? _selectedBank;
  
  List<Map<String, dynamic>> _getOperators(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'name': 'Orange Money', 'shortName': 'Orange', 'icon': Icons.phone_android, 'color': Color(0xFFFF6B00)},
      {'name': 'Moov Money', 'shortName': 'Moov', 'icon': Icons.phone_iphone, 'color': Color(0xFF0066CC)},
      {'name': l10n.translate('bank'), 'shortName': l10n.translate('bank'), 'icon': Icons.account_balance, 'color': Color(0xFF00A86B)},
    ];
  }
  
  final List<String> _banks = [
    'BDM',
    'BIM',
    'BNDA',
    'BOA',
    'CorisBank',
    'Ecobank',
    'BCS',
    'Atlantique',
    'Orabank',
    'UBA',
  ];

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final _operators = _getOperators(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('PI-SPI'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOperatorSelector(),
            const SizedBox(height: 20),
            _buildTransferForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorSelector() {
    final l10n = AppLocalizations.of(context);
    final _operators = _getOperators(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('to_which_operator'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_operators.length, (index) {
            final operator = _operators[index];
            final isSelected = index == _selectedOperatorIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedOperatorIndex = index;
                  _selectedBank = null;
                }),
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? operator['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? operator['color'] : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        operator['icon'],
                        size: 28,
                        color: isSelected ? Colors.white : operator['color'],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        operator['shortName'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTransferForm() {
    final l10n = AppLocalizations.of(context);
    final _operators = _getOperators(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('send_money'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedOperatorIndex == 2) ...[
              DropdownButtonFormField<String>(
                value: _selectedBank,
                decoration: InputDecoration(
                  labelText: l10n.translate('select_bank'),
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                  });
                },
                validator: (v) => v == null ? l10n.translate('select_bank_required') : null,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _recipientController,
              decoration: InputDecoration(
                labelText: _selectedOperatorIndex == 2 ? l10n.translate('account_number') : l10n.translate('recipient_number'),
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: _selectedOperatorIndex == 2 ? TextInputType.number : TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? l10n.translate('required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.translate('amount_fcfa'),
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.translate('required');
                if (double.tryParse(v) == null || double.parse(v) < 100) {
                  return l10n.translate('min_100_fcfa');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final bankInfo = _selectedOperatorIndex == 2 ? ' via $_selectedBank' : '';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.translate('transfer_successful')}$bankInfo !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _recipientController.clear();
                    _amountController.clear();
                    setState(() => _selectedBank = null);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _operators[_selectedOperatorIndex]['color'],
                ),
                child: Text(
                  'Envoyer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
