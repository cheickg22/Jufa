import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/jufa_card_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/l10n/app_localizations.dart';

class OrderCardPage extends StatefulWidget {
  const OrderCardPage({super.key});

  @override
  State<OrderCardPage> createState() => _OrderCardPageState();
}

class _OrderCardPageState extends State<OrderCardPage> {
  final JufaCardService _cardService = JufaCardService();
  String _selectedCardType = '';
  bool _isLoading = true;
  double _virtualCardPrice = 1000;
  double _physicalCardPrice = 5000;

  @override
  void initState() {
    super.initState();
    _loadCardPrices();
  }

  Future<void> _loadCardPrices() async {
    try {
      final prices = await _cardService.getCardPrices();
      if (mounted) {
        setState(() {
          _virtualCardPrice = prices['virtual_card_price'] ?? 1000;
          _physicalCardPrice = prices['physical_card_price'] ?? 5000;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement prix: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('order_card_title')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('choose_your_card'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('select_card_type'),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Carte Virtuelle
                  _buildCardOption(
                    type: 'virtual',
                    title: l10n.translate('virtual_card'),
                    description: l10n.translate('virtual_card_desc'),
                    icon: Icons.credit_card,
                    color: Colors.blue,
                    features: [
                      l10n.translate('instant_creation'),
                      '${l10n.translate('fees')}: ${_virtualCardPrice.toStringAsFixed(0)} FCFA',
                      l10n.translate('ideal_online'),
                      l10n.translate('secured'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Carte Physique
                  _buildCardOption(
                    type: 'physical',
                    title: l10n.translate('physical_card'),
                    description: l10n.translate('physical_card_desc'),
                    icon: Icons.credit_card_outlined,
                    color: Colors.indigo.shade800,
                    features: [
                      l10n.translate('delivery_5_7_days'),
                      '${l10n.translate('fees')}: ${_physicalCardPrice.toStringAsFixed(0)} FCFA',
                      l10n.translate('usable_everywhere'),
                      l10n.translate('pickup_possible'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCardOption({
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> features,
  }) {
    final isSelected = _selectedCardType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardType = type;
        });
        
        // Ouvrir le dialogue correspondant
        Future.delayed(const Duration(milliseconds: 200), () {
          if (type == 'virtual') {
            _showVirtualCardDialog();
          } else {
            _showPhysicalCardDialog();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showVirtualCardDialog() async {
    final l10n = AppLocalizations.of(context);
    // Récupérer les infos utilisateur
    final firstName = await UserService.getFirstName();
    final lastName = await UserService.getLastName();
    final email = await UserService.getEmail();
    final phone = await UserService.getPhone();
    
    bool acceptedTerms = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: AppColors.primary),
              SizedBox(width: 8),
              Text(l10n.translate('buy_virtual_card')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('order_summary'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Informations utilisateur
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Titulaire de la carte',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$firstName $lastName',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        phone,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Détails de la carte
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails de la carte',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${l10n.translate('type')}:', style: TextStyle(fontSize: 13)),
                          Text(l10n.translate('virtual_card'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${l10n.translate('activation')}:', style: TextStyle(fontSize: 13)),
                          Text(l10n.translate('instant'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${l10n.translate('validity')}:', style: TextStyle(fontSize: 13)),
                          Text(l10n.translate('years_5'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Prix
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.translate('total_price')}:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_virtualCardPrice.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Conditions d'utilisation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('terms_of_use'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(l10n.translate('online_only'), style: TextStyle(fontSize: 11)),
                      Text(l10n.translate('rechargeable_wallet'), style: TextStyle(fontSize: 11)),
                      Text(l10n.translate('daily_limit'), style: TextStyle(fontSize: 11)),
                      Text(l10n.translate('monthly_limit'), style: TextStyle(fontSize: 11)),
                      Text(l10n.translate('block_unblock'), style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Checkbox acceptation
                CheckboxListTile(
                  value: acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      acceptedTerms = value ?? false;
                    });
                  },
                  title: Text(
                    l10n.translate('accept_terms'),
                    style: TextStyle(fontSize: 13),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: acceptedTerms
                  ? () {
                      Navigator.pop(context);
                      _orderVirtualCard();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(l10n.translate('buy_now')),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhysicalCardDialog() async {
    final l10n = AppLocalizations.of(context);
    // Récupérer les infos utilisateur
    final firstName = await UserService.getFirstName();
    final lastName = await UserService.getLastName();
    final email = await UserService.getEmail();
    final phone = await UserService.getPhone();
    
    final formKey = GlobalKey<FormState>();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final phoneController = TextEditingController(text: phone);
    bool acceptedTerms = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: AppColors.primary),
              SizedBox(width: 8),
              Text(l10n.translate('buy_physical_card')),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('order_summary'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Informations utilisateur
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('card_holder'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Informations de livraison
                  Text(
                    l10n.translate('delivery_info'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: l10n.translate('delivery_address'),
                      hintText: l10n.translate('street_area'),
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('enter_address');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: l10n.translate('city'),
                      hintText: l10n.translate('city_example'),
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('enter_city');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.translate('contact_phone'),
                      hintText: '+223 XX XX XX XX',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                      ),
                      border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.translate('enter_phone');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Détails de la carte
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.indigo.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.translate('card_details'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${l10n.translate('type')}:', style: TextStyle(fontSize: 13)),
                                Text(l10n.translate('physical_card'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${l10n.translate('delivery')}:', style: TextStyle(fontSize: 13)),
                                Text(l10n.translate('days_5_7'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${l10n.translate('validity')}:', style: TextStyle(fontSize: 13)),
                                Text(l10n.translate('years_5'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Prix
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.translate('total_price')}:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_physicalCardPrice.toStringAsFixed(0)} FCFA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Conditions d'utilisation
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.translate('terms_of_use'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(l10n.translate('online_store'), style: TextStyle(fontSize: 11)),
                            Text(l10n.translate('atm_withdrawal'), style: TextStyle(fontSize: 11)),
                            Text(l10n.translate('rechargeable_wallet'), style: TextStyle(fontSize: 11)),
                            Text(l10n.translate('daily_limit'), style: TextStyle(fontSize: 11)),
                            Text(l10n.translate('monthly_limit'), style: TextStyle(fontSize: 11)),
                            Text(l10n.translate('free_delivery'), style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Checkbox acceptation
                      CheckboxListTile(
                        value: acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            acceptedTerms = value ?? false;
                          });
                        },
                        title: Text(
                          l10n.translate('accept_terms_delivery'),
                          style: TextStyle(fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ],
                  ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: (acceptedTerms && formKey.currentState?.validate() == true)
                  ? () {
                      if (formKey.currentState!.validate()) {
                        final address = addressController.text;
                        final city = cityController.text;
                        final phone = phoneController.text;
                        
                        Navigator.pop(context);
                        _orderPhysicalCard(address, city, phone);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(l10n.translate('buy_now')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _orderVirtualCard() async {
    print('🎴 Début commande carte virtuelle...');
    setState(() => _isLoading = true);

    try {
      print('📞 Appel API orderCard...');
      final result = await _cardService.orderCard(cardType: 'virtual');
      print('✅ Carte créée: $result');

      if (!mounted) return;
      
      setState(() => _isLoading = false);

      // Afficher le modal de félicitations
      await _showCongratulationsDialog('virtual');

      // Retourner à la page précédente
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      print('❌ Erreur lors de la commande: $e');
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _orderPhysicalCard(String address, String city, String phone) async {
    print('🎴 Début commande carte physique...');
    setState(() => _isLoading = true);

    try {
      print('📞 Appel API orderCard...');
      final result = await _cardService.orderCard(
        cardType: 'physical',
        deliveryAddress: address,
        deliveryCity: city,
        deliveryPhone: phone,
      );
      print('✅ Carte commandée: $result');

      if (!mounted) return;
      
      setState(() => _isLoading = false);

      // Afficher le modal de félicitations
      await _showCongratulationsDialog('physical');

      // Retourner à la page précédente
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      print('❌ Erreur lors de la commande: $e');
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showCongratulationsDialog(String cardType) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Icône de succès animée
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 35,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Titre
              Text(
                'Félicitations !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Message
              Text(
                cardType == 'virtual'
                    ? 'Votre carte virtuelle a été créée avec succès !'
                    : 'Votre commande de carte physique a été enregistrée !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              
              // Aperçu de la carte avec animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.easeOutBack,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: (1 - value) * 0.1,
                      child: Container(
                        width: 280,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: cardType == 'virtual'
                              ? LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [Color(0xFFf093fb), Color(0xFFF5576C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (cardType == 'virtual' 
                                  ? const Color(0xFF667eea) 
                                  : const Color(0xFFf093fb)).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JUFA CARD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    cardType == 'virtual' ? 'VIRTUELLE' : 'PHYSIQUE',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Row(
                                children: [
                                  Icon(
                                    cardType == 'virtual' ? Icons.credit_card : Icons.contactless,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '•••• •••• •••• ••••',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Message d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cardType == 'virtual'
                            ? 'Pour plus de détails, allez sur Carte Jufa'
                            : 'Vous serez notifié lors de l\'expédition. Pour plus de détails, allez sur Carte Jufa',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Bouton OK
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Compris !',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
