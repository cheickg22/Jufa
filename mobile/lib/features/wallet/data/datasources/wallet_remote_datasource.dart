import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/wallet_model.dart';

class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Future<Either<Failure, List<WalletModel>>> getWallets() async {
    try {
      debugPrint('[WalletDataSource] Fetching wallets from ${ApiConstants.wallets}');
      final response = await _apiClient.get(ApiConstants.wallets);
      debugPrint('[WalletDataSource] Response: $response');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        final wallets = data.map((json) => WalletModel.fromJson(json)).toList();
        debugPrint('[WalletDataSource] Parsed ${wallets.length} wallets');
        return Right(wallets);
      }
      
      final errorMsg = response['error']?['message'] ?? 'Failed to load wallets';
      debugPrint('[WalletDataSource] API Error: $errorMsg');
      return Left(ServerFailure(errorMsg));
    } catch (e, stackTrace) {
      debugPrint('[WalletDataSource] Exception: $e');
      debugPrint('[WalletDataSource] StackTrace: $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WalletModel>> getWallet(String walletId) async {
    try {
      final response = await _apiClient.get(ApiConstants.walletById(walletId));
      
      if (response['success'] == true) {
        return Right(WalletModel.fromJson(response['data']));
      }
      
      return Left(ServerFailure(response['error']?['message'] ?? 'Wallet not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getTotalBalance() async {
    try {
      final response = await _apiClient.get('${ApiConstants.wallets}/balance');
      
      if (response['success'] == true) {
        return Right(response['data']);
      }
      
      return Left(ServerFailure(response['error']?['message'] ?? 'Failed to load balance'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
