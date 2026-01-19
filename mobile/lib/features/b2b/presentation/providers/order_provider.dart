import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/b2b_order_remote_datasource.dart';
import '../../data/repositories/b2b_order_repository.dart';
import '../../domain/entities/b2b_order.dart';
import 'cart_provider.dart';

final b2bOrderRepositoryProvider = Provider<B2BOrderRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final datasource = B2BOrderRemoteDatasource(apiClient);
  return B2BOrderRepository(datasource);
});

class B2BOrderState {
  final bool isLoading;
  final String? error;
  final List<B2BOrder> retailerOrders;
  final List<B2BOrder> wholesalerOrders;
  final B2BOrder? currentOrder;
  final bool hasMoreRetailer;
  final bool hasMoreWholesaler;
  final int retailerPage;
  final int wholesalerPage;

  B2BOrderState({
    this.isLoading = false,
    this.error,
    this.retailerOrders = const [],
    this.wholesalerOrders = const [],
    this.currentOrder,
    this.hasMoreRetailer = true,
    this.hasMoreWholesaler = true,
    this.retailerPage = 0,
    this.wholesalerPage = 0,
  });

  B2BOrderState copyWith({
    bool? isLoading,
    String? error,
    List<B2BOrder>? retailerOrders,
    List<B2BOrder>? wholesalerOrders,
    B2BOrder? currentOrder,
    bool? hasMoreRetailer,
    bool? hasMoreWholesaler,
    int? retailerPage,
    int? wholesalerPage,
    bool clearError = false,
    bool clearOrder = false,
  }) {
    return B2BOrderState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      retailerOrders: retailerOrders ?? this.retailerOrders,
      wholesalerOrders: wholesalerOrders ?? this.wholesalerOrders,
      currentOrder: clearOrder ? null : (currentOrder ?? this.currentOrder),
      hasMoreRetailer: hasMoreRetailer ?? this.hasMoreRetailer,
      hasMoreWholesaler: hasMoreWholesaler ?? this.hasMoreWholesaler,
      retailerPage: retailerPage ?? this.retailerPage,
      wholesalerPage: wholesalerPage ?? this.wholesalerPage,
    );
  }
}

class B2BOrderNotifier extends StateNotifier<B2BOrderState> {
  final B2BOrderRepository _repository;
  final CartNotifier _cartNotifier;

  B2BOrderNotifier(this._repository, this._cartNotifier) : super(B2BOrderState());

  Future<bool> createOrder() async {
    final cartState = _cartNotifier.state;
    if (cartState.wholesalerId == null || cartState.isEmpty) {
      state = state.copyWith(error: 'Panier vide');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final items = cartState.items.values.map((item) {
      return OrderItemRequest(
        productId: item.product.id,
        quantity: item.quantity,
      );
    }).toList();

    final result = await _repository.createOrder(
      wholesalerId: cartState.wholesalerId!,
      items: items,
      notes: cartState.notes,
      deliveryAddress: cartState.deliveryAddress,
      useCredit: cartState.useCredit,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (order) {
        state = state.copyWith(
          isLoading: false,
          currentOrder: order,
          retailerOrders: [order, ...state.retailerOrders],
        );
        _cartNotifier.clearCart();
        return true;
      },
    );
  }

  Future<void> loadRetailerOrders({String? status, bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        retailerOrders: [],
        retailerPage: 0,
        hasMoreRetailer: true,
      );
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getRetailerOrders(
      status: status,
      page: state.retailerPage,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (orders) => state = state.copyWith(
        isLoading: false,
        retailerOrders: refresh ? orders : [...state.retailerOrders, ...orders],
        hasMoreRetailer: orders.length >= 20,
        retailerPage: refresh ? 0 : state.retailerPage,
      ),
    );
  }

  Future<void> loadMoreRetailerOrders({String? status}) async {
    if (state.isLoading || !state.hasMoreRetailer) return;

    state = state.copyWith(retailerPage: state.retailerPage + 1);
    await loadRetailerOrders(status: status);
  }

  Future<void> loadWholesalerOrders(String wholesalerId, {String? status, bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        wholesalerOrders: [],
        wholesalerPage: 0,
        hasMoreWholesaler: true,
      );
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getWholesalerOrders(
      wholesalerId,
      status: status,
      page: state.wholesalerPage,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (orders) => state = state.copyWith(
        isLoading: false,
        wholesalerOrders: refresh ? orders : [...state.wholesalerOrders, ...orders],
        hasMoreWholesaler: orders.length >= 20,
        wholesalerPage: refresh ? 0 : state.wholesalerPage,
      ),
    );
  }

  Future<bool> confirmOrder(String orderId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.confirmOrder(orderId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (order) {
        _updateOrderInLists(order);
        state = state.copyWith(isLoading: false, currentOrder: order);
        return true;
      },
    );
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.updateOrderStatus(orderId, status);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (order) {
        _updateOrderInLists(order);
        state = state.copyWith(isLoading: false, currentOrder: order);
        return true;
      },
    );
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.cancelOrder(orderId, reason);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (order) {
        _updateOrderInLists(order);
        state = state.copyWith(isLoading: false, currentOrder: order);
        return true;
      },
    );
  }

  void _updateOrderInLists(B2BOrder updatedOrder) {
    final updatedRetailer = state.retailerOrders.map((o) {
      return o.id == updatedOrder.id ? updatedOrder : o;
    }).toList();

    final updatedWholesaler = state.wholesalerOrders.map((o) {
      return o.id == updatedOrder.id ? updatedOrder : o;
    }).toList();

    state = state.copyWith(
      retailerOrders: updatedRetailer,
      wholesalerOrders: updatedWholesaler,
    );
  }

  void reset() {
    state = B2BOrderState();
  }
}

final b2bOrderNotifierProvider = StateNotifierProvider<B2BOrderNotifier, B2BOrderState>((ref) {
  final repository = ref.watch(b2bOrderRepositoryProvider);
  final cartNotifier = ref.watch(cartNotifierProvider.notifier);
  return B2BOrderNotifier(repository, cartNotifier);
});
