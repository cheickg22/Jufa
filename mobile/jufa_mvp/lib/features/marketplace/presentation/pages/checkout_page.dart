import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/marketplace_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Contrôleurs pour les informations de carte Visa
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  final MarketplaceService _marketplaceService = MarketplaceService();
  final CartService _cartService = CartService();
  
  String _selectedPaymentMethod = 'wallet';
  double _shippingFee = 2000; // Frais de livraison par défaut
  bool _isLoading = false;
  
  // États de validation des champs de carte
  bool _isCardNumberValid = false;
  bool _isCardHolderValid = false;
  bool _isExpiryDateValid = false;
  bool _isCvvValid = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userIdStr = await UserService.getUserId();

      if (userIdStr == null || userIdStr.isEmpty) {
        throw Exception('Utilisateur non connecté');
      }
      
      final userId = int.parse(userIdStr);

      // Formater le numéro de téléphone avec +223
      final phoneNumber = _phoneController.text.trim().replaceAll(' ', '');
      final fullPhoneNumber = '+223$phoneNumber';

      final order = Order(
        orderNumber: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        totalAmount: widget.totalAmount,
        shippingFee: _shippingFee,
        paymentMethod: _selectedPaymentMethod,
        deliveryAddress: _addressController.text.trim(),
        deliveryCity: _cityController.text.trim(),
        deliveryPhone: fullPhoneNumber,
        deliveryNotes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        items: widget.cartItems.map((item) => OrderItem(
          productId: item.productId,
          productName: item.productName,
          productImage: item.productImage,
          price: item.price,
          quantity: item.quantity,
          variant: item.variant,
        )).toList(),
      );

      final result = await _marketplaceService.createOrder(order);
      
      // Vider le panier après la commande
      await _cartService.clearCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(
              orderNumber: result['order_number'],
              orderId: result['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finaliser la commande'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Adresse de livraison'),
                const SizedBox(height: 12),
                _buildAddressFields(),
                const SizedBox(height: 24),
                
                _buildSectionTitle('Mode de paiement'),
                const SizedBox(height: 12),
                _buildPaymentMethods(),
                
                // Formulaire de carte (affiché conditionnellement pour Visa)
                if (_selectedPaymentMethod == 'visa') ...[
                  const SizedBox(height: 16),
                  _buildCardDetailsForm(),
                ],
                
                const SizedBox(height: 24),
                
                _buildSectionTitle('Récapitulatif'),
                const SizedBox(height: 12),
                _buildOrderSummary(),
                const SizedBox(height: 24),
                
                _buildPlaceOrderButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddressFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse complète *',
                hintText: 'Ex: Rue 123, Quartier XYZ',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer votre adresse';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ville *',
                hintText: 'Ex: Bamako',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer votre ville';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Téléphone de contact *',
                hintText: 'XX XX XX XX',
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🇲🇱',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+223',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
                _PhoneNumberFormatter(),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer votre numéro';
                }
                final digitsOnly = value.replaceAll(' ', '');
                if (digitsOnly.length != 8) {
                  return 'Le numéro doit contenir 8 chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Instructions de livraison (optionnel)',
                hintText: 'Ex: Sonner à la porte principale',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Portefeuille JUFA'),
              ],
            ),
            subtitle: const Text('Payer avec votre solde JUFA'),
            value: 'wallet',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() => _selectedPaymentMethod = value!);
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Text('Carte Visa'),
              ],
            ),
            subtitle: const Text('Carte bancaire ou carte virtuelle JUFA'),
            value: 'visa',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() => _selectedPaymentMethod = value!);
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(Icons.money, color: Colors.green[700]),
                const SizedBox(width: 12),
                const Text('Paiement à la livraison'),
              ],
            ),
            subtitle: const Text('Payez en espèces lors de la réception'),
            value: 'cash_on_delivery',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() => _selectedPaymentMethod = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetailsForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de carte',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Numéro de carte *',
                hintText: '1234 5678 9012 3456',
                prefixIcon: const Icon(Icons.credit_card),
                suffixIcon: _isCardNumberValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              onChanged: (value) {
                final digitsOnly = value.replaceAll(' ', '');
                setState(() {
                  _isCardNumberValid = digitsOnly.length >= 13 && digitsOnly.length <= 16;
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer le numéro de carte';
                }
                final digitsOnly = value.replaceAll(' ', '');
                if (digitsOnly.length < 13 || digitsOnly.length > 16) {
                  return 'Numéro de carte invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: 'Nom du titulaire *',
                hintText: 'JOHN DOE',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: _isCardHolderValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                setState(() {
                  _isCardHolderValid = value.trim().length >= 3;
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer le nom du titulaire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryDateController,
                    decoration: InputDecoration(
                      labelText: 'Date d\'expiration *',
                      hintText: 'MM/AA',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: _isExpiryDateValid
                          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateFormatter(),
                    ],
                    onChanged: (value) {
                      if (value.contains('/') && value.length == 5) {
                        final parts = value.split('/');
                        final month = int.tryParse(parts[0]);
                        setState(() {
                          _isExpiryDateValid = month != null && month >= 1 && month <= 12;
                        });
                      } else {
                        setState(() {
                          _isExpiryDateValid = false;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Date requise';
                      }
                      if (!value.contains('/') || value.length != 5) {
                        return 'Format: MM/AA';
                      }
                      final parts = value.split('/');
                      final month = int.tryParse(parts[0]);
                      if (month == null || month < 1 || month > 12) {
                        return 'Mois invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV *',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: _isCvvValid
                          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isCvvValid = value.length == 3;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'CVV requis';
                      }
                      if (value.length != 3) {
                        return '3 chiffres';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vos informations sont sécurisées et cryptées',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            const Divider(height: 24),
            _buildSummaryRow('Sous-total', widget.totalAmount),
            const SizedBox(height: 8),
            _buildSummaryRow('Frais de livraison', _shippingFee),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              widget.totalAmount + _shippingFee,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? null : Colors.grey[700],
          ),
        ),
        Text(
          Formatters.formatCurrency(amount),
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Confirmer la commande',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }

    // Retirer tous les espaces
    final digitsOnly = text.replaceAll(' ', '');
    
    // Formater au format XX XX XX XX
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      // Ajouter un espace après chaque paire de chiffres (sauf à la fin)
      if ((i + 1) % 2 == 0 && i + 1 != digitsOnly.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }

    // Retirer tous les espaces
    final digitsOnly = text.replaceAll(' ', '');
    
    // Formater au format XXXX XXXX XXXX XXXX
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      // Ajouter un espace après chaque groupe de 4 chiffres (sauf à la fin)
      if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }

    // Retirer tous les slashes
    final digitsOnly = text.replaceAll('/', '');
    
    // Formater au format MM/AA
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
