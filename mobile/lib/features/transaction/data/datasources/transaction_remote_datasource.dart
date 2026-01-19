import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDataSource {
  final ApiClient _apiClient;

  TransactionRemoteDataSource(this._apiClient);

  Future<Either<Failure, TransactionModel>> transfer({
    required String receiverPhone,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.transactionsTransfer,
        data: {
          'receiverPhone': receiverPhone,
          'amount': amount,
          if (description != null) 'description': description,
        },
      );
      
      if (response['success'] == true) {
        return Right(TransactionModel.fromJson(response['data']));
      }
      
      return Left(ServerFailure(response['error']?['message'] ?? 'Transfer failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<TransactionModel>>> getTransactionHistory({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.transactions,
        queryParams: {'page': page, 'size': size},
      );
      
      if (response['success'] == true) {
        final content = response['data']['content'] as List<dynamic>? ?? response['data'] as List<dynamic>?;
        if (content != null) {
          final transactions = content.map((json) => TransactionModel.fromJson(json)).toList();
          return Right(transactions);
        }
        return const Right([]);
      }
      
      return Left(ServerFailure(response['error']?['message'] ?? 'Failed to load transactions'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, TransactionModel>> getTransaction(String transactionId) async {
    try {
      final response = await _apiClient.get(ApiConstants.transactionById(transactionId));
      
      if (response['success'] == true) {
        return Right(TransactionModel.fromJson(response['data']));
      }
      
      return Left(ServerFailure(response['error']?['message'] ?? 'Transaction not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
