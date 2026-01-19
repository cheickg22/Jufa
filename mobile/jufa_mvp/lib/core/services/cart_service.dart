import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';
  
  List<CartItem> _cartItems = [];
  
  List<CartItem> get items => _cartItems;
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        _cartItems = decoded.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      print('❌ Erreur chargement panier: $e');
      _cartItems = [];
    }
  }
  
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('❌ Erreur sauvegarde panier: $e');
    }
  }
  
  Future<void> addItem(CartItem item) async {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.productId == item.productId && cartItem.variant == item.variant,
    );
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }
    
    await _saveCart();
  }
  
  Future<void> removeItem(int productId, {String? variant}) async {
    _cartItems.removeWhere(
      (item) => item.productId == productId && item.variant == variant,
    );
    await _saveCart();
  }
  
  Future<void> updateQuantity(int productId, int quantity, {String? variant}) async {
    final index = _cartItems.indexWhere(
      (item) => item.productId == productId && item.variant == variant,
    );
    
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      await _saveCart();
    }
  }
  
  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
  }
  
  bool hasItem(int productId, {String? variant}) {
    return _cartItems.any(
      (item) => item.productId == productId && item.variant == variant,
    );
  }
  
  int getItemQuantity(int productId, {String? variant}) {
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId && item.variant == variant,
      orElse: () => CartItem(
        productId: 0,
        productName: '',
        productImage: '',
        price: 0,
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}
