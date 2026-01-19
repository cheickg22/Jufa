import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/jufa_card_service.dart';

class OrderCardPage extends StatefulWidget {
  const OrderCardPage({super.key});

  @override
  State<OrderCardPage> createState() => _OrderCardPageState();
}

class _OrderCardPageState extends State<OrderCardPage> {
  final JufaCardService _cardService = JufaCardService();
  String _selectedCardType = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commander une carte'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez votre carte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez le type de carte que vous souhaitez commander',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Carte Virtuelle
            _buildCardOption(
              type: 'virtual',
              title: 'Carte Virtuelle',
              description: 'Créez instantanément une carte virtuelle pour vos achats en ligne',
              icon: Icons.credit_card,
              color: Colors.blue,
              features: [
                'Création instantanée',
                'Gratuite',
                'Idéale pour les achats en ligne',
                'Sécurisée',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Carte Physique
            _buildCardOption(
              type: 'physical',
              title: 'Carte Physique',
              description: 'Commandez une carte physique livrée chez vous',
              icon: Icons.credit_card_outlined,
              color: Colors.indigo.shade800,
              features: [
                'Livraison sous 5-7 jours',
                'Frais de 5 000 FCFA',
                'Utilisable partout',
                'Retrait en agence possible',
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
            _showAddCardDialog();
          } else {
            _showOrderPhysicalCardDialog();
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

  void _showAddCardDialog() {
    final formKey = GlobalKey<FormState>();
    final cardNameController = TextEditingController();
    final initialAmountController = TextEditingController();
    String selectedCardType = 'Standard';
    Color selectedColor = Colors.blue;
    
    final List<Color> availableColors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo.shade800,
      Colors.pink,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Acheter une carte virtuelle'),
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
                    'Achetez une carte virtuelle pour vos achats en ligne. Vous pourrez la recharger après l\'achat.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: cardNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la carte',
                      hintText: 'Ex: Carte Shopping',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: selectedCardType,
                    decoration: const InputDecoration(
                      labelText: 'Type de carte',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Standard', child: Text('Standard - Gratuite')),
                      DropdownMenuItem(value: 'Premium', child: Text('Premium - 1 000 FCFA')),
                      DropdownMenuItem(value: 'Business', child: Text('Business - 2 500 FCFA')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCardType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Sélecteur de couleur
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Couleur de la carte',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: availableColors.map((color) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
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
                          'Avantages:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• Activation instantanée', style: TextStyle(fontSize: 11)),
                        Text('• Utilisable immédiatement', style: TextStyle(fontSize: 11)),
                        Text('• Rechargeable à volonté', style: TextStyle(fontSize: 11)),
                        Text('• Blocage/déblocage facile', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Frais d\'achat: ${selectedCardType == 'Standard' ? 'Gratuit' : selectedCardType == 'Premium' ? '1 000 FCFA' : '2 500 FCFA'}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final cardName = cardNameController.text;
                  final fee = selectedCardType == 'Standard' ? 0 : selectedCardType == 'Premium' ? 1000 : 2500;
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Carte "$cardName" achetée avec succès ! ${fee > 0 ? 'Frais: $fee FCFA' : 'Gratuit'}'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text('Acheter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderPhysicalCardDialog() {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedCardDesign = 'Classique';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.credit_card, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Commander une carte physique'),
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
                    'Commandez votre carte Jufa physique et recevez-la chez vous.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      hintText: 'Nom sur la carte',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse de livraison',
                      hintText: 'Rue, quartier',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre adresse';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Ex: Bamako',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre ville';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
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
                        return 'Veuillez entrer votre numéro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: selectedCardDesign,
                    decoration: const InputDecoration(
                      labelText: 'Design de la carte',
                      prefixIcon: Icon(Icons.palette),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Classique', child: Text('Classique (Bleu)')),
                      DropdownMenuItem(value: 'Premium', child: Text('Premium (Noir)')),
                      DropdownMenuItem(value: 'Gold', child: Text('Gold (Or)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCardDesign = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avantages:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• Livraison gratuite', style: TextStyle(fontSize: 11)),
                        Text('• Acceptée partout', style: TextStyle(fontSize: 11)),
                        Text('• Paiements sans contact', style: TextStyle(fontSize: 11)),
                        Text('• Retraits aux distributeurs', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Frais de commande: 5 000 FCFA\nLivraison sous 5-7 jours',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = fullNameController.text;
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Commande de carte pour "$name" enregistrée !'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text('Commander'),
            ),
          ],
        ),
      ),
    );
  }
}
