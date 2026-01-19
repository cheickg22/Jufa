import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/b2b_order.dart';
import '../datasources/b2b_order_remote_datasource.dart';

class B2BOrderRepository {
  final B2BOrderRemoteDatasource _remoteDatasource;

  B2BOrderRepository(this._remoteDatasource);

  Future<Either<Failure, B2BOrder>> createOrder({
    required String wholesalerId,
    required List<OrderItemRequest> items,
    String? notes,
    String? deliveryAddress,
    bool useCredit = false,
  }) async {
    try {
      final request = CreateOrderRequest(
        wholesalerId: wholesalerId,
        items: items,
        notes: notes,
        deliveryAddress: deliveryAddress,
        useCredit: useCredit,
      );
      final order = await _remoteDatasource.createOrder(request);
      return Right(order.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<B2BOrder>>> getRetailerOrders({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final orders = await _remoteDatasource.getRetailerOrders(
        status: status,
        page: page,
        size: size,
      );
      return Right(orders.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<B2BOrder>>> getWholesalerOrders(
    String wholesalerId, {
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final orders = await _remoteDatasource.getWholesalerOrders(
        wholesalerId,
        status: status,
        page: page,
        size: size,
      );
      return Right(orders.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, B2BOrder>> confirmOrder(String orderId) async {
    try {
      final order = await _remoteDatasource.confirmOrder(orderId);
      return Right(order.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, B2BOrder>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final order = await _remoteDatasource.updateOrderStatus(orderId, status);
      return Right(order.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, B2BOrder>> cancelOrder(
    String orderId,
    String reason,
  ) async {
    try {
      final order = await _remoteDatasource.cancelOrder(orderId, reason);
      return Right(order.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> getPendingOrdersCount(String wholesalerId) async {
    try {
      final count = await _remoteDatasource.getPendingOrdersCount(wholesalerId);
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
