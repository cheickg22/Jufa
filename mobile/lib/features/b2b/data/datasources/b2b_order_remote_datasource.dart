import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/b2b_order_model.dart';

class OrderItemRequest {
  final String productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}

class CreateOrderRequest {
  final String wholesalerId;
  final List<OrderItemRequest> items;
  final String? notes;
  final String? deliveryAddress;
  final bool useCredit;

  CreateOrderRequest({
    required this.wholesalerId,
    required this.items,
    this.notes,
    this.deliveryAddress,
    this.useCredit = false,
  });

  Map<String, dynamic> toJson() => {
        'wholesalerId': wholesalerId,
        'items': items.map((item) => item.toJson()).toList(),
        if (notes != null) 'notes': notes,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        'useCredit': useCredit,
      };
}

class B2BOrderRemoteDatasource {
  final ApiClient _apiClient;

  B2BOrderRemoteDatasource(this._apiClient);

  Future<B2BOrderModel> createOrder(CreateOrderRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.b2bOrdersCreate,
      data: request.toJson(),
    );
    return B2BOrderModel.fromJson(response['data']);
  }

  Future<List<B2BOrderModel>> getRetailerOrders({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (status != null) {
      queryParams['status'] = status;
    }
    final response = await _apiClient.get(
      ApiConstants.b2bOrdersRetailer,
      queryParams: queryParams,
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => B2BOrderModel.fromJson(json)).toList();
  }

  Future<List<B2BOrderModel>> getWholesalerOrders(
    String wholesalerId, {
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (status != null) {
      queryParams['status'] = status;
    }
    final response = await _apiClient.get(
      ApiConstants.b2bOrdersWholesalerById(wholesalerId),
      queryParams: queryParams,
    );
    final content = response['data']?['content'] ?? response['data'] ?? [];
    return (content as List).map((json) => B2BOrderModel.fromJson(json)).toList();
  }

  Future<B2BOrderModel> confirmOrder(String orderId) async {
    final response = await _apiClient.post(
      ApiConstants.b2bOrderConfirm(orderId),
    );
    return B2BOrderModel.fromJson(response['data']);
  }

  Future<B2BOrderModel> updateOrderStatus(String orderId, String status) async {
    final response = await _apiClient.put(
      ApiConstants.b2bOrderStatus(orderId),
      data: {'status': status},
    );
    return B2BOrderModel.fromJson(response['data']);
  }

  Future<B2BOrderModel> cancelOrder(String orderId, String reason) async {
    final response = await _apiClient.post(
      ApiConstants.b2bOrderCancel(orderId),
      data: {'reason': reason},
    );
    return B2BOrderModel.fromJson(response['data']);
  }

  Future<int> getPendingOrdersCount(String wholesalerId) async {
    final response = await _apiClient.get(
      ApiConstants.b2bOrdersPendingCount(wholesalerId),
    );
    return response['data'] as int? ?? 0;
  }
}
