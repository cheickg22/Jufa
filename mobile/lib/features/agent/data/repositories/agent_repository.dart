import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/agent_dashboard.dart';
import '../../domain/entities/agent_transaction.dart';
import '../../domain/entities/agent_daily_report.dart';
import '../../domain/entities/fee_calculation.dart';
import '../../domain/entities/client_info.dart';
import '../datasources/agent_remote_datasource.dart';

class AgentRepository {
  final AgentRemoteDatasource _remoteDatasource;

  AgentRepository(this._remoteDatasource);

  Future<Either<Failure, AgentDashboard>> getDashboard() async {
    try {
      final dashboard = await _remoteDatasource.getDashboard();
      return Right(dashboard);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AgentTransaction>> processCashIn({
    required String customerPhone,
    required double amount,
    String? description,
  }) async {
    try {
      final request = CashInRequestModel(
        customerPhone: customerPhone,
        amount: amount,
        description: description,
      );
      final transaction = await _remoteDatasource.processCashIn(request);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AgentTransaction>> processCashOut({
    required String customerPhone,
    required double amount,
    required String customerPin,
    String? description,
  }) async {
    try {
      final request = CashOutRequestModel(
        customerPhone: customerPhone,
        amount: amount,
        customerPin: customerPin,
        description: description,
      );
      final transaction = await _remoteDatasource.processCashOut(request);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, FeeCalculation>> calculateCashInFees(double amount) async {
    try {
      final fees = await _remoteDatasource.calculateCashInFees(amount);
      return Right(fees);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, FeeCalculation>> calculateCashOutFees(double amount) async {
    try {
      final fees = await _remoteDatasource.calculateCashOutFees(amount);
      return Right(fees);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<AgentTransaction>>> getTransactions({int page = 0}) async {
    try {
      final transactions = await _remoteDatasource.getTransactions(page: page);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<AgentTransaction>>> getCashInTransactions({int page = 0}) async {
    try {
      final transactions = await _remoteDatasource.getCashInTransactions(page: page);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<AgentTransaction>>> getCashOutTransactions({int page = 0}) async {
    try {
      final transactions = await _remoteDatasource.getCashOutTransactions(page: page);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<AgentDailyReport>>> getLast30DaysReports() async {
    try {
      final reports = await _remoteDatasource.getLast30DaysReports();
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ClientInfo>> searchClient(String phone) async {
    try {
      final client = await _remoteDatasource.searchClient(phone);
      return Right(client);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> verifySecretCode(String code) async {
    try {
      final result = await _remoteDatasource.verifySecretCode(code);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateSecretCode(String newCode, {String? oldCode}) async {
    try {
      await _remoteDatasource.updateSecretCode(newCode, oldCode: oldCode);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
