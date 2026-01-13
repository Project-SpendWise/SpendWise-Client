import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/budget_service.dart';
import '../../data/services/api_service.dart';
import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class AppInitializer {
  static Future<void> initialize(WidgetRef ref) async {
    final authState = ref.read(authProvider);
    
    // Only load data if user is authenticated
    if (!authState.isAuthenticated || authState.accessToken == null) {
      return;
    }

    try {
      // Get selected profile
      final profileState = ref.read(profileProvider);
      final statementId = profileState.selectedProfileId;

      // Set auth token on API service
      final apiService = ApiService();
      apiService.setAuthToken(authState.accessToken!);
      
      // Set token refresh callback
      apiService.setTokenRefreshCallback(() async {
        final authNotifier = ref.read(authProvider.notifier);
        final refreshed = await authNotifier.refreshAccessToken();
        if (refreshed) {
          final newAuthState = ref.read(authProvider);
          return newAuthState.accessToken;
        }
        return null;
      });

      // Initialize services with API service
      final transactionService = TransactionService(apiService: apiService);
      final budgetService = BudgetService(apiService: apiService);

      // Load transactions from API (filtered by selected profile if any)
      print('=== AppInitializer: Loading transactions ===');
      print('StatementId: $statementId');
      final transactions = await transactionService.getTransactions(
        statementId: statementId,
      );
      print('Loaded ${transactions.length} transactions from API');
      
      if (transactions.isNotEmpty) {
        // Log sample transaction
        final sample = transactions.first;
        print('Sample transaction:');
        print('  id: ${sample.id}');
        print('  type: ${sample.type}');
        print('  category: ${sample.category}');
        print('  amount: ${sample.amount}');
        print('  date: ${sample.date}');
        print('  description: ${sample.description}');
        
        // Log transaction breakdown
        final incomeCount = transactions.where((t) => t.type == TransactionType.income).length;
        final expenseCount = transactions.where((t) => t.type == TransactionType.expense).length;
        final expensesWithCategories = transactions.where((t) => t.type == TransactionType.expense && t.category != null).length;
        print('Transaction breakdown:');
        print('  Income: $incomeCount');
        print('  Expenses: $expenseCount');
        print('  Expenses with categories: $expensesWithCategories');
        
        // Log unique categories
        final uniqueCategories = transactions.where((t) => t.category != null).map((t) => t.category!).toSet();
        print('Unique categories: $uniqueCategories');
      } else {
        print('WARNING: No transactions loaded!');
        print('This could mean:');
        print('  1. No file has been uploaded yet');
        print('  2. File hasn\'t been processed (check statement status)');
        print('  3. Backend returned empty array');
        print('  4. statementId filter is too restrictive');
      }
      
      final transactionNotifier = ref.read(transactionProvider.notifier);
      transactionNotifier.clearTransactions();
      transactionNotifier.addTransactions(transactions);
      print('=== AppInitializer: Transactions added to provider ===');

      // Load budgets from API
      print('Loading budgets...');
      final budgets = await budgetService.getBudgets();
      print('Loaded ${budgets.length} budgets');
      
      final budgetNotifier = ref.read(budgetProvider.notifier);
      budgetNotifier.clearBudgets();
      for (var budget in budgets) {
        budgetNotifier.addBudget(budget);
      }
    } catch (e, stackTrace) {
      // If loading fails, continue without data
      // User can retry by refreshing
      print('Failed to load initial data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Reload data when profile changes
  static Future<void> reloadData(WidgetRef ref) async {
    await initialize(ref);
  }
}

