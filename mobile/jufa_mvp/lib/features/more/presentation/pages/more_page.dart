import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plus de services'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Services Financiers
            _buildSectionTitle(context, 'Services Financiers'),
            const SizedBox(height: 16),
            _buildServiceGrid([
              ServiceItem(
                icon: Icons.savings,
                title: 'Épargne',
                subtitle: 'Comptes d\'épargne sécurisés',
                color: AppColors.success,
                onTap: () => _showComingSoon(context, 'Épargne'),
              ),
              ServiceItem(
                icon: Icons.trending_up,
                title: 'Investissement',
                subtitle: 'Placements et investissements',
                color: AppColors.primary,
                onTap: () => _showComingSoon(context, 'Investissement'),
              ),
              ServiceItem(
                icon: Icons.account_balance,
                title: 'Crédit',
                subtitle: 'Demandes de crédit',
                color: AppColors.info,
                onTap: () => _showComingSoon(context, 'Crédit'),
              ),
              ServiceItem(
                icon: Icons.security,
                title: 'Assurance',
                subtitle: 'Protection et assurance',
                color: AppColors.secondary,
                onTap: () => _showComingSoon(context, 'Assurance'),
              ),
            ]),

            const SizedBox(height: 32),

            // Section Billetterie
            _buildSectionTitle(context, 'Billetterie'),
            const SizedBox(height: 16),
            _buildServiceGrid([
              ServiceItem(
                icon: Icons.flight,
                title: 'Avion',
                subtitle: 'Billets d\'avion domestiques',
                color: AppColors.info,
                onTap: () => _showTicketingService(context, 'Billets d\'avion'),
              ),
              ServiceItem(
                icon: Icons.directions_bus,
                title: 'Bus',
                subtitle: 'Transport interurbain',
                color: AppColors.warning,
                onTap: () => _showTicketingService(context, 'Billets de bus'),
              ),
              ServiceItem(
                icon: Icons.train,
                title: 'Train',
                subtitle: 'Transport ferroviaire',
                color: AppColors.success,
                onTap: () => _showTicketingService(context, 'Billets de train'),
              ),
              ServiceItem(
                icon: Icons.event,
                title: 'Événements',
                subtitle: 'Concerts, spectacles',
                color: AppColors.accent,
                onTap: () => _showTicketingService(context, 'Billets d\'événements'),
              ),
            ]),

            const SizedBox(height: 32),

            // Section Utilitaires
            _buildSectionTitle(context, 'Utilitaires'),
            const SizedBox(height: 16),
            _buildServiceGrid([
              ServiceItem(
                icon: Icons.calculate,
                title: 'Calculatrice',
                subtitle: 'Calculatrice financière',
                color: AppColors.accent,
                onTap: () => _showCalculator(context),
              ),
              ServiceItem(
                icon: Icons.currency_exchange,
                title: 'Taux de change',
                subtitle: 'Convertisseur de devises',
                color: AppColors.warning,
                onTap: () => _showExchangeRates(context),
              ),
              ServiceItem(
                icon: Icons.location_on,
                title: 'Agences',
                subtitle: 'Trouver une agence',
                color: AppColors.error,
                onTap: () => _showComingSoon(context, 'Localisation d\'agences'),
              ),
              ServiceItem(
                icon: Icons.help,
                title: 'Aide',
                subtitle: 'Support et FAQ',
                color: AppColors.textSecondary,
                onTap: () => _showHelp(context),
              ),
            ]),

          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildServiceGrid(List<ServiceItem> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return InkWell(
      onTap: service.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                color: service.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              service.subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bientôt disponible'),
        content: Text('La fonctionnalité "$feature" sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Calculatrice'),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Text(
              'Calculatrice financière\n\nFonctionnalités:\n• Calcul d\'intérêts\n• Conversion de devises\n• Calcul de commissions',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showExchangeRates(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Taux de change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExchangeRate('USD', 'FCFA', '1 USD = 590 FCFA'),
            _buildExchangeRate('EUR', 'FCFA', '1 EUR = 655 FCFA'),
            _buildExchangeRate('GBP', 'FCFA', '1 GBP = 745 FCFA'),
            const SizedBox(height: 8),
            Text(
              'Taux indicatifs - Mis à jour il y a 2h',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRate(String from, String to, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$from → $to'),
          Text(
            rate,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }


  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aide et Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Besoin d\'aide ?'),
            const SizedBox(height: 16),
            _buildHelpItem(Icons.phone, 'Appeler le support', '+223 XX XX XX XX'),
            _buildHelpItem(Icons.email, 'Email', 'support@jufa.ml'),
            _buildHelpItem(Icons.chat, 'Chat en ligne', 'Disponible 24h/7j'),
            _buildHelpItem(Icons.help, 'FAQ', 'Questions fréquentes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketingService(BuildContext context, String serviceType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(serviceType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service de réservation de $serviceType'),
            const SizedBox(height: 16),
            if (serviceType.contains('avion')) ...[
              _buildTicketOption('Bamako → Kayes', '45 000 FCFA', Icons.flight_takeoff),
              _buildTicketOption('Bamako → Gao', '65 000 FCFA', Icons.flight_takeoff),
              _buildTicketOption('Bamako → Tombouctou', '70 000 FCFA', Icons.flight_takeoff),
            ] else if (serviceType.contains('bus')) ...[
              _buildTicketOption('Bamako → Sikasso', '8 000 FCFA', Icons.directions_bus),
              _buildTicketOption('Bamako → Ségou', '5 000 FCFA', Icons.directions_bus),
              _buildTicketOption('Bamako → Mopti', '12 000 FCFA', Icons.directions_bus),
            ] else if (serviceType.contains('train')) ...[
              _buildTicketOption('Bamako → Kayes', '15 000 FCFA', Icons.train),
              _buildTicketOption('Bamako → Kita', '8 000 FCFA', Icons.train),
            ] else if (serviceType.contains('événements')) ...[
              _buildTicketOption('Concert Salif Keïta', '25 000 FCFA', Icons.music_note),
              _buildTicketOption('Festival sur le Niger', '15 000 FCFA', Icons.festival),
              _buildTicketOption('Match des Aigles', '10 000 FCFA', Icons.sports_soccer),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.info, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Réservation en ligne sécurisée avec paiement mobile',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context, serviceType);
            },
            child: Text('Réserver'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketOption(String route, String price, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(route, style: TextStyle(fontSize: 14))),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

}

class ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
