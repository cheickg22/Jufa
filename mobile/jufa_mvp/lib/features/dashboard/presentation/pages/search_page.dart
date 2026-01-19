import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.translate('search_hint'),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: TextStyle(color: Colors.black, fontSize: 18),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptyState(l10n)
          : _buildSearchResults(),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('search_in_jufa'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('search_placeholder'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context);
    final services = _getFilteredServices();
    final features = _getFilteredFeatures();

    if (services.isEmpty && features.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('no_results'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('try_other_keywords'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (services.isNotEmpty) ...[
          Text(
            l10n.translate('services'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...services.map((service) => _buildServiceItem(service)),
          const SizedBox(height: 24),
        ],
        if (features.isNotEmpty) ...[
          Text(
            l10n.translate('features'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => _buildFeatureItem(feature)),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredServices() {
    final l10n = AppLocalizations.of(context);
    final allServices = [
      {
        'name': l10n.translate('send_money'),
        'icon': Icons.send,
        'route': '/send-money',
        'keywords': ['envoyer', 'transfert', 'argent', 'send'],
      },
      {
        'name': l10n.translate('recharge_account'),
        'icon': Icons.add_circle,
        'route': '/recharge',
        'keywords': ['recharger', 'depot', 'ajouter', 'argent'],
      },
      {
        'name': l10n.translate('jufa_card_service'),
        'icon': Icons.credit_card,
        'route': '/jufa',
        'keywords': ['carte', 'jufa', 'virtuelle', 'physique'],
      },
      {
        'name': l10n.translate('nege_gold_silver'),
        'icon': Icons.diamond,
        'route': '/nege',
        'keywords': ['nege', 'or', 'argent', 'gold', 'silver', 'investir', 'marketplace'],
      },
      {
        'name': l10n.translate('airtime_mobile_credit'),
        'icon': Icons.phone_android,
        'route': '/airtime',
        'keywords': ['airtime', 'credit', 'telephone', 'recharge', 'mobile', 'forfait'],
      },
      {
        'name': l10n.translate('chat_messages'),
        'icon': Icons.chat_bubble,
        'route': '/chat',
        'keywords': ['chat', 'message', 'conversation', 'discuter', 'messenger'],
      },
      {
        'name': l10n.translate('pay_bill'),
        'icon': Icons.receipt_long,
        'route': '/bills',
        'keywords': ['facture', 'payer', 'bill', 'electricite', 'eau'],
      },
      {
        'name': l10n.translate('history'),
        'icon': Icons.history,
        'route': '/history',
        'keywords': ['historique', 'transactions', 'history'],
      },
    ];

    return allServices.where((service) {
      final keywords = service['keywords'] as List<String>;
      return keywords.any((keyword) => keyword.contains(_searchQuery)) ||
          (service['name'] as String).toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredFeatures() {
    final l10n = AppLocalizations.of(context);
    final allFeatures = [
      {
        'name': l10n.translate('notifications_feature'),
        'icon': Icons.notifications,
        'route': '/notifications',
        'keywords': ['notification', 'alerte', 'message'],
      },
      {
        'name': l10n.translate('profile_feature'),
        'icon': Icons.person,
        'route': '/profile',
        'keywords': ['profil', 'compte', 'parametres', 'settings'],
      },
      {
        'name': l10n.translate('security_feature'),
        'icon': Icons.security,
        'route': '/security',
        'keywords': ['securite', 'code', 'pin', 'mot de passe'],
      },
    ];

    return allFeatures.where((feature) {
      final keywords = feature['keywords'] as List<String>;
      return keywords.any((keyword) => keyword.contains(_searchQuery)) ||
          (feature['name'] as String).toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            service['icon'] as IconData,
            color: AppColors.primary,
          ),
        ),
        title: Text(service['name'] as String),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.push(service['route'] as String);
        },
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature['icon'] as IconData,
            color: Colors.grey[700],
          ),
        ),
        title: Text(feature['name'] as String),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.push(feature['route'] as String);
        },
      ),
    );
  }
}
