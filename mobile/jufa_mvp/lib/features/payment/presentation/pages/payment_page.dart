import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recharger'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Section Factures
          Text(
            'Payer une facture',
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
              _buildPaymentCard(
                context,
                title: 'EDM',
                subtitle: 'Électricité',
                icon: Icons.bolt,
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BillPaymentPage(
                        provider: 'EDM',
                        type: 'Électricité',
                      ),
                    ),
                  );
                },
              ),
              _buildPaymentCard(
                context,
                title: 'SOMAGEP',
                subtitle: 'Eau',
                icon: Icons.water_drop,
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BillPaymentPage(
                        provider: 'SOMAGEP',
                        type: 'Eau',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Section Airtime
          Text(
            'Recharger du crédit',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildOperatorCard(
                context,
                name: 'Orange Mali',
                icon: Icons.phone_android,
                color: AppColors.orangeMali,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AirtimePage(
                        operator: 'Orange Mali',
                      ),
                    ),
                  );
                },
              ),
              _buildOperatorCard(
                context,
                name: 'Moov Africa Malitel',
                icon: Icons.phone_android,
                color: AppColors.malitel,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AirtimePage(
                        operator: 'Moov Africa Malitel',
                      ),
                    ),
                  );
                },
              ),
              _buildOperatorCard(
                context,
                name: 'Wave',
                icon: Icons.phone_android,
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AirtimePage(
                        operator: 'Wave',
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
  
  Widget _buildPaymentCard(
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

  Widget _buildOperatorCard(
    BuildContext context, {
    required String name,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              name,
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
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paiement ${widget.provider} effectué avec succès'),
        backgroundColor: AppColors.success,
      ),
    );
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payer ${widget.type}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de référence',
                  hintText: 'Ex: 123456789',
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
                      : Text('Payer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page de recharge airtime
class AirtimePage extends StatefulWidget {
  final String operator;
  
  const AirtimePage({
    super.key,
    required this.operator,
  });

  @override
  State<AirtimePage> createState() => _AirtimePageState();
}

class _AirtimePageState extends State<AirtimePage> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleRecharge() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recharge ${widget.operator} effectuée avec succès'),
        backgroundColor: AppColors.success,
      ),
    );
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.operator),
      ),
      body: Padding(
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
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [500, 1000, 2500, 5000, 10000].map((amount) {
                return ActionChip(
                  label: Text('$amount CFA'),
                  onPressed: () {
                    _amountController.text = amount.toString();
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRecharge,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Recharger'),
            ),
          ],
        ),
      ),
    );
  }
}
