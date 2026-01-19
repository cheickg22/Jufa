import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';
import '../../domain/models/international_models.dart';

class InternationalTransferPage extends StatefulWidget {
  const InternationalTransferPage({super.key});

  @override
  State<InternationalTransferPage> createState() => _InternationalTransferPageState();
}

class _InternationalTransferPageState extends State<InternationalTransferPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Calculateur
  final TextEditingController _sendAmountController = TextEditingController();
  Country _sourceCountry = Country.supportedCountries[0]; // Mali
  Country _destinationCountry = Country.supportedCountries[1]; // France
  double _exchangeRate = 655.957; // EUR/XOF
  double _fees = 2500.0;
  
  // Données simulées
  final List<InternationalTransfer> _recentTransfers = [];
  final List<TransferCorridor> _popularCorridors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    // Simuler des données
    setState(() {
      // Pas de données pour le moment - sera connecté à l'API
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Transferts Internationaux'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Envoyer'),
            Tab(text: 'Historique'),
            Tab(text: 'Corridors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendTab(),
          _buildHistoryTab(),
          _buildCorridorsTab(),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildSendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calculateur de transfert
          _buildTransferCalculator(),
          
          const SizedBox(height: 24),
          
          // Bouton d'envoi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendAmountController.text.isNotEmpty ? _initiateTransfer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continuer le transfert',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Avantages
          _buildAdvantages(),
        ],
      ),
    );
  }

  Widget _buildTransferCalculator() {
    final sendAmount = double.tryParse(_sendAmountController.text) ?? 0.0;
    final receiveAmount = sendAmount * _exchangeRate;
    final totalCost = sendAmount + _fees;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculateur de transfert',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Pays source
          _buildCountrySelector(
            label: 'De',
            country: _sourceCountry,
            onChanged: (country) {
              setState(() {
                _sourceCountry = country;
                _updateExchangeRate();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Montant à envoyer
          TextField(
            controller: _sendAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Montant à envoyer',
              suffixText: _sourceCountry.currency,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          
          const SizedBox(height: 16),
          
          // Icône d'échange
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.swap_vert,
                color: AppColors.primary,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Pays destination
          _buildCountrySelector(
            label: 'Vers',
            country: _destinationCountry,
            onChanged: (country) {
              setState(() {
                _destinationCountry = country;
                _updateExchangeRate();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Montant reçu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Le destinataire recevra',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${receiveAmount.toStringAsFixed(2)} ${_destinationCountry.currency}',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Détails des frais
          _buildFeeBreakdown(sendAmount, _fees, totalCost),
          
          const SizedBox(height: 16),
          
          // Taux de change
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Text(
                  '1 ${_sourceCountry.currency} = ${_exchangeRate.toStringAsFixed(4)} ${_destinationCountry.currency}',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountrySelector({
    required String label,
    required Country country,
    required Function(Country) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCountryPicker(onChanged),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  country.flag,
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        country.currency,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeBreakdown(double sendAmount, double fees, double totalCost) {
    return Column(
      children: [
        _buildFeeRow('Montant à envoyer', '${sendAmount.toStringAsFixed(0)} ${_sourceCountry.currency}'),
        _buildFeeRow('Frais de transfert', '${fees.toStringAsFixed(0)} ${_sourceCountry.currency}'),
        const Divider(),
        _buildFeeRow(
          'Total à débiter',
          '${totalCost.toStringAsFixed(0)} ${_sourceCountry.currency}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildFeeRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pourquoi choisir Jufa ?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildAdvantageItem(
          icon: Icons.speed,
          title: 'Transferts rapides',
          description: 'Argent disponible en quelques minutes',
          color: AppColors.success,
        ),
        _buildAdvantageItem(
          icon: Icons.security,
          title: 'Sécurisé',
          description: 'Chiffrement de niveau bancaire',
          color: AppColors.info,
        ),
        _buildAdvantageItem(
          icon: Icons.attach_money,
          title: 'Taux compétitifs',
          description: 'Meilleurs taux du marché',
          color: AppColors.warning,
        ),
        _buildAdvantageItem(
          icon: Icons.support_agent,
          title: 'Support 24/7',
          description: 'Assistance disponible à tout moment',
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildAdvantageItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return _recentTransfers.isEmpty
        ? _buildEmptyState(
            icon: Icons.history,
            title: 'Aucun transfert',
            description: 'Vos transferts internationaux apparaîtront ici',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _recentTransfers.length,
            itemBuilder: (context, index) {
              final transfer = _recentTransfers[index];
              return _buildTransferCard(transfer);
            },
          );
  }

  Widget _buildCorridorsTab() {
    final corridors = [
      {'from': '🇲🇱 Mali', 'to': '🇫🇷 France', 'rate': '655.957', 'time': '15 min', 'popular': true},
      {'from': '🇲🇱 Mali', 'to': '🇺🇸 USA', 'rate': '0.0016', 'time': '30 min', 'popular': true},
      {'from': '🇲🇱 Mali', 'to': '🇨🇦 Canada', 'rate': '0.0021', 'time': '45 min', 'popular': false},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: corridors.length,
      itemBuilder: (context, index) {
        final corridor = corridors[index];
        return _buildCorridorCard(corridor);
      },
    );
  }

  Widget _buildCorridorCard(Map<String, dynamic> corridor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${corridor['from']} → ${corridor['to']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (corridor['popular'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Populaire',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCorridorInfo('Taux', corridor['rate']),
              _buildCorridorInfo('Temps', corridor['time']),
              _buildCorridorInfo('Frais', '2 500 FCFA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorridorInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTransferCard(InternationalTransfer transfer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transfer.recipientName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: transfer.status.icon == '✅' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${transfer.status.icon} ${transfer.status.displayName}',
                  style: TextStyle(
                    color: transfer.status.icon == '✅' ? AppColors.success : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${transfer.sourceCountry.flag} → ${transfer.destinationCountry.flag}',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transfer.formattedSendAmount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                transfer.formattedReceiveAmount,
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ref: ${transfer.referenceNumber}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCountryPicker(Function(Country) onChanged) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choisir un pays',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...Country.supportedCountries.map((country) {
              return ListTile(
                leading: Text(country.flag, style: TextStyle(fontSize: 24)),
                title: Text(country.name),
                subtitle: Text(country.currency),
                onTap: () {
                  onChanged(country);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _updateExchangeRate() {
    // Simuler la mise à jour du taux de change
    final pair = '${_sourceCountry.code}${_destinationCountry.code}';
    switch (pair) {
      case 'MLFR':
        _exchangeRate = 655.957;
        break;
      case 'MLUS':
        _exchangeRate = 0.0016;
        break;
      case 'MLCA':
        _exchangeRate = 0.0021;
        break;
      default:
        _exchangeRate = 1.0;
    }
  }

  void _initiateTransfer() {
    // Naviguer vers la page de détails du transfert
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfert initié'),
        content: Text('Votre transfert international a été initié avec succès !'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sendAmountController.dispose();
    super.dispose();
  }
}
