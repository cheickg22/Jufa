import 'package:flutter_test/flutter_test.dart';
import 'package:jufa_mobile/features/agent/domain/entities/agent_transaction.dart';
import 'package:jufa_mobile/features/agent/domain/entities/agent_enums.dart';
import 'package:jufa_mobile/features/agent/domain/entities/fee_calculation.dart';

void main() {
  group('AgentTransaction', () {
    test('creates transaction with all fields', () {
      final transaction = AgentTransaction(
        id: '123',
        reference: 'CI1234567890',
        transactionType: AgentTransactionType.cashIn,
        transactionTypeName: 'CASH_IN',
        status: AgentTransactionStatus.completed,
        statusName: 'COMPLETED',
        customerId: 'cust_123',
        customerPhone: '+22370001234',
        amount: 10000,
        fee: 100,
        totalAmount: 10100,
        agentCommission: 70,
        createdAt: DateTime.now(),
      );

      expect(transaction.id, '123');
      expect(transaction.reference, 'CI1234567890');
      expect(transaction.transactionType, AgentTransactionType.cashIn);
      expect(transaction.amount, 10000);
      expect(transaction.fee, 100);
      expect(transaction.agentCommission, 70);
      expect(transaction.status, AgentTransactionStatus.completed);
    });

    test('totalAmount is provided correctly', () {
      final transaction = AgentTransaction(
        id: '123',
        reference: 'CI1234567890',
        transactionType: AgentTransactionType.cashIn,
        transactionTypeName: 'CASH_IN',
        status: AgentTransactionStatus.completed,
        statusName: 'COMPLETED',
        customerId: 'cust_123',
        customerPhone: '+22370001234',
        amount: 10000,
        fee: 100,
        totalAmount: 10100,
        agentCommission: 70,
        createdAt: DateTime.now(),
      );

      expect(transaction.totalAmount, 10100);
    });

    test('creates cash-out transaction', () {
      final transaction = AgentTransaction(
        id: '123',
        reference: 'CO1234567890',
        transactionType: AgentTransactionType.cashOut,
        transactionTypeName: 'CASH_OUT',
        status: AgentTransactionStatus.completed,
        statusName: 'COMPLETED',
        customerId: 'cust_456',
        customerPhone: '+22370001234',
        amount: 10000,
        fee: 150,
        totalAmount: 9850,
        agentCommission: 105,
        createdAt: DateTime.now(),
      );

      expect(transaction.transactionType, AgentTransactionType.cashOut);
      expect(transaction.totalAmount, 9850);
    });
  });

  group('AgentTransactionType', () {
    test('has correct values', () {
      expect(AgentTransactionType.values.length, 2);
      expect(AgentTransactionType.cashIn.name, 'cashIn');
      expect(AgentTransactionType.cashOut.name, 'cashOut');
    });
  });

  group('AgentTransactionStatus', () {
    test('has correct values', () {
      expect(AgentTransactionStatus.values.length, 4);
      expect(AgentTransactionStatus.pending.name, 'pending');
      expect(AgentTransactionStatus.completed.name, 'completed');
      expect(AgentTransactionStatus.cancelled.name, 'cancelled');
      expect(AgentTransactionStatus.failed.name, 'failed');
    });
  });

  group('FeeCalculation', () {
    test('creates fee calculation correctly', () {
      final feeCalc = FeeCalculation(
        amount: 10000,
        fee: 100,
        totalAmount: 10100,
        agentCommission: 70,
        feeDescription: 'Frais de dépôt: 1%',
      );

      expect(feeCalc.amount, 10000);
      expect(feeCalc.fee, 100);
      expect(feeCalc.agentCommission, 70);
      expect(feeCalc.totalAmount, 10100);
    });

    test('fee description is provided', () {
      final feeCalc = FeeCalculation(
        amount: 10000,
        fee: 100,
        totalAmount: 10100,
        agentCommission: 70,
        feeDescription: 'Frais de dépôt: 1%',
      );

      expect(feeCalc.feeDescription, 'Frais de dépôt: 1%');
    });
  });
}
