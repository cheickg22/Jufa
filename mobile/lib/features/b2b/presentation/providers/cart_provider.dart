import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get lineTotal => product.effectivePrice * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final String? wholesalerId;
  final String? wholesalerName;
  final Map<String, CartItem> items;
  final String? notes;
  final String? deliveryAddress;
  final bool useCredit;

  CartState({
    this.wholesalerId,
    this.wholesalerName,
    this.items = const {},
    this.notes,
    this.deliveryAddress,
    this.useCredit = false,
  });

  int get totalItems => items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int getQuantity(String productId) => items[productId]?.quantity ?? 0;

  CartState copyWith({
    String? wholesalerId,
    String? wholesalerName,
    Map<String, CartItem>? items,
    String? notes,
    String? deliveryAddress,
    bool? useCredit,
    bool clearNotes = false,
    bool clearAddress = false,
  }) {
    return CartState(
      wholesalerId: wholesalerId ?? this.wholesalerId,
      wholesalerName: wholesalerName ?? this.wholesalerName,
      items: items ?? this.items,
      notes: clearNotes ? null : (notes ?? this.notes),
      deliveryAddress: clearAddress ? null : (deliveryAddress ?? this.deliveryAddress),
      useCredit: useCredit ?? this.useCredit,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void setWholesaler(String wholesalerId, String wholesalerName) {
    if (state.wholesalerId != wholesalerId) {
      state = CartState(wholesalerId: wholesalerId, wholesalerName: wholesalerName);
    }
  }

  void addToCart(Product product, {int quantity = 1}) {
    if (state.wholesalerId == null) return;

    final currentItem = state.items[product.id];
    final newQuantity = (currentItem?.quantity ?? 0) + quantity;

    if (newQuantity < product.minOrderQuantity) {
      return;
    }

    if (newQuantity > product.stockQuantity) {
      return;
    }

    final updatedItems = Map<String, CartItem>.from(state.items);
    updatedItems[product.id] = CartItem(product: product, quantity: newQuantity);
    state = state.copyWith(items: updatedItems);
  }

  void updateQuantity(String productId, int quantity) {
    final currentItem = state.items[productId];
    if (currentItem == null) return;

    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    if (quantity < currentItem.product.minOrderQuantity) {
      return;
    }

    if (quantity > currentItem.product.stockQuantity) {
      return;
    }

    final updatedItems = Map<String, CartItem>.from(state.items);
    updatedItems[productId] = currentItem.copyWith(quantity: quantity);
    state = state.copyWith(items: updatedItems);
  }

  void removeFromCart(String productId) {
    final updatedItems = Map<String, CartItem>.from(state.items);
    updatedItems.remove(productId);
    state = state.copyWith(items: updatedItems);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes, clearNotes: notes == null);
  }

  void setDeliveryAddress(String? address) {
    state = state.copyWith(deliveryAddress: address, clearAddress: address == null);
  }

  void setUseCredit(bool useCredit) {
    state = state.copyWith(useCredit: useCredit);
  }

  void clearCart() {
    state = CartState(
      wholesalerId: state.wholesalerId,
      wholesalerName: state.wholesalerName,
    );
  }

  void reset() {
    state = CartState();
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
