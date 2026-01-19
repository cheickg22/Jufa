import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class RechargePage extends StatelessWidget {
  const RechargePage({super.key});

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
          Text(
            'Recharge rapide',
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
                      builder: (context) => const QuickRechargePage(
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
                      builder: (context) => const QuickRechargePage(
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
                      builder: (context) => const QuickRechargePage(
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

// Page de recharge rapide
class QuickRechargePage extends StatefulWidget {
  final String operator;
  
  const QuickRechargePage({
    super.key,
    required this.operator,
  });

  @override
  State<QuickRechargePage> createState() => _QuickRechargePageState();
}

class _QuickRechargePageState extends State<QuickRechargePage> {
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
              runSpacing: 8,
              children: [500, 1000, 2500, 5000].map((amount) {
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
