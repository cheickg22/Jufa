import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('bills')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            l10n.translate('pay_bill'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildBillCard(
                context,
                title: 'EDM',
                subtitle: l10n.translate('electricity'),
                icon: Icons.bolt,
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillPaymentPage(
                        provider: 'EDM',
                        type: l10n.translate('electricity'),
                      ),
                    ),
                  );
                },
              ),
              _buildBillCard(
                context,
                title: 'SOMAGEP',
                subtitle: l10n.translate('water'),
                icon: Icons.water_drop,
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillPaymentPage(
                        provider: 'SOMAGEP',
                        type: l10n.translate('water'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Page de paiement de facture
class BillPaymentPage extends StatefulWidget {
  final String provider;
  final String type;
  
  const BillPaymentPage({
    super.key,
    required this.provider,
    required this.type,
  });

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends State<BillPaymentPage> {
  final _referenceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.translate('payment_successful')} ${widget.provider}'),
        backgroundColor: AppColors.success,
      ),
    );
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.translate('pay')} ${widget.type}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: l10n.translate('reference_number'),
                  hintText: l10n.translate('reference_example'),
                  prefixIcon: Icon(Icons.receipt_long),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.translate('pay')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
