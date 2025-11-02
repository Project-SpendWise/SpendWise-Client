import '../../data/mock/mock_data.dart';
import '../../providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockDataInitializer {
  static void initializeMockData(WidgetRef ref) {
    // Initialize transactions from mock data
    final mockTransactions = MockData.getMockTransactions();
    final transactionNotifier = ref.read(transactionProvider.notifier);
    transactionNotifier.addTransactions(mockTransactions);
  }
}

